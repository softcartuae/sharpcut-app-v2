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

      // Filter by Search Query (Customer Name or Invoice No)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += '(customer_name LIKE ? OR invoice_no LIKE ?)';
        whereArgs.add('%$searchQuery%');
        whereArgs.add('%$searchQuery%');
      }

      // Filter by Date Range
      if (dateRange != null && dateRange.isNotEmpty) {
        final dates = dateRange.split(' - ');
        if (dates.length == 2) {
          if (whereClause.isNotEmpty) whereClause += ' AND ';
          // Assuming transaction_date is stored as YYYY-MM-DD or similar string format
          // Using string comparison for dates
          whereClause += 'date(transaction_date) BETWEEN date(?) AND date(?)';
          whereArgs.add(dates[0].trim());
          whereArgs.add(dates[1].trim());
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
        orderBy: 'created_at DESC', // Sort by latest
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

        // Map to Model
        transactions.add(BookingResponseModel.fromJson(mutableTransaction));
      }

      return transactions;
    } catch (e) {
      throw Exception("Failed to fetch transactions form local db: $e");
    }
  }
}
