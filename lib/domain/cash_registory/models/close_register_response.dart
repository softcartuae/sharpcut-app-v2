import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';

class CloseRegisterResponse {
  final String message;
  final CloseRegisterReportModel? report;

  CloseRegisterResponse({required this.message, this.report});
}
