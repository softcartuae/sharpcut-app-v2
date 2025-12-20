import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class SettlementSimpleInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isReadOnly;

  const SettlementSimpleInput({
    super.key,
    required this.controller,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
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
        controller: controller,
        readOnly: isReadOnly,
        style: GoogleFonts.rajdhani(color: Colors.white),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}

class SettlementLabelInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isReadOnly;

  const SettlementLabelInput({
    super.key,
    required this.label,
    required this.controller,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        SettlementSimpleInput(controller: controller, isReadOnly: isReadOnly),
      ],
    );
  }
}

class SettlementRowInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isReadOnly;

  const SettlementRowInput({
    super.key,
    required this.label,
    required this.controller,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 3,
          child: SettlementSimpleInput(
            controller: controller,
            isReadOnly: isReadOnly,
          ),
        ),
      ],
    );
  }
}
