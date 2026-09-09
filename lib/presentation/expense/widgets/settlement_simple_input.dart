import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class SettlementSimpleInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isReadOnly;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const SettlementSimpleInput({
    super.key,
    required this.controller,
    this.isReadOnly = false,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.violetLight.withValues(alpha: 0.9), // highlight
              AppColors.violetLight.withValues(alpha: 0.6), // shadow
            ],
          ),
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        style: GoogleFonts.rajdhani(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          isDense: true,
        ),
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
      ),
    );
  }
}
