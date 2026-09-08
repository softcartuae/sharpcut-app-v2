import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

class OnlineBookingStatusChip extends StatelessWidget {
  final String status;

  const OnlineBookingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusEnum = OnlineBookingStatus.fromString(status);
    final bgColor = statusEnum?.bgColor ?? AppColors.statusPendingBg;
    final borderColor = statusEnum?.borderColor ?? AppColors.statusPendingBorder;
    final textColor = statusEnum?.textColor ?? AppColors.statusPendingText;
    final labelText = statusEnum?.label ?? status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 0.8,
        ),
      ),
      child: Text(
        labelText,
        style: GoogleFonts.rajdhani(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
