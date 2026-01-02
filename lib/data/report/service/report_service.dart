import 'package:dio/dio.dart';
import 'package:sharp_cut/data/api_client.dart';

class ReportService {
  ReportService();

  Future<Response> getTransactions({
    int? userId,
    String? searchQuery,
    String? dateRange,
    String? transactionStatus,
    String? paidStatus,
  }) async {
    final Map<String, dynamic> queryParams = {};

    if (userId != null) queryParams['user_id'] = userId;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['search_query'] = searchQuery;
    }
    if (dateRange != null && dateRange.isNotEmpty) {
      queryParams['date_range'] = dateRange;
    }
    if (transactionStatus != null &&
        transactionStatus.isNotEmpty &&
        transactionStatus != 'All') {
      queryParams['transaction_status'] = transactionStatus.toLowerCase();
    }
    if (paidStatus != null && paidStatus.isNotEmpty && paidStatus != 'All') {
      queryParams['paid_status'] = paidStatus.toLowerCase();
    }

    return await ApiClient.dio.get(
      '/api/transactions/search',
      queryParameters: queryParams,
    );
  }
}
