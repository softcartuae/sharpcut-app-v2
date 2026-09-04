import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/domain/booking/models/staff_wise_booking_model.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_card.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_table_header.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class StaffWiseCard extends StatelessWidget {
  final StaffWiseBookingModel staffBooking;

  const StaffWiseCard({super.key, required this.staffBooking});

  @override
  Widget build(BuildContext context) {
    final bookings = staffBooking.bookings ?? [];
    final staffName = (staffBooking.staffName != null &&
            staffBooking.staffName!.trim().isNotEmpty)
        ? staffBooking.staffName!.trim()
        : "Unassigned Staff";
    final staffPhoto = staffBooking.staffPhoto;
    final staffSpeciality = (staffBooking.staffSpeciality != null &&
            staffBooking.staffSpeciality!.trim().isNotEmpty)
        ? staffBooking.staffSpeciality!.trim()
        : "Stylist";
    final totalBookings = staffBooking.totalBookings ?? bookings.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Staff Header
          StaffCardHeader(
            staffName: staffName,
            staffPhoto: staffPhoto,
            staffSpeciality: staffSpeciality,
            totalBookings: totalBookings,
          ),
          const Divider(color: AppColors.borderLight, height: 1),

          // Staff Bookings Table
          Padding(
            padding: const EdgeInsets.all(12),
            child: bookings.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        "No bookings found for $staffName",
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textMutedLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const OnlineBookingTableHeader(staffwise: true,),
                      const SizedBox(height: 6),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return OnlineBookingCard(booking: booking, staffwise: true,);
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class StaffCardHeader extends StatelessWidget {
  final String staffName;
  final String? staffPhoto;
  final String staffSpeciality;
  final int totalBookings;

  const StaffCardHeader({
    super.key,
    required this.staffName,
    this.staffPhoto,
    required this.staffSpeciality,
    required this.totalBookings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.headerLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // Staff Photo Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight, width: 1.5),
            ),
            child: ClipOval(
              child: staffPhoto != null && staffPhoto!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: staffPhoto!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) =>
                          StaffAvatarFallback(staffName: staffName),
                    )
                  : StaffAvatarFallback(staffName: staffName),
            ),
          ),
          const SizedBox(width: 12),

          // Staff Name & Speciality
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staffName,
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  staffSpeciality.toUpperCase(),
                  style: GoogleFonts.rajdhani(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Total Bookings Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.violetNormal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.violetNormal.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              "$totalBookings ${totalBookings == 1 ? 'BOOKING' : 'BOOKINGS'}",
              style: GoogleFonts.rajdhani(
                color: AppColors.violetDark,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StaffAvatarFallback extends StatelessWidget {
  final String staffName;

  const StaffAvatarFallback({super.key, required this.staffName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.violetNormal,
      alignment: Alignment.center,
      child: Text(
        staffName.isNotEmpty ? staffName[0].toUpperCase() : "S",
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
