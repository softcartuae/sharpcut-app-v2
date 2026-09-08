import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class CustomerAvatarFallback extends StatelessWidget {
  final String? customerName;

  const CustomerAvatarFallback({super.key, this.customerName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.violetNormal,
            AppColors.violetDark,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        (customerName != null && customerName!.trim().isNotEmpty)
            ? customerName!.trim()[0].toUpperCase()
            : "C",
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
