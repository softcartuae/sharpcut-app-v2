import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/online_booking/online_booking_state.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';
import 'package:sharp_cut/domain/booking/models/online_booking_model.dart';

class OnlineBookingCubit extends Cubit<OnlineBookingState> {
  final BookingRepo bookingRepo;
  int _currentPage = 1;
  final int _perPage = 15;
  String? _phoneNumber;
  String? _date;
  String? _status;
  List<OnlineBookingModel> _allBookings = [];

  OnlineBookingCubit({required this.bookingRepo})
      : super(OnlineBookingInitial());

  String? get currentDateFilter => _date;
  String? get currentStatusFilter => _status;

  Future<void> fetchOnlineBookings({
    int page = 1,
    bool isRefresh = true,
    String? phoneNumber,
    String? date,
    bool clearDate = false,
    String? status,
    bool clearStatus = false,
  }) async {
    if (phoneNumber != null) {
      _phoneNumber = phoneNumber.trim().isEmpty ? null : phoneNumber;
    }

    if (clearDate) {
      _date = null;
    } else if (date != null) {
      _date = (date.trim().isEmpty || date.trim().toLowerCase() == 'all')
          ? null
          : date;
    }

    if (clearStatus) {
      _status = null;
    } else if (status != null) {
      _status = (status.trim().isEmpty || status.trim().toLowerCase() == 'all')
          ? null
          : status;
    }

    if (isRefresh) {
      _currentPage = 1;
      if (state is OnlineBookingLoaded &&
          (state as OnlineBookingLoaded).bookings.isNotEmpty) {
        // Keep current loaded list visible while refreshing in background
        emit((state as OnlineBookingLoaded).copyWith(isRefreshing: true));
      } else {
        // First load or empty: emit full loading shimmer state
        _allBookings = [];
        emit(OnlineBookingLoading());
      }
    }

    final result = await bookingRepo.getOnlineBookings(
      page: page,
      perPage: _perPage,
      phoneNumber: _phoneNumber,
      date: _date,
      status: _status,
    );

    result.fold(
      (error) {
        if (state is OnlineBookingLoaded) {
          emit((state as OnlineBookingLoaded).copyWith(isRefreshing: false));
        } else {
          emit(OnlineBookingError(message: error));
        }
      },
      (newBookings) {
        if (isRefresh) {
          _allBookings = newBookings;
        } else {
          _allBookings.addAll(newBookings);
        }
        _currentPage = page;
        emit(
          OnlineBookingLoaded(
            bookings: List.from(_allBookings),
            page: _currentPage,
            hasMore: newBookings.length >= _perPage,
            isRefreshing: false,
          ),
        );
      },
    );
  }

  Future<void> loadMoreOnlineBookings() async {
    if (state is OnlineBookingLoaded) {
      final currentState = state as OnlineBookingLoaded;
      if (!currentState.hasMore || currentState.isRefreshing) return;
      await fetchOnlineBookings(
        page: _currentPage + 1,
        isRefresh: false,
        phoneNumber: _phoneNumber,
        date: _date,
        status: _status,
      );
    }
  }
}
