import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class TableHeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final Alignment alignment;

  const TableHeaderCell({
    super.key,
    required this.label,
    required this.flex,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            color: AppColors.textHeaderLight,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
