import 'package:sharp_cut/utils/helpers/convertion.dart';

class OnlineBookingResponseModel {
  final bool? success;
  final int? shopId;
  final List<OnlineBookingModel>? data;

  OnlineBookingResponseModel({
    this.success,
    this.shopId,
    this.data,
  });

  factory OnlineBookingResponseModel.fromJson(Map<String, dynamic> json) {
    return OnlineBookingResponseModel(
      success: json['success'],
      shopId: json['shop_id'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => OnlineBookingModel.fromJson(e))
              .toList()
          : null,
    );
  }
}

class OnlineBookingModel {
  final int? id;
  final int? customerId;
  final int? shopId;
  final int? shopBookingId;
  final int? stylistId;
  final String? stylistName;
  final String? stylistPhoto;
  final String? stylistSpeciality;
  final String? bookingTime;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final OnlineCustomerModel? customer;
  final List<OnlineServiceModel>? services;

  OnlineBookingModel({
    this.id,
    this.customerId,
    this.shopId,
    this.shopBookingId,
    this.stylistId,
    this.stylistName,
    this.stylistPhoto,
    this.stylistSpeciality,
    this.bookingTime,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.customer,
    this.services,
  });

  factory OnlineBookingModel.fromJson(Map<String, dynamic> json) {
    return OnlineBookingModel(
      id: json['id'],
      customerId: json['customer_id'],
      shopId: json['shop_id'],
      shopBookingId: json['shop_booking_id'],
      stylistId: json['stylist_id'],
      stylistName: json['stylist_name'],
      stylistPhoto: json['stylist_photo'],
      stylistSpeciality: json['stylist_speciality'],
      bookingTime: json['booking_time'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      customer: json['customer'] != null
          ? OnlineCustomerModel.fromJson(json['customer'])
          : null,
      services: json['services'] != null
          ? (json['services'] as List)
              .map((e) => OnlineServiceModel.fromJson(e))
              .toList()
          : null,
    );
  }

  double get totalAmount {
    if (services == null || services!.isEmpty) return 0.0;
    return services!.fold(
      0.0,
      (sum, item) => sum + ((item.rate ?? 0.0) * (item.quantity ?? 1)),
    );
  }
}

class OnlineCustomerModel {
  final int? id;
  final String? name;
  final String? phoneNumber;

  OnlineCustomerModel({
    this.id,
    this.name,
    this.phoneNumber,
  });

  factory OnlineCustomerModel.fromJson(Map<String, dynamic> json) {
    return OnlineCustomerModel(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
    );
  }
}

class OnlineServiceModel {
  final int? id;
  final int? customerBookingId;
  final int? serviceId;
  final String? name;
  final int? quantity;
  final double? rate;
  final String? createdAt;
  final String? updatedAt;

  OnlineServiceModel({
    this.id,
    this.customerBookingId,
    this.serviceId,
    this.name,
    this.quantity,
    this.rate,
    this.createdAt,
    this.updatedAt,
  });

  factory OnlineServiceModel.fromJson(Map<String, dynamic> json) {
    return OnlineServiceModel(
      id: json['id'],
      customerBookingId: json['customer_booking_id'],
      serviceId: json['service_id'],
      name: json['name'],
      quantity: json['quantity'],
      rate: toDouble(json['rate']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
