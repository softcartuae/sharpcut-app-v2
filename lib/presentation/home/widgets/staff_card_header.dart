import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/presentation/home/widgets/staff_avatar_fallback.dart';
import 'package:sharp_cut/utils/app_colors.dart';

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
