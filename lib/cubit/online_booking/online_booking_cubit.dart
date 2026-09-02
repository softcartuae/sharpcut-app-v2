import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/online_booking/online_booking_state.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';
import 'package:sharp_cut/domain/booking/models/online_booking_model.dart';

class OnlineBookingCubit extends Cubit<OnlineBookingState> {
  final BookingRepo bookingRepo;
  int _currentPage = 1;
  final int _perPage = 15;
  List<OnlineBookingModel> _allBookings = [];

  OnlineBookingCubit({required this.bookingRepo})
      : super(OnlineBookingInitial());

  Future<void> fetchOnlineBookings({int page = 1, bool isRefresh = true}) async {
    if (isRefresh) {
      _currentPage = 1;
      _allBookings = [];
      emit(OnlineBookingLoading());
    }

    final result = await bookingRepo.getOnlineBookings(
      page: page,
      perPage: _perPage,
    );

    result.fold(
      (error) => emit(OnlineBookingError(message: error)),
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
          ),
        );
      },
    );
  }

  Future<void> loadMoreOnlineBookings() async {
    if (state is OnlineBookingLoaded) {
      final currentState = state as OnlineBookingLoaded;
      if (!currentState.hasMore) return;
      await fetchOnlineBookings(page: _currentPage + 1, isRefresh: false);
    }
  }
  

}
