import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback? onTap;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.label,
    this.isPrimary = false,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 43,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [AppColors.violetNormal, AppColors.redNormal],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 47, 55, 70),
                    Color.fromARGB(255, 35, 42, 54),
                    Color.fromARGB(255, 25, 31, 40),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
          border: isPrimary
              ? null
              : const GradientBoxBorder(
                  gradient: LinearGradient(
                    colors: [AppColors.violetLight, AppColors.violetLight],
                  ),
                  width: .10,
                ),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
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
