import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickPaymentEditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const QuickPaymentEditableField({
    super.key,
    required this.label,
    required this.controller,
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: GoogleFonts.rajdhani(fontSize: 16, color: Colors.black87),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "0.0",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
