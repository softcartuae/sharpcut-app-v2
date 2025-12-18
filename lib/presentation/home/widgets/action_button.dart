import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.label,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [AppColors.violetNormal, AppColors.redNormal],
                )
              : null,
          color: isPrimary ? null : Colors.black.withOpacity(0.3),
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
