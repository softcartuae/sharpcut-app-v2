import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final BookingResponseModel bookingResponse;
  BookingSuccess({required this.bookingResponse});
}

class BookingError extends BookingState {
  final String message;
  BookingError({required this.message});
}

class BookingRestored extends BookingState {}
