import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/report/report_repo.dart';

abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportSuccess extends ReportState {
  final List<BookingResponseModel> transactions;
  final Map<String, dynamic> activeFilters;
  final bool hasMore;
  final bool isLoadingMore;

  ReportSuccess(
    this.transactions,
    this.activeFilters, {
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  ReportSuccess copyWith({
    List<BookingResponseModel>? transactions,
    Map<String, dynamic>? activeFilters,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ReportSuccess(
      transactions ?? this.transactions,
      activeFilters ?? this.activeFilters,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ReportFailure extends ReportState {
  final String message;

  ReportFailure(this.message);
}

class ReportCubit extends Cubit<ReportState> {
  final ReportRepo _reportRepo;

  ReportCubit(this._reportRepo) : super(ReportInitial());

  int _currentPage = 1;
  static const int _pageSize = 50;
  bool _isFetchingMore = false;

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
    _currentPage = 1;
    _isFetchingMore = false;
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
        limit: _pageSize,
        page: _currentPage,
      );

      final bool hasMore = transactions.length >= _pageSize;
      emit(ReportSuccess(transactions, _currentFilters, hasMore: hasMore));
    } catch (e) {
      emit(ReportFailure(e.toString()));
    }
  }

  void fetchMoreTransactions() async {
    if (state is! ReportSuccess || _isFetchingMore) return;
    final currentState = state as ReportSuccess;
    if (!currentState.hasMore) return;

    _isFetchingMore = true;
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = _currentPage + 1;
      final newTransactions = await _reportRepo.getTransactions(
        userId: _currentFilters['user_id'],
        searchQuery: _currentFilters['search_query'],
        dateRange: _currentFilters['date_range'],
        transactionStatus: _currentFilters['transaction_status'],
        paidStatus: _currentFilters['paid_status'],
        limit: _pageSize,
        page: nextPage,
      );

      _currentPage = nextPage;
      final bool hasMore = newTransactions.length >= _pageSize;
      final updatedList = List<BookingResponseModel>.from(currentState.transactions)
        ..addAll(newTransactions);

      emit(
        ReportSuccess(
          updatedList,
          _currentFilters,
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    } finally {
      _isFetchingMore = false;
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
