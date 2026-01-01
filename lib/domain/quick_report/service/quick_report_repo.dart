import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';

abstract class QuickReportRepo {
  Future<QuickReportModel> getQuickReport({String? dateRange, int? userId});
}
