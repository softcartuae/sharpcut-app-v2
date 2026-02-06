import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/domain/printing/model/printer_paper_size.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class PaperWidthSelectionDialog extends StatelessWidget {
  const PaperWidthSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              "Select Paper Width",
              style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Please select the paper width for this printer. This setting will be saved.",
            style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          ...PrinterPaperSize.values.map((size) {
            return ListTile(
              title: Text(
                size.label,
                style: GoogleFonts.rajdhani(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop(size);
              },
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.violetNormal,
              ),
            );
          }),
        ],
      ),
    );
  }
}
