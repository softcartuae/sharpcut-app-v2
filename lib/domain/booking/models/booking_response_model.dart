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
      details: json['details'] != null
          ? (json['details'] as List)
                .map((e) => BookingDetail.fromJson(e))
                .toList()
          : null,
    );
  }
}

class BookingDetail {
  final int? id;

  final ServiceModel? service;

  BookingDetail({this.id, this.service});

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      id: json['id'],

      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
    );
  }
}
