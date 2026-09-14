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
    int limit = 50,
    int page = 1,
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
        whereClause += 'status LIKE ?';
        whereArgs.add(transactionStatus);
      }

      // Filter by Paid Status
      if (paidStatus != null && paidStatus.isNotEmpty && paidStatus != 'All') {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'payment_status LIKE ?';
        whereArgs.add(paidStatus);
      }

      final int offset = (page - 1) * limit;

      // 2. Execute Paginated Query (50 items max)
      final List<Map<String, dynamic>> transactionMaps = await db.query(
        'transactions',
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy:
            'substr(transaction_date, 7, 4) DESC, substr(transaction_date, 4, 2) DESC, substr(transaction_date, 1, 2) DESC, substr(transaction_date, 12, 2) DESC, substr(transaction_date, 15, 2) DESC, id DESC',
        limit: limit,
        offset: offset,
      );

      if (transactionMaps.isEmpty) {
        return [];
      }

      // 3. Bulk Optimization: Fetch Users, Services & Payments in Bulk
      final List<int> txIds = transactionMaps.map((t) => t['id'] as int).toList();
      final String idPlaceholders = List.filled(txIds.length, '?').join(',');

      // Bulk fetch users
      final Set<int> userIds = transactionMaps
          .where((t) => t['user_id'] != null)
          .map((t) => t['user_id'] as int)
          .toSet();
      Map<int, Map<String, dynamic>> userMap = {};
      if (userIds.isNotEmpty) {
        final userPlaceholders = List.filled(userIds.length, '?').join(',');
        final userRows = await db.query(
          'users',
          where: 'id IN ($userPlaceholders)',
          whereArgs: userIds.toList(),
        );
        for (var u in userRows) {
          userMap[u['id'] as int] = u;
        }
      }

      // Bulk fetch services
      final servicesRows = await db.query(
        'transaction_services',
        where: 'transaction_id IN ($idPlaceholders)',
        whereArgs: txIds,
      );

      // Bulk fetch service master names
      final Set<int> serviceIds = servicesRows
          .where((s) => s['service_id'] != null)
          .map((s) => s['service_id'] as int)
          .toSet();
      Map<int, Map<String, dynamic>> masterServiceMap = {};
      if (serviceIds.isNotEmpty) {
        final sPlaceholders = List.filled(serviceIds.length, '?').join(',');
        final masterRows = await db.query(
          'services',
          where: 'id IN ($sPlaceholders)',
          whereArgs: serviceIds.toList(),
        );
        for (var s in masterRows) {
          masterServiceMap[s['id'] as int] = s;
        }
      }

      // Group services by transaction_id
      Map<int, List<Map<String, dynamic>>> txServicesMap = {};
      for (var sRow in servicesRows) {
        final txId = sRow['transaction_id'] as int;
        final enrichedService = Map<String, dynamic>.from(sRow);
        if (sRow['service_id'] != null && masterServiceMap.containsKey(sRow['service_id'])) {
          enrichedService['service'] = masterServiceMap[sRow['service_id']];
        }
        txServicesMap.putIfAbsent(txId, () => []).add(enrichedService);
      }

      // Bulk fetch payments
      final paymentsRows = await db.query(
        'transaction_payments',
        where: 'transaction_id IN ($idPlaceholders)',
        whereArgs: txIds,
      );

      Map<int, List<Map<String, dynamic>>> txPaymentsMap = {};
      for (var pRow in paymentsRows) {
        final txId = pRow['transaction_id'] as int;
        txPaymentsMap.putIfAbsent(txId, () => []).add(pRow);
      }

      // 4. Fast Model Mapping in Memory
      List<BookingResponseModel> transactions = [];
      for (var transaction in transactionMaps) {
        final Map<String, dynamic> mutableTransaction =
            Map<String, dynamic>.from(transaction);
        final int transactionId = transaction['id'];

        if (transaction['user_id'] != null && userMap.containsKey(transaction['user_id'])) {
          mutableTransaction['user'] = userMap[transaction['user_id']];
        }

        mutableTransaction['details'] = txServicesMap[transactionId] ?? [];
        mutableTransaction['payments'] = txPaymentsMap[transactionId] ?? [];

        final double currentFinalTotal =
            (mutableTransaction['final_total'] as num?)?.toDouble() ?? 0.0;
        final double currentDiscount =
            (mutableTransaction['discount'] as num?)?.toDouble() ?? 0.0;
        mutableTransaction['final_total'] = currentFinalTotal - currentDiscount;

        if (currentDiscount != 0) {
          mutableTransaction['grand_total'] =
              (mutableTransaction['grand_total_after'] as num?)?.toDouble() ?? 0.0;
          mutableTransaction['tax_total'] =
              (mutableTransaction['tax_total_after'] as num?)?.toDouble() ?? 0.0;
        }

        transactions.add(BookingResponseModel.fromJson(mutableTransaction));
      }

      return transactions;
    } catch (e) {
      throw Exception("Failed to fetch transactions from local db: $e");
    }
  }
}
