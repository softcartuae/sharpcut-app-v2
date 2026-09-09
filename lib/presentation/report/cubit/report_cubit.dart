import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/report/report_repo.dart';

abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportSuccess extends ReportState {
  final List<BookingResponseModel> transactions;
  final Map<String, dynamic> activeFilters;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool isLoadingMore;

  ReportSuccess({
    required this.transactions,
    required this.activeFilters,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.isLoadingMore = false,
  });

  bool get hasMore => currentPage < lastPage;

  ReportSuccess copyWith({
    List<BookingResponseModel>? transactions,
    Map<String, dynamic>? activeFilters,
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    bool? isLoadingMore,
  }) {
    return ReportSuccess(
      transactions: transactions ?? this.transactions,
      activeFilters: activeFilters ?? this.activeFilters,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
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
  final int _perPage = 15;

  int get currentPage => _currentPage;
  int get perPage => _perPage;

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
      final response = await _reportRepo.getTransactions(
        userId: _currentFilters['user_id'],
        searchQuery: _currentFilters['search_query'],
        dateRange: _currentFilters['date_range'],
        transactionStatus: _currentFilters['transaction_status'],
        paidStatus: _currentFilters['paid_status'],
        page: _currentPage,
        perPage: _perPage,
      );

      emit(ReportSuccess(
        transactions: response.transactions,
        activeFilters: _currentFilters,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        perPage: response.perPage,
        total: response.total,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(ReportFailure(e.toString()));
    }
  }

  void fetchMoreTransactions() async {
    if (state is! ReportSuccess) return;
    final currentState = state as ReportSuccess;

    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = _currentPage + 1;

    try {
      final response = await _reportRepo.getTransactions(
        userId: _currentFilters['user_id'],
        searchQuery: _currentFilters['search_query'],
        dateRange: _currentFilters['date_range'],
        transactionStatus: _currentFilters['transaction_status'],
        paidStatus: _currentFilters['paid_status'],
        page: nextPage,
        perPage: _perPage,
      );

      _currentPage = response.currentPage;

      emit(ReportSuccess(
        transactions: [...currentState.transactions, ...response.transactions],
        activeFilters: _currentFilters,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        perPage: response.perPage,
        total: response.total,
        isLoadingMore: false,
      ));
    } catch (e) {
      // Revert loading state on failure
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  void updateFilter(String key, dynamic value) {
    _currentFilters[key] = value;
    _currentPage = 1;
  }

  void resetFilters() {
    _currentFilters = {
      'user_id': null,
      'search_query': '',
      'date_range': '',
      'transaction_status': 'All',
      'paid_status': 'All',
    };
    _currentPage = 1;
  }
}
