import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TipDialog extends StatefulWidget {
  final Function(double) onTipSelected;
  final String title;

  const TipDialog({super.key, required this.onTipSelected, this.title = "TIP"});

  @override
  State<TipDialog> createState() => _TipDialogState();
}

class _TipDialogState extends State<TipDialog> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter the amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Amount',
                hintStyle: const TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  if (_amountController.text.isNotEmpty) {
                    final amount = double.tryParse(_amountController.text);
                    if (amount != null) {
                      widget.onTipSelected(amount);
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
