import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_response_model.dart';

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

class BookingCancelled extends BookingState {
  final String message;
  BookingCancelled({required this.message});
}

class BookingSaved extends BookingState {
  final String message;
  BookingSaved({required this.message});
}

class BookingPaymentSettled extends BookingState {
  final String message;
  final SettlePaymentResponseModel response;
  BookingPaymentSettled({required this.message, required this.response});
}
