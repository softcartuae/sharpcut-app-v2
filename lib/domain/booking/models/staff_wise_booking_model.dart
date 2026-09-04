import 'package:sharp_cut/domain/booking/models/online_booking_model.dart';

class StaffWiseBookingResponseModel {
  final bool? success;
  final int? shopId;
  final String? date;
  final List<StaffWiseBookingModel>? data;
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final int? totalBookings;

  StaffWiseBookingResponseModel({
    this.success,
    this.shopId,
    this.date,
    this.data,
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.totalBookings,
  });

  factory StaffWiseBookingResponseModel.fromJson(Map<String, dynamic> json) {
    return StaffWiseBookingResponseModel(
      success: json['success'],
      shopId: json['shop_id'],
      date: json['date'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => StaffWiseBookingModel.fromJson(e))
              .toList()
          : null,
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
      totalBookings: json['total_bookings'],
    );
  }
}

class StaffWiseBookingModel {
  final int? staffId;
  final String? staffName;
  final String? staffPhoto;
  final String? staffSpeciality;
  final int? totalBookings;
  final List<OnlineBookingModel>? bookings;

  StaffWiseBookingModel({
    this.staffId,
    this.staffName,
    this.staffPhoto,
    this.staffSpeciality,
    this.totalBookings,
    this.bookings,
  });

  factory StaffWiseBookingModel.fromJson(Map<String, dynamic> json) {
    return StaffWiseBookingModel(
      staffId: json['staff_id'],
      staffName: json['staff_name'],
      staffPhoto: json['staff_photo'],
      staffSpeciality: json['staff_speciality'],
      totalBookings: json['total_bookings'],
      bookings: json['bookings'] != null
          ? (json['bookings'] as List)
              .map((e) => OnlineBookingModel.fromJson(e))
              .toList()
          : null,
    );
  }
}
