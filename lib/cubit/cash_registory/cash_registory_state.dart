import 'package:sharp_cut/domain/cash_registory/models/close_register_model.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_response.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';

abstract class CashRegistoryState {}

class CashRegistoryInitial extends CashRegistoryState {}

class CashRegistoryLoading extends CashRegistoryState {}

class CashRegistoryAddSuccess extends CashRegistoryState {
  final String message;
  CashRegistoryAddSuccess(this.message);
}

class CashRegistorOpen extends CashRegistoryState {
  final String message;
  CashRegistorOpen(this.message);
}

class CashRegistorClosed extends CashRegistoryState {
  final String message;
  CashRegistorClosed(this.message);
}

class CashRegistoryAddError extends CashRegistoryState {
  final String message;
  CashRegistoryAddError(this.message);
}

class CashRegistorySalesTotalLoaded extends CashRegistoryState {
  final CloseRegisterModel closeRegisterModel;
  CashRegistorySalesTotalLoaded(this.closeRegisterModel);
}

class CashRegistoryCloseSuccess extends CashRegistoryState {
  final CloseRegisterResponse response;
  CashRegistoryCloseSuccess(this.response);
}

class CashRegistoryReportLoaded extends CashRegistoryState {
  final CloseRegisterReportModel report;
  CashRegistoryReportLoaded(this.report);
}
