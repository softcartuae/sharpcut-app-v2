import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/booking/models/save_booking_request_model.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepo bookingRepo;

  BookingCubit({required this.bookingRepo}) : super(BookingInitial());

  Future<void> bookSlot({
    required int chairId,
    required int userId,
    required String userPassword,
  }) async {
    emit(BookingLoading());
    final result = await bookingRepo.bookSlot(
      chairId: chairId,
      userId: userId,
      userPassword: userPassword,
    );
    result.fold(
      (error) => emit(BookingError(message: error)),
      (bookingResponse) =>
          emit(BookingSuccess(bookingResponse: bookingResponse)),
    );
  }

  void restoreBooking({required BookingResponseModel bookingResponse}) {
    emit(BookingRestored(bookingResponse: bookingResponse));
  }

  Future<void> cancelBooking({
    required int transactionId,
    required int userId,
    required String userPassword,
    required String reason,
  }) async {
    emit(BookingLoading());
    final result = await bookingRepo.cancelBooking(
      transactionId: transactionId,
      userId: userId,
      userPassword: userPassword,
      reason: reason,
    );
    result.fold(
      (error) => emit(BookingError(message: error)),
      (message) => emit(BookingCancelled(message: message)),
    );
  }

  Future<void> saveBooking({required SaveBookingRequestModel request}) async {
    return;
    emit(BookingLoading());
    final result = await bookingRepo.saveBooking(request);
    result.fold(
      (error) => emit(BookingError(message: error)),
      (message) => emit(BookingSaved(message: message)),
    );
  }
}
