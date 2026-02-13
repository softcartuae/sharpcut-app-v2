import 'dart:developer';
import 'package:sharp_cut/core/database/database_helper.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';

class SyncToServer {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<Either<String, String>> syncTransactionsToServer() async {
    try {
      log("Starting transaction sync...");

     
      final registerSyncResult = await _syncCashRegisterIfNeeded();

      String? registerSyncError;
      registerSyncResult.fold((l) => registerSyncError = l, (r) => null);

      if (registerSyncError != null) {
        log("Cash register sync failed: $registerSyncError");
        return Left(registerSyncError!);
      }

      final transactions = await _dbHelper.getUnsyncedTransactions();
      if (transactions.isEmpty) {
        log("No unsynced transactions found.");
        return const Right("No unsynced transactions found.");
      }

      log("Found ${transactions.length} unsynced transactions.");

      List<Map<String, dynamic>> payload = [];
      List<int> transactionIds = [];

      for (var transaction in transactions) {
        int id = transaction['id'];
        transactionIds.add(id);

        final services = await _dbHelper.getTransactionServices(id);
        final payments = await _dbHelper.getTransactionPayments(id);

        List<String> detailIds = [];
        List<int> serviceIds = [];
        List<int> quantities = [];
        List<double> rates = [];
        List<double> taxAmounts = [];
        List<String> currencies = [];
        List<double> amountTotals = [];
        List<double> taxes = [];
        List<double> subTotals = [];
        List<int> isTips = [];

        for (var s in services) {
          detailIds.add(
            (s['detail_id'] ?? 0).toString(),
          ); 
          serviceIds.add(s['service_id'] ?? 0);
          quantities.add(s['quantity'] ?? 0);
          rates.add(s['rate'] ?? 0.0);
          taxAmounts.add(s['tax_amount'] ?? 0.0);

          String? currency = await _dbHelper.getCurrencyForService(
            s['service_id'],
          );
          currencies.add(currency ?? "AED"); // Default to AED if not found
          amountTotals.add(s['amount_total'] ?? 0.0);
          taxes.add(s['tax'] ?? 0.0);
          subTotals.add(s['sub_total'] ?? 0.0);
          isTips.add(s['is_tip'] ?? 0);
        }

        List<String> paymentIds = [];
        List<int> collectedUserIds = [];
        List<String> modes = [];
        List<double> amounts = [];
        List<double> tenderCash = [];
        List<double> changes = [];
        List<String> dates = [];

        for (var p in payments) {
          paymentIds.add(
            (p['payment_id'] ?? 0).toString(),
          ); 
          collectedUserIds.add(p['collected_user_id'] ?? 0);
          modes.add(p['mode'] ?? "");
          amounts.add(p['amount'] ?? 0.0);
          tenderCash.add(p['tender_cash'] ?? 0.0);
          changes.add(p['change'] ?? 0.0);
          dates.add(
            (p['date'] != null && p['date'].toString().isNotEmpty)
                ? DateFormat(
                    'dd/MM/yyyy hh:mm a',
                  ).parse(p['date']).toUtc().toIso8601String()
                : "",
          );
        }

        Map<String, dynamic> transactionMap = {

          "app_id": transaction['app_id'],
          "chair_id": transaction['chair_id'],
          "user_id": transaction['user_id'],
          "cash_register_id":
              transaction['cash_register_id'], 
          "customer_name": transaction['customer_name'] ?? "",
          "customer_number": transaction['customer_number'] ?? "",

          "transaction_date": DateFormat(
            'dd/MM/yyyy hh:mm a',
          ).parse(transaction['transaction_date']).toUtc().toIso8601String(),

          "grand_total": transaction['grand_total'],
          "tax_total": transaction['tax_total'],
          "discount": transaction['discount'],
          "round_off": transaction['round_off'],
          "final_total": transaction['final_total'],
          "invoice_no": transaction['invoice_no'],
          "invoice_date": transaction['invoice_date'],
          "status": transaction['status'],
          "cancellation_reason": transaction['cancellation_reason'],
          "detail_id": detailIds,
          "service_id": serviceIds,
          "quantity": quantities,
          "rate": rates,
          "tax_amount": taxAmounts,
          "currency": currencies,
          "amount_total": amountTotals,
          "tax": taxes,
          "sub_total": subTotals,
          "is_tip": isTips,
          "payment_id": paymentIds,
          "collected_user_id": collectedUserIds,
          "mode": modes,
          "amount": amounts,
          "tender_cash": tenderCash,
          "change": changes,
          "date": dates,

        };
        payload.add(transactionMap);
      }

      final invoiceSettings = await _dbHelper.getInvoiceSettings();
      final invoiceCount = invoiceSettings?['count'] ?? 0;

      log(
        "Sending payload to server: ${payload.length} transactions, Invoice Count: $invoiceCount",
      );
      Map<String, dynamic> data = {
        "transactions": payload,
        "invoice_count": invoiceCount,
      };
      // Call API
      final response = await ApiClient.dio.post(
        ApiClient.transactionsSyncPOSTapi,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mark as synced
        await _dbHelper.markTransactionsAsSynced(transactionIds);
        log("Synced ${transactionIds.length} transactions successfully.");
        return Right(
          "Synced ${transactionIds.length} transactions successfully.",
        );
      } else {
        log(
          "Failed to sync transactions: ${response.statusCode} - ${response.statusMessage}",
        );
        return Left(
          "Failed to sync transactions: ${response.statusCode} - ${response.statusMessage}",
        );
      }
    } catch (e) {
      log("Error syncing transactions: $e");
      return Left("Error syncing transactions: $e");
    }
  }

  Future<Either<String, bool>> isFullySynced() async {
    try {
      final result = await _dbHelper.isFullySynced();
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, bool>> _syncCashRegisterIfNeeded() async {
    try {
      final register = await _dbHelper.getLastOpenCashRegister();
      if (register == null) {
        log("No open cash register found. Nothing to sync.");
        return const Left("No open cash register found.");
      }

      int isSynced = register['is_synced'] ?? 0;
      if (isSynced == 1) {
        log("Cash register ${register['id']} is already synced.");
        return const Right(true);
      }

      log("Syncing cash register ${register['id']}...");

      final payload = {
        "id": register['id'],
        "opened_by": register['opened_by'],
        "closed_by": register['closed_by'], 
        "opened_by_type": register['opened_by_type'],
        "closed_by_type": register['closed_by_type'], 
        "opening_amount": register['opening_amount'],
        "closing_amount": register['closing_amount'], 
        "opened_at": DateFormat(
          'dd/MM/yyyy hh:mm a',
        ).parse(register['opened_at']).toUtc().toIso8601String(),
        "closed_at": register['closed_at'] != null
            ? DateFormat(
                'dd/MM/yyyy hh:mm a',
              ).parse(register['closed_at']).toUtc().toIso8601String()
            : null, 
        "is_sync": true, 
      };

      final response = await ApiClient.dio.post(
        ApiClient.cashRegistersSyncApi,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          log("Cash register synced successfully.");
          await _dbHelper.updateCashRegisterSyncStatus(register['id'], 1);
          return const Right(true);
        } else {
          log("Failed to sync cash register: ${data['message']}");
          return Left(data['message'] ?? "Failed to sync cash register.");
        }
      } else {
        log("Failed to sync cash register: ${response.statusCode}");
        return Left("Failed to sync cash register: ${response.statusCode}");
      }
    } catch (e) {
      log("Error syncing cash register: $e");
      return Left("Error syncing cash register");
    }
  }

  Future<Either<String, String>> syncTransactionsFromServer() async {
    try {
      log("Starting transaction pull from server...");
      final hasData = await _dbHelper.hasTransactionData();

      if (hasData) {
        return const Right("No new transactions from server.");
      }

      final response = await ApiClient.dio.get(ApiClient.transactionsGETApi);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];

        if (data.isEmpty) {
          return const Right("No new transactions from server.");
        }

        log("Received transactions from server.");

        for (var item in data) {
          await _processTransaction(item);
        }

        return Right("Pulled transactions successfully.");
      } else {
        return Left("Failed to pull transactions: ${response.statusCode}");
      }
    } catch (e) {
      log("Error pulling transactions: $e");
      return Left("Error pulling transactions: $e");
    }
  }

  Future<Either<String, String>> syncCashRegistersFromServer() async {
    try {
      log("Starting cash registers pull from server...");

      final response = await ApiClient.dio.get(ApiClient.cashRegistersGetApi);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];

        if (data.isEmpty) {
          return const Right("No cash registers from server.");
        }

        log("Received ${data.length} cash registers from server.");

        for (var item in data) {
          // Force is_synced to 1 because we just got it from server
          var registerData = Map<String, dynamic>.from(item);
          registerData['is_synced'] = 1;
          registerData.remove("is_sync");
          await _dbHelper.syncCashRegister(registerData);
        }

        return Right("Pulled ${data.length} cash registers successfully.");
      } else {
        return Left("Failed to pull cash registers: ${response.statusCode}");
      }
    } catch (e) {
      log("Error pulling cash registers: $e");
      return Left("Error pulling cash registers: $e");
    }
  }

  Future<void> _processTransaction(Map<String, dynamic> transactionMap) async {
    try {
      // Extract details (services) and payments
      final details =
          (transactionMap['details'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];

      final payments =
          (transactionMap['payments'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];

      // Prepare transaction data for DB (remove nested lists/objects)
      final transactionForDb = Map<String, dynamic>.from(transactionMap);
      transactionForDb.remove('details');
      transactionForDb.remove('payments');
      transactionForDb.remove('user'); // If user object is nested
      transactionForDb.remove('chair'); // If chair object is nested

      // Force is_synced to 1 because we just got it from server
      transactionForDb['is_synced'] = 1;

      await _dbHelper.syncTransaction(
        transactionData: transactionForDb,
        services: details,
        payments: payments,
      );
    } catch (e) {
      log("Failed to sync transaction ${transactionMap['id']}: $e");
    }
  }
}
