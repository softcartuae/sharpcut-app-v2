import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/widgets/quick_payment_popup.dart';

final GlobalKey quickPaymentKey = GlobalKey();
OverlayEntry? overlayEntry;

void showQuickPaymentPopup(BuildContext context, Function onCashSelected, Function onCreditCardSelected) {
  if (overlayEntry != null) {
    overlayEntry!.remove();
    overlayEntry = null;
    return;
  }

  final RenderBox renderBox =
      quickPaymentKey.currentContext!.findRenderObject() as RenderBox;
  final offset = renderBox.localToGlobal(Offset.zero);

  overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        GestureDetector(
          onTap: () {
            overlayEntry?.remove();
            overlayEntry = null;
          },
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          left: offset.dx - 260, // Adjust based on popup width
          top: offset.dy - 10, // Adjust to align vertically
          child: Material(
            color: Colors.transparent,
            child: QuickPaymentPopup(
              onCashSelected: () {
                // Handle Cash Selection
                onCashSelected();
                overlayEntry?.remove();
                overlayEntry = null;
              },
              onCreditCardSelected: () {
                onCreditCardSelected();
                // Handle Credit Card Selection
                overlayEntry?.remove();
                overlayEntry = null;
              },
            ),
          ),
        ),
      ],
    ),
  );

  Overlay.of(context).insert(overlayEntry!);
}
