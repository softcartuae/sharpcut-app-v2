import 'package:dartz/dartz.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/booking/models/rebooking_model.dart';
import 'package:sharp_cut/domain/booking/models/save_booking_request_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_response_model.dart';

abstract class BookingRepo {
  Future<Either<String, String>> bookSlot({
    required int chairId,
    required int userId,
    required String userPassword,
  });

  Future<Either<String, String>> cancelBooking({
    required int transactionId,
    required int userId,
    required String userPassword,
    required String reason,
  });

  Future<Either<String, String>> saveBooking(SaveBookingRequestModel request);

  Future<Either<String, SettlePaymentResponseModel>> settlePayment(
    SettlePaymentRequestModel request,
  );


  Future<Either<String, SettlePaymentResponseModel>> reSettlePayment(
    ResettleModel request,
  );

  Future<Either<String, SettlePaymentResponseModel>> quickPayment(
    SettlePaymentRequestModel request,
  );





}
