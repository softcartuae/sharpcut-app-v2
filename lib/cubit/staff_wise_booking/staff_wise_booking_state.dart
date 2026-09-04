import 'package:equatable/equatable.dart';
import 'package:sharp_cut/domain/booking/models/staff_wise_booking_model.dart';

abstract class StaffWiseBookingState extends Equatable {
  const StaffWiseBookingState();

  @override
  List<Object?> get props => [];
}

class StaffWiseBookingInitial extends StaffWiseBookingState {}

class StaffWiseBookingLoading extends StaffWiseBookingState {}

class StaffWiseBookingLoaded extends StaffWiseBookingState {
  final List<StaffWiseBookingModel> staffWiseBookings;
  final int page;
  final bool hasMore;
  final bool isRefreshing;
  final int totalBookings;
  final int totalStaff;
  final String? date;
  final String? status;
  final String? search;

  const StaffWiseBookingLoaded({
    required this.staffWiseBookings,
    required this.page,
    required this.hasMore,
    this.isRefreshing = false,
    this.totalBookings = 0,
    this.totalStaff = 0,
    this.date,
    this.status,
    this.search,
  });

  StaffWiseBookingLoaded copyWith({
    List<StaffWiseBookingModel>? staffWiseBookings,
    int? page,
    bool? hasMore,
    bool? isRefreshing,
    int? totalBookings,
    int? totalStaff,
    String? date,
    String? status,
    String? search,
  }) {
    return StaffWiseBookingLoaded(
      staffWiseBookings: staffWiseBookings ?? this.staffWiseBookings,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      totalBookings: totalBookings ?? this.totalBookings,
      totalStaff: totalStaff ?? this.totalStaff,
      date: date ?? this.date,
      status: status ?? this.status,
      search: search ?? this.search,
    );
  }

  @override
  List<Object?> get props => [
        staffWiseBookings,
        page,
        hasMore,
        isRefreshing,
        totalBookings,
        totalStaff,
        date,
        status,
        search,
      ];
}

class StaffWiseBookingError extends StaffWiseBookingState {
  final String message;

  const StaffWiseBookingError({required this.message});

  @override
  List<Object?> get props => [message];
}
