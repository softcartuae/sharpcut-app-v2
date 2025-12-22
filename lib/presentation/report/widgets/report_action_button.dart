import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportActionButton extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  const ReportActionButton({
    super.key,
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, color: textColor, size: 16),
          ],
        ],
      ),
    );
  }
}
