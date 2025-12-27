import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/booking/models/save_booking_request_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_response_model.dart';

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

  @override
  Future<Either<String, String>> cancelBooking({
    required int transactionId,
    required int userId,
    required String userPassword,
    required String reason,
  }) async {
    final body = {
      "transaction_id": transactionId,
      "user_id": userId,
      "user_password": userPassword,
      "cancellation_reason": reason,
    };

    try {
      final response = await ApiClient.dio.post(
        ApiClient.cancelBookingApi,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Right(data['message'] ?? 'Transaction cancelled successfully');
        } else {
          return Left(data['message'] ?? 'Cancellation failed');
        }
      } else {
        return Left('Failed to cancel booking: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error cancelling booking: ${e.message}');
    } catch (e) {
      return Left('Error cancelling booking: $e');
    }
  }

  @override
  Future<Either<String, String>> saveBooking(
    SaveBookingRequestModel request,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.saveBookingApi,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Right(data['message'] ?? 'Booking saved successfully');
        } else {
          return Left(data['message'] ?? 'Failed to save booking');
        }
      } else {
        return Left('Failed to save booking: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error saving booking: ${e.message}');
    } catch (e) {
      return Left('Error saving booking: $e');
    }
  }

  @override
  Future<Either<String, SettlePaymentResponseModel>> settlePayment(
    SettlePaymentRequestModel request,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.settlePayment,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Right(SettlePaymentResponseModel.fromJson(data));
        } else {
          return Left(data['message'] ?? 'Payment settlement failed');
        }
      } else {
        return Left('Failed to settle payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error settling payment: ${e.message}');
    } catch (e) {
      return Left('Error settling payment: $e');
    }
  }

  @override
  Future<Either<String, SettlePaymentResponseModel>> quickPayment(
    SettlePaymentRequestModel request,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.quickPayment,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Right(SettlePaymentResponseModel.fromJson(data));
        } else {
          return Left(data['message'] ?? 'Payment settlement failed');
        }
      } else {
        return Left('Failed to settle payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error settling payment: ${e.message}');
    } catch (e) {
      return Left('Error settling payment: $e');
    }
  }



}
