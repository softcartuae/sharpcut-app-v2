import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/booking/models/online_booking_model.dart';
import 'package:sharp_cut/domain/booking/models/rebooking_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_response_model.dart';
import 'package:sharp_cut/domain/booking/models/customer_suggestion_model.dart';

class BookingRepoImp implements BookingRepo {
  @override
  Future<Either<String, String>> bookSlot({
    required int chairId,
    required int userId,
    required String userPassword,
    int? onlineBookingId,
  }) async {
    final body = <String, dynamic>{
      "chair_id": chairId,
      "user_id": userId,
      "user_password": userPassword,
      "mode" : onlineBookingId != null ? "app" : "shop",
      "online_booking_id": onlineBookingId,
    };

    try {
      final response = await ApiClient.dio.post(
        ApiClient.slotBookingChairApi,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Right("Booking successful");
        } else {
          return Left(data['message'] ?? 'Booking failed');
        }
      } else {
        return Left('Failed to book slot: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return Left(e.response!.data['message']);
      }

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

  @override
  Future<Either<String, SettlePaymentResponseModel>> reSettlePayment(
    ResettleModel request,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.reSettlementPayment,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          final transactiondata = data["data"];
          return Right(SettlePaymentResponseModel.fromJson(transactiondata));
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
  Future<Either<String, String>> updatePaymentMode({
    required int paymentId,
    required String mode,
    required double amount,
  }) async {
    try {
      await ApiClient.dio.post(
        "${ApiClient.updatePaymentMode}/$paymentId/update-mode",
        data: {"mode": mode, "amount": amount},
      );
      return const Right("Payment updated successfully");
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error updating payment: ${e.message}');
    } catch (e) {
      return Left('Error updating payment: $e');
    }
  }

  @override
  Future<Either<String, String>> updateCustomerDetails({
    required int transactionId,
    required String customerName,
    required String customerNumber,
  }) async {
    try {
      final body = {
        'customer_name': customerName,
        'customer_number': customerNumber,
      };
      await ApiClient.dio.post(
        "${ApiClient.transactionsPOSTapi}/$transactionId/update-customer",
        data: body,
      );
      return const Right("Customer details updated successfully");
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error updating customer details: ${e.message}');
    } catch (e) {
      return Left('Error updating customer details: $e');
    }
  }

  @override
  Future<Either<String, List<CustomerSuggestionModel>>> searchCustomer({
    String? name,
    String? number,
  }) async {
    try {
      final body = name != null
          ? {'customer_name': name}
          : {'customer_number': number};

      final response = await ApiClient.dio.post(
        ApiClient.searchCustomerApi,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          final List suggestions = data['data'];
          return Right(
            suggestions
                .map((e) => CustomerSuggestionModel.fromJson(e))
                .toList(),
          );
        } else {
          return Left(data['message'] ?? 'Search failed');
        }
      } else {
        return Left('Failed to search: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error searching: ${e.message}');
    } catch (e) {
      return Left('Error searching: $e');
    }
  }

  @override
  Future<Either<String, List<OnlineBookingModel>>> getOnlineBookings({
    int page = 1,
    int perPage = 10,
    String? phoneNumber,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        queryParams['phone_number'] = phoneNumber.trim();
      }

      final response = await ApiClient.dio.get(
        ApiClient.bookingsPostApi,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List list = data['data'];
          final bookings =
              list.map((e) => OnlineBookingModel.fromJson(e)).toList();
          return Right(bookings);
        } else {
          return Left(data['message'] ?? 'Failed to fetch online bookings');
        }
      } else {
        return Left('Failed to fetch online bookings: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error fetching online bookings: ${e.message}');
    } catch (e) {
      return Left('Error fetching online bookings: $e');
    }
  }
}

