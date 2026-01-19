import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showQuickPaymentPopup(
  BuildContext context,
  Function(double discount) onCashSelected,
  Function(double discount) onCreditCardSelected,
  Function(double discount) onUnPaid, {
  required double total,
  required double discount,
  required double grandTotal,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return QuickPaymentDialog(
        total: total,
        initialDiscount: discount,
        onCashSelected: onCashSelected,
        onCreditCardSelected: onCreditCardSelected,
        onUnPaid: onUnPaid,
      );
    },
  );
}

class QuickPaymentDialog extends StatefulWidget {
  final double total;
  final double initialDiscount;
  final Function(double discount) onCashSelected;
  final Function(double discount) onCreditCardSelected;
  final Function(double discount) onUnPaid;

  const QuickPaymentDialog({
    super.key,
    required this.total,
    required this.initialDiscount,
    required this.onCashSelected,
    required this.onCreditCardSelected,
    required this.onUnPaid,
  });

  @override
  State<QuickPaymentDialog> createState() => _QuickPaymentDialogState();
}

class _QuickPaymentDialogState extends State<QuickPaymentDialog> {
  late TextEditingController _discountController;
  late double _grandTotal;
  late double _uiGrandTotal;

  @override
  void initState() {
    super.initState();
    _discountController = TextEditingController(
      text: widget.initialDiscount.toString(),
    );
    _grandTotal = widget.total - widget.initialDiscount;
    _uiGrandTotal = _grandTotal;
    _discountController.addListener(_updateGrandTotal);
  }

  void _updateGrandTotal() {
    final double discount = double.tryParse(_discountController.text) ?? 0.0;
    setState(() {
      _uiGrandTotal = widget.total - discount;
    });
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFF3E5F5),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            Text(
              "Quick Payment",
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildReadOnlyField("Total :", widget.total.toStringAsFixed(2)),
            const SizedBox(height: 10),
            _buildEditableField("Discount :", _discountController),
            const SizedBox(height: 10),
            _buildReadOnlyField(
              "Grand Total :",
              _uiGrandTotal.toStringAsFixed(2),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      final discount =
                          double.tryParse(_discountController.text) ?? 0.0;
                      widget.onCashSelected(discount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Cash",
                      style: GoogleFonts.rajdhani(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      final discount =
                          double.tryParse(_discountController.text) ?? 0.0;
                      widget.onCreditCardSelected(discount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      "Card",
                      style: GoogleFonts.rajdhani(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      final discount =
                          double.tryParse(_discountController.text) ?? 0.0;
                      widget.onUnPaid(discount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      "Unpaid",
                      style: GoogleFonts.rajdhani(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
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

  Widget _buildEditableField(String label, TextEditingController controller) {
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
