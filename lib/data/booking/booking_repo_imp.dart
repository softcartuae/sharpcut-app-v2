import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';

class BookingRepoImp implements BookingRepo {
  @override
  Future<Either<String, BookingResponseModel>> bookSlot({
    required int chairId,
    required int userId,
    required String userPassword,
  }) async {
    final body = {
      "chair_id": chairId,
      "user_id": userId,
      "user_password": userPassword,
    };

    try {
      final response = await ApiClient.dio.post(
        ApiClient.slotBookingChairApi,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Right(BookingResponseModel.fromJson(data['data']));
        } else {
          return Left(data['message'] ?? 'Booking failed');
        }
      } else {
        return Left('Failed to book slot: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error booking slot: ${e.message}');
    } catch (e) {
      return Left('Error booking slot: $e');
    }
  }
}
