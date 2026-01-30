import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/data/sync/sync_to_server.dart';
import 'package:sharp_cut/domain/cash_registory/service/cash_registory_repo.dart';
import 'package:sharp_cut/core/database/database_helper.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_model.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_response.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';
import 'package:sharp_cut/core/utils/date_formatter.dart';

class CashRegistoryRepoImp implements CashRegistoryRepo {
  @override
  Future<Either<String, bool>> checkCashRegisterStatus() async {
    try {
      final lastOpen = await DatabaseHelper().getLastOpenCashRegister();
      return Right(lastOpen != null);
    } catch (e) {
      return Left('Error checking register status: $e');
    }
  }

  @override
  Future<Either<String, String>> openCashRegister({
    required int userId,
    required Role role,
    required double amount,
    required String password,
  }) async {
    try {
      final localUsers = await DatabaseHelper().getUsers();
      final user = localUsers.firstWhere(
        (element) => element['id'] == userId,
        orElse: () => {},
      );

      if (user.isEmpty) {
        return const Left("User not found.");
      }

      if (user['password'] == null) {
        return const Left("Reset Password Required");
      }

      if (user['password'] != password) {
        return const Left("Invalid password.");
      }
      final lastOpen = await DatabaseHelper().getLastOpenCashRegister();
      if (lastOpen != null) {
        return const Left(
          "A cash register is already open. Please close it first.",
        );
      }

      final data = {
        'opened_by': userId,
        'opened_by_type': role.name,
        'opening_amount': amount,
        'opened_at': DateFormatter.now(),
        'created_at': DateFormatter.now(),
        'is_synced': 0,
      };

      await DatabaseHelper().openCashRegister(data);
      return const Right("Cash register opened successfully.");
    } catch (e) {
      return Left('Error opening cash register: $e');
    }
  }

  @override
  Future<Either<String, CloseRegisterResponse>> closeCashRegister({
    required double amount,
    required int userId,
    required Role role,
    required String password,
    required bool isPrint,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.closeCashRegisterApi,
        data: {
          "is_print": isPrint,
          "closing_amount": amount,
          "user_type": role.name,
          "user_id": userId,
          "password": password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          // Check if we have a locally synced but open register
          final lastOpenSynced = await DatabaseHelper()
              .getLastOpenSyncedCashRegister();

          if (lastOpenSynced != null) {
            final registerId = lastOpenSynced['id'] as int;

            // Calculate totals
            final totals = await DatabaseHelper().calculateSalesTotal(
              registerId,
            );
            final totalSales = totals['total_sales'] ?? 0.0;
            final cashSales = totals['cash_total'] ?? 0.0;
            final openingAmount = (lastOpenSynced['opening_amount'] as num)
                .toDouble();
            final expectedClosing = openingAmount + cashSales;

            final updateData = {
              'closed_by': userId,
              'closed_by_type': role.name,
              'closing_amount': amount,
              'closed_at': DateFormatter.now(),
              'updated_at': DateFormatter.now(),
              'is_synced': 1, // Keep it synced as we just closed it via API
              'total_sales': totalSales,
              'expected_closing': expectedClosing,
              'discrepancy': amount - expectedClosing,
            };

            await DatabaseHelper().closeCashRegister(registerId, updateData);
          }

          CloseRegisterReportModel? report;
          if (data['report'] != null) {
            report = CloseRegisterReportModel.fromJson(data['report']);
          }
          return Right(
            CloseRegisterResponse(
              message: data['message'] ?? 'Cash register closed successfully.',
              report: report,
            ),
          );
        } else {
          return Left(data['message'] ?? 'Failed to close cash register.');
        }
      } else {
        return Left('Failed to close cash register: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(
          e.response?.data['message'] ??
              'Failed to close cash register: ${e.message}',
        );
      } else {
        return Left('Failed to close cash register: ${e.message}');
      }
    } catch (e) {
      return Left('An unexpected error occurred: $e');
    }
  }

  // @override
  // Future<Either<String, CloseRegisterResponse>> closeCashRegister({
  //   required double amount,
  //   required int userId,
  //   required Role role,
  //   required String password,
  //   required bool isPrint,
  // }) async {
  //   try {
  //     final localUsers = await DatabaseHelper().getUsers();
  //     final user = localUsers.firstWhere(
  //       (element) => element['id'] == userId,
  //       orElse: () => {},
  //     );

  //     if (user.isEmpty) {
  //       return const Left("User not found.");
  //     }

  //     if (user['password'] == null) {
  //       return const Left("Reset Password Required");
  //     }

  //     if (user['password'] != password) {
  //       return const Left("Invalid password.");
  //     }

  //     final lastOpen = await DatabaseHelper().getLastOpenCashRegister();
  //     if (lastOpen == null) {
  //       return const Left("No open register found.");
  //     }

  //     final registerId = lastOpen['id'] as int;

  //     // Check for pending transactions
  //     final hasPending = await DatabaseHelper().hasPendingTransactions(
  //       registerId,
  //     );
  //     if (hasPending) {
  //       return const Left(
  //         "there are pending transactions .Please complet or cancel all pending transactions before closing the cash register",
  //       );
  //     }

  //     // Calculate totals before closing
  //     final totals = await DatabaseHelper().calculateSalesTotal(registerId);
  //     final totalSales = totals['total_sales'] ?? 0.0;
  //     final cashSales = totals['cash_total'] ?? 0.0;
  //     final count = (totals['count'] ?? 0).toInt();
  //     final openingAmount = (lastOpen['opening_amount'] as num).toDouble();
  //     final expectedClosing = openingAmount + cashSales;
  //     final updateData = {
  //       'closed_by': userId,
  //       'closed_by_type': role.name,
  //       'closing_amount': amount,
  //       'closed_at': DateFormatter.now(),
  //       'updated_at': DateFormatter.now(),
  //       'is_synced': 0,
  //       'total_sales': totalSales,
  //       'expected_closing': expectedClosing,
  //       'discrepancy': amount - expectedClosing,
  //     };

  //     await DatabaseHelper().closeCashRegister(registerId, updateData);

  //     // Fetch the updated register data from DB to ensure report matches persisted state
  //     // Fetch the updated register data from DB to ensure report matches persisted state
  //     final closedRegister = await DatabaseHelper().getLastClosedCashRegister();
  //     if (closedRegister == null) {
  //       return const Left("Failed to retrieve closed register.");
  //     }

  //     // Generate Offline Report Data
  //     final reportData = await DatabaseHelper().getOfflineReportData(
  //       registerId,
  //     );
  //     final quickReport = QuickReportModel.fromJson(reportData);

  //     final report = CloseRegisterReportModel(
  //       transactions: quickReport,
  //       openingAmount: openingAmount.toString(),
  //       closingAmount: amount,
  //       openedAt: closedRegister['opened_at'] as String,
  //       closedAt: closedRegister['closed_at'] as String,
  //       totalSalesAmount: totalSales,
  //       totalSalesCount: count,
  //       expectedClosingAmount: expectedClosing,
  //       discrepancy: amount - expectedClosing,
  //       closedBy: closedRegister['closed_by'].toString(),
  //       openedBy: closedRegister['opened_by'].toString(),
  //       cashRegisterId: registerId,
  //     );

  //     return Right(
  //       CloseRegisterResponse(
  //         message: 'Cash register closed successfully.',
  //         report: report,
  //       ),
  //     );
  //   } catch (e) {
  //     return Left('Error closing cash register: $e');
  //   }
  // }

  @override
  Future<Either<String, CloseRegisterModel>> getSalesTotal() async {
    try {
      final lastOpen = await DatabaseHelper().getLastOpenCashRegister();
      if (lastOpen == null) {
        return const Left("No open register found.");
      }

      final registerId = lastOpen['id'] as int;
      final totals = await DatabaseHelper().calculateSalesTotal(registerId);
      final openingAmount = (lastOpen['opening_amount'] as num).toDouble();
      final cashSales = totals['cash_total'] ?? 0.0;

      return Right(
        CloseRegisterModel(
          openingDate: lastOpen['opened_at'] as String,
          openingAmount: openingAmount,
          totalSales: totals['total_sales'] ?? 0.0,
          expectedClosingAmount: openingAmount + cashSales,
        ),
      );
    } catch (e) {
      return Left('Error getting sales total: $e');
    }
  }

  @override
  Future<Either<String, CloseRegisterReportModel>>
  getLastCloseRegisterReport() async {
    try {
      final lastClosed = await DatabaseHelper().getLastClosedCashRegister();
      if (lastClosed == null) {
        return const Left("No closed register report found.");
      }

      final registerId = lastClosed['id'] as int;
      final totals = await DatabaseHelper().calculateSalesTotal(registerId);
      final totalSales = totals['total_sales'] ?? 0.0;
      final cashSales = totals['cash_total'] ?? 0.0;
      final count = (totals['count'] ?? 0).toInt();
      final openingAmount = (lastClosed['opening_amount'] as num).toDouble();
      final closingAmount =
          (lastClosed['closing_amount'] as num?)?.toDouble() ?? 0.0;
      final expectedClosing = openingAmount + cashSales;

      // Generate Offline Report Data
      final reportData = await DatabaseHelper().getOfflineReportData(
        registerId,
      );
      final quickReport = QuickReportModel.fromJson(reportData);

      return Right(
        CloseRegisterReportModel(
          transactions: quickReport,
          openingAmount: openingAmount.toString(),
          closingAmount: closingAmount,
          openedAt: lastClosed['opened_at'],
          closedAt: lastClosed['closed_at'],
          totalSalesAmount: totalSales,
          totalSalesCount: count,
          expectedClosingAmount: expectedClosing,
          discrepancy: closingAmount - expectedClosing,
          closedBy: lastClosed['closed_by'] as String,
          openedBy: lastClosed['opened_by'] as String,
          cashRegisterId: registerId,
        ),
      );
    } catch (e) {
      return Left('Error getting report: $e');
    }
  }
}
