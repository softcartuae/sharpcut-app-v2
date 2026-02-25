import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/quick_report/quick_report_state.dart';
import 'package:sharp_cut/domain/quick_report/service/quick_report_repo.dart';

class QuickReportCubit extends Cubit<QuickReportState> {
  final QuickReportRepo _quickReportRepo;

  QuickReportCubit(this._quickReportRepo) : super(QuickReportInitial());

  Future<void> fetchQuickReport({String? dateRange, int? userId}) async {
    emit(QuickReportLoading());
    try {
      final result = await _quickReportRepo.getQuickReport(
        dateRange: dateRange,
        userId: userId,
      );
      result.fold(
        (error) => emit(QuickReportError(error)),
        (report) => emit(QuickReportLoaded(report)),
      );
    } catch (e) {
      emit(QuickReportError(e.toString()));
    }
  }
}
