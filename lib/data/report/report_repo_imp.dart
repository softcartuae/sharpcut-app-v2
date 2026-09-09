import 'package:dio/dio.dart';
import 'package:sharp_cut/data/report/service/report_service.dart';
import 'package:sharp_cut/domain/report/models/report_paginated_response.dart';
import 'package:sharp_cut/domain/report/report_repo.dart';

class ReportRepoImp implements ReportRepo {
  final ReportService _reportService;

  ReportRepoImp(this._reportService);

  @override
  Future<ReportPaginatedResponse> getTransactions({
    int? userId,
    String? searchQuery,
    String? dateRange,
    String? transactionStatus,
    String? paidStatus,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _reportService.getTransactions(
        userId: userId,
        searchQuery: searchQuery,
        dateRange: dateRange,
        transactionStatus: transactionStatus,
        paidStatus: paidStatus,
        page: page,
        perPage: perPage,
      );

      if (response.data['success'] == true) {
        return ReportPaginatedResponse.fromJson(response.data);
      } else {
        throw Exception("Failed to fetch transactions");
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
