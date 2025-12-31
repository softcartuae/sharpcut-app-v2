import 'package:sharp_cut/domain/home/models/service_model.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';

class BookingResponseModel {
  final int? id;
  final String? appId;
  final int? chairId;
  final int? userId;
  final String? customerName;
  final String? customerNumber;
  final String? transactionDate;
  final String? invoiceNo;
  final String? invoiceDate;
  final String? status;
  final String? createdAt;
  final StaffModel? staff;
  final List<BookingDetail>? details;
  final String? grandTotal;
  final String? taxTotal;
  final String? finalTotal;
  final String? paymentStatus;
  final num? totalPayment;
  final List<PaymentModel>? payments;

  BookingResponseModel({
    this.id,
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
    this.grandTotal,
    this.taxTotal,
    this.finalTotal,
    this.paymentStatus,
    this.totalPayment,
    this.payments,
  });

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingResponseModel(
      id: json['id'],
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
      grandTotal: json['grand_total'],
      taxTotal: json['tax_total'],
      finalTotal: json['final_total'],
      paymentStatus: json['payment_status'],
      totalPayment: json['total_payment'],
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
  final String? rate;
  final String? amountTotal;

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
      rate: json['rate'],
      amountTotal: json['amount_total'],
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
    );
  }
}

class PaymentModel {
  final int? id;
  final String? mode;
  final String? amount;
  final String? date;

  PaymentModel({this.id, this.mode, this.amount, this.date});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      mode: json['mode'],
      amount: json['amount'],
      date: json['date'],
    );
  }
}
