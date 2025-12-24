import 'package:dartz/dartz.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';

abstract class BookingRepo {
  Future<Either<String, BookingResponseModel>> bookSlot({
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
}
