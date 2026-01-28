import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/utils/helpers/convertion.dart';

class SettlePaymentResponseModel {
  final bool? success;
  final String? message;
  final BookingResponseModel? bookingResponse;

  SettlePaymentResponseModel({
    this.success,
    this.message,
    this.bookingResponse,
  });

  factory SettlePaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return SettlePaymentResponseModel(
      success: json['success'],
      message: json['message'],
      
      bookingResponse: json['data'] != null
          ? BookingResponseModel.fromJson(json['data'])
          : null,
    );
  }
}


