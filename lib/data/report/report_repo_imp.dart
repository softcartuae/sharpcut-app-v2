import 'package:sharp_cut/core/database/database_helper.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/report/report_repo.dart';

class ReportRepoImp implements ReportRepo {
  final DatabaseHelper _databaseHelper;

  ReportRepoImp(this._databaseHelper);

  @override
  Future<List<BookingResponseModel>> getTransactions({
    int? userId,
    String? searchQuery,
    String? dateRange,
    String? transactionStatus,
    String? paidStatus,
  }) async {
    try {
      final db = await _databaseHelper.database;

      // 1. Build Query
      String whereClause = '';
      List<dynamic> whereArgs = [];

      // Filter by User ID
      if (userId != null) {
        whereClause += 'user_id = ?';
        whereArgs.add(userId);
      }

      // Filter by Search Query (Customer Name, Invoice No, Customer Number, Transaction ID)
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim();
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause +=
            '(customer_name LIKE ? OR invoice_no LIKE ? OR customer_number LIKE ? OR CAST(id AS TEXT) LIKE ?)';
        whereArgs.add('%$query%');
        whereArgs.add('%$query%');
        whereArgs.add('%$query%');
        whereArgs.add('%$query%');
      }

      // Filter by Date Range
      if (dateRange != null && dateRange.isNotEmpty) {
        final dates = dateRange.split(' - ');
        if (dates.length == 2) {
          if (whereClause.isNotEmpty) whereClause += ' AND ';

          String formatDate(String d) {
            final parts = d.trim().split('/');
            if (parts.length == 3) {
              return "${parts[2]}-${parts[1]}-${parts[0]}"; // yyyy-MM-dd
            }
            return d.trim();
          }

          // Construct YYYY-MM-DD from dd/MM/yyyy for string comparison
          whereClause +=
              '(substr(transaction_date, 7, 4) || "-" || substr(transaction_date, 4, 2) || "-" || substr(transaction_date, 1, 2)) BETWEEN ? AND ?';
          whereArgs.add(formatDate(dates[0]));
          whereArgs.add(formatDate(dates[1]));
        }
      }

      // Filter by Transaction Status
      if (transactionStatus != null &&
          transactionStatus.isNotEmpty &&
          transactionStatus != 'All') {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause +=
            'status LIKE ?'; // Case-insensitive often handled by DB or LIKE
        whereArgs.add(transactionStatus);
      }

      // Filter by Paid Status
      if (paidStatus != null && paidStatus.isNotEmpty && paidStatus != 'All') {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'payment_status LIKE ?';
        whereArgs.add(paidStatus);
      }

      // Execute Query
      final List<Map<String, dynamic>> transactionMaps = await db.query(
        'transactions',
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy:
            'substr(transaction_date, 7, 4) DESC, substr(transaction_date, 4, 2) DESC, substr(transaction_date, 1, 2) DESC, substr(transaction_date, 12, 2) DESC, substr(transaction_date, 15, 2) DESC, id DESC',
      );

      List<BookingResponseModel> transactions = [];

      // 2. Fetch Details & Map to Model
      for (var transaction in transactionMaps) {
        // We need a mutable map to add details
        final Map<String, dynamic> mutableTransaction =
            Map<String, dynamic>.from(transaction);
        final int transactionId = transaction['id'];

        // Fetch User (Staff)
        if (transaction['user_id'] != null) {
          final userResult = await db.query(
            'users',
            where: 'id = ?',
            whereArgs: [transaction['user_id']],
          );
          if (userResult.isNotEmpty) {
            mutableTransaction['user'] = userResult.first;
          }
        }

        // Fetch Services
        final servicesResult = await db.query(
          'transaction_services',
          where: 'transaction_id = ?',
          whereArgs: [transactionId],
        );

        // For each service, we might want to fetch the ServiceModel (name, etc.) if it's not fully in transaction_services
        // But BookingDetail.fromJson expects 'service' object inside.
        // The transaction_services table in database_helper.dart has: service_id, quantity, etc.
        // It does NOT have the service name directly (it's in services table).
        // So we need to join or fetch service details.

        List<Map<String, dynamic>> enrichedServices = [];
        for (var serviceRow in servicesResult) {
          final Map<String, dynamic> enrichedService =
              Map<String, dynamic>.from(serviceRow);
          if (serviceRow['service_id'] != null) {
            final serviceInfo = await db.query(
              'services',
              where: 'id = ?',
              whereArgs: [serviceRow['service_id']],
            );
            if (serviceInfo.isNotEmpty) {
              enrichedService['service'] = serviceInfo.first;
            }
          }
          enrichedServices.add(enrichedService);
        }
        mutableTransaction['details'] = enrichedServices;

        // Fetch Payments
        final paymentsResult = await db.query(
          'transaction_payments',
          where: 'transaction_id = ?',
          whereArgs: [transactionId],
        );
        mutableTransaction['payments'] = paymentsResult;

        // Deduct Discount from Final Total as requested
        final double currentFinalTotal =
            (mutableTransaction['final_total'] as num?)?.toDouble() ?? 0.0;
        final double currentDiscount =
            (mutableTransaction['discount'] as num?)?.toDouble() ?? 0.0;
        mutableTransaction['final_total'] = currentFinalTotal - currentDiscount;

        if (currentDiscount != 0) {
          mutableTransaction['grand_total'] =
              (mutableTransaction['grand_total_after'] as num?)?.toDouble() ??
              0.0;
          mutableTransaction['tax_total'] =
              (mutableTransaction['tax_total_after'] as num?)?.toDouble() ??
              0.0;
        }

        // Map to Model
        transactions.add(BookingResponseModel.fromJson(mutableTransaction));
      }

      return transactions;
    } catch (e) {
      throw Exception("Failed to fetch transactions form local db: $e");
    }
  }
}
