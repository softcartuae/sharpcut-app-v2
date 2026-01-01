import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/quick_report/quick_report_state.dart';
import 'package:sharp_cut/domain/quick_report/service/quick_report_repo.dart';

class QuickReportCubit extends Cubit<QuickReportState> {
  final QuickReportRepo _quickReportRepo;

  QuickReportCubit(this._quickReportRepo) : super(QuickReportInitial());

  Future<void> fetchQuickReport({String? dateRange, int? userId}) async {
    emit(QuickReportLoading());
    try {
      final report = await _quickReportRepo.getQuickReport(
        dateRange: dateRange,
        userId: userId,
      );
      emit(QuickReportLoaded(report));
    } catch (e) {
      emit(QuickReportError(e.toString()));
    }
  }
}
