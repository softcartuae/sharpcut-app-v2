import 'package:sharp_cut/domain/home/models/service_model.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/utils/helpers/convertion.dart';

class BookingResponseModel {
  final int? id;
  final int? onlineBookingId;
  final String? appId;
  final int? chairId;
  final int? userId;
  final String? customerName;
  final String? customerNumber;
  final String? transactionDate;
  final String? invoiceNo;
  final String? invoiceDate;
  final String? status;
  final double? discount;
  final String? createdAt;
  final StaffModel? staff;
  final List<BookingDetail>? details;
  final double? subtotal;
  final double? taxTotal;
  final double? finalTotal;
  final double? finalTotalbefore;
  final String? paymentStatus;
  final double? totalPayment;
  final String? endTime;
  final List<PaymentModel>? payments;

  BookingResponseModel({
    this.id,
    this.onlineBookingId,
    this.appId,
    this.chairId,
    this.userId,
    this.customerName,
    this.customerNumber,
    this.transactionDate,
    this.invoiceNo,
    this.invoiceDate,
    this.status,
    this.createdAt,
    this.staff,
    this.details,
    this.subtotal,
    this.taxTotal,
    this.finalTotal,
    this.paymentStatus,
    this.totalPayment,
    this.payments,
    this.discount,
    this.endTime,
    this.finalTotalbefore,
  });

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingResponseModel(
      id: json['id'],
      onlineBookingId: json['online_booking_id'],
      staff: json['user'] != null ? StaffModel.fromJson(json['user']) : null,
      appId: json['app_id'],
      chairId: json['chair_id'],
      userId: json['user_id'],
      customerName: json['customer_name'],
      customerNumber: json['customer_number'],
      transactionDate: json['transaction_date'],
      invoiceNo: json['invoice_no'],
      invoiceDate: json['invoice_date'],
      status: json['status'],
      createdAt: json['created_at'],
      subtotal: toDouble(json['grand_total']),
      taxTotal: toDouble(json['tax_total']),
      finalTotal: toDouble(json['final_total']),
      discount: toDouble(json['discount']),
      paymentStatus: json['payment_status'],
      totalPayment: toDouble(json['total_payment']),
      endTime: json['end_time'],
      finalTotalbefore: toDouble(json['final_total_before']),
      details: json['details'] != null
          ? (json['details'] as List)
                .map((e) => BookingDetail.fromJson(e))
                .toList()
          : null,
      payments: json['payments'] != null
          ? (json['payments'] as List)
                .map((e) => PaymentModel.fromJson(e))
                .toList()
          : null,
    );
  }
}

class BookingDetail {
  final int? id;
  final ServiceModel? service;
  final int? quantity;
  final double? rate;
  final double? amountTotal;

  BookingDetail({
    this.id,
    this.service,
    this.quantity,
    this.rate,
    this.amountTotal,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      id: json['id'],
      quantity: json['quantity'],
      rate: toDouble(json['rate']),
      amountTotal: toDouble(json['amount_total']),
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
    );
  }
}

class PaymentModel {
  final int? id;
  final String? mode;
  final double? amount;
  final String? date;

  PaymentModel({this.id, this.mode, this.amount, this.date});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      mode: json['mode'],
      amount: toDouble(json['amount']),
      date: json['date'],
    );
  }
}
