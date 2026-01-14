import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/report/report_repo.dart';

abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportSuccess extends ReportState {
  final List<BookingResponseModel> transactions;
  final Map<String, dynamic> activeFilters;

  ReportSuccess(this.transactions, this.activeFilters);
}

class ReportFailure extends ReportState {
  final String message;

  ReportFailure(this.message);
}

class ReportCubit extends Cubit<ReportState> {
  final ReportRepo _reportRepo;

  ReportCubit(this._reportRepo) : super(ReportInitial());

  Map<String, dynamic> _currentFilters = {
    'user_id': null,
    'search_query': '',
    'date_range': '',
    'transaction_status': 'All',
    'paid_status': 'All',
  };

  void fetchTransactions({
    int? userId,
    String? searchQuery,
    String? dateRange,
    String? transactionStatus,
    String? paidStatus,
  }) async {
    emit(ReportLoading());

    // Update local filters if provided
    if (userId != null) _currentFilters['user_id'] = userId;
    if (searchQuery != null) _currentFilters['search_query'] = searchQuery;
    if (dateRange != null) _currentFilters['date_range'] = dateRange;
    if (transactionStatus != null) {
      _currentFilters['transaction_status'] = transactionStatus;
    }
    if (paidStatus != null) _currentFilters['paid_status'] = paidStatus;

    try {
      final transactions = await _reportRepo.getTransactions(
        userId: _currentFilters['user_id'],
        searchQuery: _currentFilters['search_query'],
        dateRange: _currentFilters['date_range'],
        transactionStatus: _currentFilters['transaction_status'],
        paidStatus: _currentFilters['paid_status'],
      );
      emit(ReportSuccess(transactions, _currentFilters));
    } catch (e) {
      emit(ReportFailure(e.toString()));
    }
  }

  void updateFilter(String key, dynamic value) {
    _currentFilters[key] = value;
  }

  void resetFilters() {
    _currentFilters = {
      'user_id': null,
      'search_query': '',
      'date_range': '',
      'transaction_status': 'All',
      'paid_status': 'All',
    };
    
  }
}
