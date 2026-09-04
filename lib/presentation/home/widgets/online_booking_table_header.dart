import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class OnlineBookingTableHeader extends StatelessWidget {
    final bool staffwise;

  const OnlineBookingTableHeader({super.key,this.staffwise = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.headerLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child:  Row(
        children: [
          TableHeaderCell(label: "CUSTOMER", flex: 3),
          TableHeaderCell(label: "DATE & TIME", flex: 3),
        if(staffwise == false)   TableHeaderCell(label: "STYLIST", flex: 2),
          TableHeaderCell(label: "SERVICES", flex: 3),
          TableHeaderCell(label: "TOTAL", flex: 2),
          TableHeaderCell(
            label: "STATUS",
            flex: 2,
            alignment: Alignment.center,
          ),
          TableHeaderCell(
            label: "ACTION",
            flex: 3,
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }
}

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
