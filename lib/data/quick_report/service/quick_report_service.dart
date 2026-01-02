import 'package:dio/dio.dart';
import 'package:sharp_cut/data/api_client.dart';

class QuickReportService {
  QuickReportService();

  Future<Response> getQuickReport({String? dateRange, int? userId}) async {
    final Map<String, dynamic> queryParams = {};
    if (dateRange != null && dateRange.isNotEmpty) {
      queryParams['date_range'] = dateRange;
    }
    if (userId != null) {
      queryParams['user_id'] = userId;
    }

    return await ApiClient.dio.get(
      ApiClient.quickReportapi,
      queryParameters: queryParams,
    );
  }
}
