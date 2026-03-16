import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/booking/models/rebooking_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_response_model.dart';

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
      (bookingResponse) => emit(BookingInitial()),
    );
  }

  void restoreBooking({required BookingResponseModel bookingResponse}) {
    emit(BookingSuccess(bookingResponse: bookingResponse));
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

  // Future<void> saveBooking({required SaveBookingRequestModel request}) async {
  //   // emit(BookingLoading());
  //   final result = await bookingRepo.saveBooking(request);
  //   result.fold(
  //     (error) {
  //       emit(BookingError(message: error));
  //       ToastHelper.showError(error);
  //     },
  //     (message) {
  //       emit(BookingInitial());
  //       ToastHelper.showSuccess(message);
  //     },
  //   );
  // }

  Future<void> quickPayment({
    required SettlePaymentRequestModel request,
  }) async {
    emit(BookingLoading());
    final result = await bookingRepo.quickPayment(request);
    result.fold(
      (error) => emit(BookingError(message: error)),
      (response) => emit(
        BookingPaymentSettled(
          message: response.message ?? 'Payment settled',
          response: response,
        ),
      ),
    );
  }

  Future<bool> reSettlePayment({required ResettleModel resettleModel}) async {
    emit(BookingLoading());

    final result = await bookingRepo.reSettlePayment(resettleModel);

    return result.fold(
      (error) {
        emit(BookingError(message: error));
        return false;
      },
      (response) {
        emit(
          BookingPaymentSettled(
            message: response.message ?? 'Payment settled',
            response: response,
          ),
        );
        return true;
      },
    );
  }

  Future<void> settlePayment({
    required SettlePaymentRequestModel request,
  }) async {
    emit(BookingLoading());
    final result = await bookingRepo.settlePayment(request);
    result.fold(
      (error) => emit(BookingError(message: error)),
      (response) => emit(
        BookingPaymentSettled(
          message: response.message ?? 'Payment settled',
          response: response,
        ),
      ),
    );
  }

  Future<void> updatePaymentMode({
    required int paymentId,
    required String mode,
    required double amount,
  }) async {
    emit(BookingLoading());
    final result = await bookingRepo.updatePaymentMode(
      paymentId: paymentId,
      mode: mode,
      amount: amount,
    );
    result.fold(
      (error) => emit(BookingError(message: error)),
      (message) => emit(
        BookingPaymentSettled(
          message: message,
          response: SettlePaymentResponseModel(success: true, message: message),
        ),
      ),
    );
  }

  Future<void> updateCustomerDetails({
    required BookingResponseModel booking,
    required String customerName,
    required String customerNumber,
  }) async {
    emit(BookingLoading());
    final result = await bookingRepo.updateCustomerDetails(
      transactionId: booking.id!,
      customerName: customerName,
      customerNumber: customerNumber,
    );
    result.fold(
      (error) => emit(BookingError(message: error)),
      (message) => emit(
        BookingPaymentSettled(
          message: message,
          response: SettlePaymentResponseModel(success: true, message: message),
        ),
      ),
    );
  }

  void backToInitialState() {
    emit(BookingInitial());
  }
}
