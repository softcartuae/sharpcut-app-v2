import 'package:equatable/equatable.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';

abstract class QuickReportState extends Equatable {
  const QuickReportState();

  @override
  List<Object> get props => [];
}

class QuickReportInitial extends QuickReportState {}

class QuickReportLoading extends QuickReportState {}

class QuickReportLoaded extends QuickReportState {
  final QuickReportModel report;

  const QuickReportLoaded(this.report);

  @override
  List<Object> get props => [report];
}

class QuickReportError extends QuickReportState {
  final String message;

  const QuickReportError(this.message);

  @override
  List<Object> get props => [message];
}
