import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/utils/helpers/convertion.dart';

import 'booking_detail_model.dart';
import 'customer_booking_service_model.dart';
import 'customer_model.dart';
import 'payment_model.dart';

export 'booking_detail_model.dart';
export 'customer_booking_service_model.dart';
export 'customer_model.dart';
export 'payment_model.dart';

class BookingResponseModel {
  final int? id;
  final int? onlineBookingId;
  final String? appId;
  final int? chairId;
  final int? userId;
  final String? customerName;
  final String? customerNumber;
  final CustomerModel? customer;
  final String? transactionDate;
  final String? invoiceNo;
  final String? invoiceDate;
  final String? status;
  final double? discount;
  final String? createdAt;
  final StaffModel? staff;
  final List<BookingDetail>? details;
  final List<CustomerBookingService>? customerBookingServices;
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
    this.customer,
    this.transactionDate,
    this.invoiceNo,
    this.invoiceDate,
    this.status,
    this.createdAt,
    this.staff,
    this.details,
    this.customerBookingServices,
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

     var json1 = {
  "id": 101,
  "online_booking_id": 25,
  "app_id": 1001,
  "chair_id": 1,
  "user_id": 10,
  "customer_name": "John Doe",
  "customer_number": "+971501234567",
  "customer": {
    "id": 5,
    "firebase_uid": "uid_abc123",
    "phone_number": "+971501111111",
    "name": "John Doe",
    "email": "[EMAIL_ADDRESS]",
    "gender": "male",
    "wallet": 250.00,
    "discount": null,
    "valid_up_to": null,
    "address": "Dubai, UAE"
  },
  "transaction_date": "2026-09-07 18:00:00",
  "invoice_no": "INV-2026-0056",
  "invoice_date": "2026-09-07",
  "status": "completed",
  "discount": 0.00,
  "created_at": "2026-09-07T18:30:00.000000Z",
  "user": {
    "id": 10,
    "shop_id": 1001,
    "first_name": "Alice",
    "last_name": "Smith",
    "email": "[EMAIL_ADDRESS]",
    "phone": "+971509876543",
    "status": 1,
    "profile_pic": "https://example.com/images/alice.jpg"
  },
  "details": [
    {
      "id": 201,
      "service": {
        "id": 3,
        "name": "Men's Haircut",
        "image": "https://example.com/images/haircut.jpg",
        "duration": 45,
        "price": 120.00
      },
      "quantity": 1,
      "rate": 120.00,
      "amount_total": 120.00
    }
  ],
  "customer_booking_services": [
    {
      "id": 401,
      "customer_booking_id": 101,
      "service_id": 3,
      "name": "Men's Haircut",
      "quantity": 1,
      "rate": 120.00,
      "before_vat": 120.00,
      "tax_percentage": 5.0,
      "unit_tax": 6.00,
      "created_at": "2026-09-07T18:30:00.000000Z",
      "updated_at": "2026-09-07T18:30:00.000000Z"
    }
  ],
  "grand_total": 120.00,
  "tax_total": 6.00,
  "final_total": 126.00,
  "total_payment": 126.00,
  "payment_status": "paid",
  "end_time": "2026-09-07 18:45:00",
  "payments": [
    {
      "id": 301,
      "mode": "cash",
      "amount": 126.00,
      "date": "2026-09-07"
    }
  ]
};


 
    return BookingResponseModel(
      id: json['id'],
      onlineBookingId: json['online_booking_id'],
      staff: json['user'] != null ? StaffModel.fromJson(json['user']) : null,
      appId: json['app_id'],
      chairId: json['chair_id'],
      userId: json['user_id'],
      customerName: json['customer_name'],
      customerNumber: json['customer_number'],
      customer: json1['customer'] != null
          ? CustomerModel.fromJson(json1['customer'] as Map<String, dynamic>)
          : null,
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
      customerBookingServices: json['customer_booking_services'] != null
          ? (json['customer_booking_services'] as List)
                .map((e) => CustomerBookingService.fromJson(e))
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
