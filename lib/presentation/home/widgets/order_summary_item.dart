import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const OrderSummaryItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
