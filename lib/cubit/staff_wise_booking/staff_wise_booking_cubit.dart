import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/staff_wise_booking/staff_wise_booking_state.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';
import 'package:sharp_cut/domain/booking/models/staff_wise_booking_model.dart';

class StaffWiseBookingCubit extends Cubit<StaffWiseBookingState> {
  final BookingRepo bookingRepo;
  int _currentPage = 1;
  final int _perPage = 10;
  String? _date;
  String? _status;
  String? _search;
  List<StaffWiseBookingModel> _allStaffBookings = [];

  StaffWiseBookingCubit({required this.bookingRepo})
      : super(StaffWiseBookingInitial());

  String? get currentDateFilter => _date;
  String? get currentStatusFilter => _status;
  String? get currentSearchQuery => _search;

  Future<void> fetchStaffWiseBookings({
    int page = 1,
    bool isRefresh = true,
    String? date,
    bool clearDate = false,
    String? status,
    bool clearStatus = false,
    String? search,
    bool clearSearch = false,
  }) async {
    if (clearDate) {
      _date = null;
    } else if (date != null) {
      _date = date;
    }

    if (clearStatus) {
      _status = null;
    } else if (status != null) {
      _status = status;
    }

    if (clearSearch) {
      _search = null;
    } else if (search != null) {
      _search = search;
    }

    if (isRefresh) {
      _currentPage = 1;
      if (state is StaffWiseBookingLoaded &&
          (state as StaffWiseBookingLoaded).staffWiseBookings.isNotEmpty) {
        emit((state as StaffWiseBookingLoaded).copyWith(isRefreshing: true));
      } else {
        _allStaffBookings = [];
        emit(StaffWiseBookingLoading());
      }
    }

    final result = await bookingRepo.getStaffWiseOnlineBookings(
      page: page,
      perPage: _perPage,
      date: _date,
      status: _status,
      search: _search,
    );

    result.fold(
      (error) {
        if (state is StaffWiseBookingLoaded) {
          emit((state as StaffWiseBookingLoaded).copyWith(isRefreshing: false));
        } else {
          emit(StaffWiseBookingError(message: error));
        }
      },
      (responseModel) {
        final newStaffList = responseModel.data ?? [];
        if (isRefresh) {
          _allStaffBookings = newStaffList;
        } else {
          _allStaffBookings.addAll(newStaffList);
        }
        _currentPage = page;

        final hasMore = (responseModel.currentPage ?? 1) <
            (responseModel.lastPage ?? 1);

        emit(
          StaffWiseBookingLoaded(
            staffWiseBookings: List.from(_allStaffBookings),
            page: _currentPage,
            hasMore: hasMore,
            isRefreshing: false,
            totalBookings: responseModel.totalBookings ?? 0,
            totalStaff: responseModel.total ?? _allStaffBookings.length,
            date: _date,
            status: _status,
            search: _search,
          ),
        );
      },
    );
  }

  Future<void> loadMoreStaffWiseBookings() async {
    if (state is StaffWiseBookingLoaded) {
      final currentState = state as StaffWiseBookingLoaded;
      if (!currentState.hasMore || currentState.isRefreshing) return;
      await fetchStaffWiseBookings(
        page: _currentPage + 1,
        isRefresh: false,
      );
    }
  }
}
