import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class QuickPaymentPopup extends StatefulWidget {
  final VoidCallback onCashSelected;
  final VoidCallback onCreditCardSelected;

  const QuickPaymentPopup({
    super.key,
    required this.onCashSelected,
    required this.onCreditCardSelected,
  });

  @override
  State<QuickPaymentPopup> createState() => _QuickPaymentPopupState();
}

class _QuickPaymentPopupState extends State<QuickPaymentPopup> {
  bool isCashSelected = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9), // Light green/white background
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cash Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCashSelected = true;
                  });
                  widget.onCashSelected();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isCashSelected
                        ? AppColors.greenNormal
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isCashSelected
                        ? null
                        : Border.all(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    "Cash",
                    style: GoogleFonts.rajdhani(
                      color: isCashSelected ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Credit Card Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCashSelected = false;
                  });
                  widget.onCreditCardSelected();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: !isCashSelected
                        ? AppColors.greenNormal
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: !isCashSelected
                        ? null
                        : Border.all(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    "Credit Card",
                    style: GoogleFonts.rajdhani(
                      color: !isCashSelected ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Triangle Tail
        Positioned(
          right: -10,
          top: 0,
          bottom: 0,
          child: Center(
            child: CustomPaint(
              painter: _TrianglePainter(color: const Color(0xFFE8F5E9)),
              size: const Size(10, 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
