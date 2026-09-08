import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';

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
