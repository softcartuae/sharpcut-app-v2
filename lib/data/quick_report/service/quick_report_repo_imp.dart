import 'package:dio/dio.dart';
import 'package:sharp_cut/data/quick_report/service/quick_report_service.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';
import 'package:sharp_cut/domain/quick_report/service/quick_report_repo.dart';

class QuickReportRepoImp implements QuickReportRepo {
  final QuickReportService _quickReportService;

  QuickReportRepoImp(this._quickReportService);

  @override
  Future<QuickReportModel> getQuickReport({
    String? dateRange,
    int? userId,
  }) async {
    try {
      final response = await _quickReportService.getQuickReport(
        dateRange: dateRange,
        userId: userId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data["data"];
        return QuickReportModel.fromJson(data);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
