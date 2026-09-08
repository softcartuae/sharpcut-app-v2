import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/domain/booking/models/staff_wise_booking_model.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_card.dart';
import 'package:sharp_cut/presentation/home/widgets/online_booking_table_header.dart';
import 'package:sharp_cut/presentation/home/widgets/staff_card_header.dart';
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
