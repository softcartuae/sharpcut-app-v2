import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final bool readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.readOnly = false,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: GradientBoxBorder(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.violetLight.withOpacity(0.9), // highlight
                      AppColors.violetLight.withOpacity(0.6), // shadow
                    ],
                  ),
                  width: 0.5,
                ),
              ),
              child: TextField(
                onChanged: onChanged,
                readOnly: readOnly,
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                style: GoogleFonts.rajdhani(color: Colors.white),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.rajdhani(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
