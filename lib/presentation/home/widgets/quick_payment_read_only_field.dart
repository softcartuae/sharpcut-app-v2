import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickPaymentReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const QuickPaymentReadOnlyField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.rajdhani(fontSize: 16, color: Colors.black87),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: GoogleFonts.rajdhani(fontSize: 16, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
