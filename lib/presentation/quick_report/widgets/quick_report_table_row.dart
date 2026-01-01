import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickReportTableRow extends StatelessWidget {
  final String col1;
  final String col2;
  final String col3;

  const QuickReportTableRow(this.col1, this.col2, this.col3, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              col1,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col2,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col3,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
