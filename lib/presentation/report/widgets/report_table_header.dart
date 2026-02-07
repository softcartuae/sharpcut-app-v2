import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class ReportTableHeader extends StatelessWidget {
  const ReportTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          _buildHeaderCell("No", width: 50),
          _buildHeaderCell("Date", width: 100),
          _buildHeaderCell("Invoice", width: 150),
          _buildHeaderCell("Mobile", width: 100),
          _buildHeaderCell("Name", width: 150),
          _buildHeaderCell("Total", width: 80),
          _buildHeaderCell("Paid", width: 80),
          _buildHeaderCell("Balance", width: 80),
          _buildHeaderCell("Discount", width: 80),
          _buildHeaderCell("Staff Name", width: 100),
          _buildHeaderCell("Status", width: 80),

          _buildHeaderCell("Payment", width: 80),
          _buildHeaderCell("Print", width: 60),
          // _buildHeaderCell("Invoice", width: 60),
          _buildHeaderCell("View", width: 60),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    String text, {
    required double width,
    bool isCheckbox = false,
  }) {
    return SizedBox(
      width: width,
      child: isCheckbox
          ? Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.violetDarkActive,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                text,
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ),
    );
  }
}
