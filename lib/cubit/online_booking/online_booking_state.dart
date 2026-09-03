import 'package:sharp_cut/domain/booking/models/online_booking_model.dart';

abstract class OnlineBookingState {}

class OnlineBookingInitial extends OnlineBookingState {}

class OnlineBookingLoading extends OnlineBookingState {}

class OnlineBookingLoaded extends OnlineBookingState {
  final List<OnlineBookingModel> bookings;
  final int page;
  final bool hasMore;
  final bool isRefreshing;

  OnlineBookingLoaded({
    required this.bookings,
    this.page = 1,
    this.hasMore = true,
    this.isRefreshing = false,
  });

  OnlineBookingLoaded copyWith({
    List<OnlineBookingModel>? bookings,
    int? page,
    bool? hasMore,
    bool? isRefreshing,
  }) {
    return OnlineBookingLoaded(
      bookings: bookings ?? this.bookings,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class OnlineBookingError extends OnlineBookingState {
  final String message;
  OnlineBookingError({required this.message});
}
