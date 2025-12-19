import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class PrintCountDialog extends StatefulWidget {
  const PrintCountDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const PrintCountDialog(),
    );
  }

  @override
  State<PrintCountDialog> createState() => _PrintCountDialogState();
}

class _PrintCountDialogState extends State<PrintCountDialog> {
  final TextEditingController _quickPaymentController = TextEditingController(
    text: '1',
  );
  final TextEditingController _settlePaymentController = TextEditingController(
    text: '1',
  );
  final TextEditingController _reportController = TextEditingController(
    text: '1',
  );
  final TextEditingController _invoiceListController = TextEditingController(
    text: '1',
  );

  @override
  void dispose() {
    _quickPaymentController.dispose();
    _settlePaymentController.dispose();
    _reportController.dispose();
    _invoiceListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2C), // Dark background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400, // Fixed width for better look on tablets/desktop
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Print Count',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Fields
            _buildCountField('Quick Payment', _quickPaymentController),
            const SizedBox(height: 16),
            _buildCountField('Settle payment', _settlePaymentController),
            const SizedBox(height: 16),
            _buildCountField('Report', _reportController),
            const SizedBox(height: 16),
            _buildCountField('Invoice List', _invoiceListController),

            const SizedBox(height: 32),

            // Save Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [AppColors.violetNormal, AppColors.redNormal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                 
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Label positioned on the border
              Positioned(
                left: 12,
                top: -10,
                child: Container(
                  color: const Color(0xFF1E1E2C), // Match dialog background
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '1/1',
          style: GoogleFonts.rajdhani(
            color: Colors.white.withOpacity(0.3),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
