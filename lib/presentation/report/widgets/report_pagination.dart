import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportPagination extends StatelessWidget {
  const ReportPagination({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing 1 to 15 of 2,000 entries ( filtered from 25 total entries )",
            style: GoogleFonts.rajdhani(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Add pagination controls if needed
        ],
      ),
    );
  }
}
