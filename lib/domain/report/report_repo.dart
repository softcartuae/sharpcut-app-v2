import 'package:sharp_cut/domain/report/models/report_paginated_response.dart';

abstract class ReportRepo {
  Future<ReportPaginatedResponse> getTransactions({
    int? userId,
    String? searchQuery,
    String? dateRange,
    String? transactionStatus,
    String? paidStatus,
    int page = 1,
    int perPage = 15,
  });
}
