import 'package:sharp_cut/domain/booking/models/online_booking_model.dart';

abstract class OnlineBookingState {}

class OnlineBookingInitial extends OnlineBookingState {}

class OnlineBookingLoading extends OnlineBookingState {}

class OnlineBookingLoaded extends OnlineBookingState {
  final List<OnlineBookingModel> bookings;
  final int page;
  final bool hasMore;

  OnlineBookingLoaded({
    required this.bookings,
    this.page = 1,
    this.hasMore = true,
  });
}

class OnlineBookingError extends OnlineBookingState {
  final String message;
  OnlineBookingError({required this.message});
}
