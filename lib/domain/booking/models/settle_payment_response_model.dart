import 'package:sharp_cut/utils/helpers/convertion.dart';

class SettlePaymentResponseModel {
  final bool? success;
  final String? message;
  final SettlePaymentData? data;

  SettlePaymentResponseModel({this.success, this.message, this.data});

  factory SettlePaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return SettlePaymentResponseModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? SettlePaymentData.fromJson(json['data'])
          : null,
    );
  }
}

class SettlePaymentData {
  final int? transactionId;
  final String? status;
  final double? totalPaid;
  final double? finalTotal;

  SettlePaymentData({
    this.transactionId,
    this.status,
    this.totalPaid,
    this.finalTotal,
  });

  factory SettlePaymentData.fromJson(Map<String, dynamic> json) {
    return SettlePaymentData(
      transactionId: json['transaction_id'],
      status: json['status'],
      totalPaid: toDouble(json['total_paid']),
      finalTotal: toDouble(json['final_total']),
    );
  }
}
