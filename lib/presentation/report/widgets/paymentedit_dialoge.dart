import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

class PaymentEditDialog extends StatefulWidget {
  final String invoiceNo;
  final double invoiceAmount;
  final String currentMode;
  final double currentAmount;
  final double availableWalletBalance;
  final Function(String mode, double amount) onUpdate;

  const PaymentEditDialog({
    super.key,
    required this.invoiceNo,
    required this.invoiceAmount,
    required this.currentMode,
    required this.currentAmount,
    this.availableWalletBalance = 0.0,
    required this.onUpdate,
  });

  @override
  State<PaymentEditDialog> createState() => _PaymentEditDialogState();
}

class _PaymentEditDialogState extends State<PaymentEditDialog> {
  late String selectedMode;
  late TextEditingController amountController;
  final List<String> paymentModes = [
    PaymentMode.Cash.name,
    PaymentMode.Card.name,
    PaymentMode.Wallet.name,
  ];

  @override
  void initState() {
    super.initState();
    selectedMode = widget.currentMode;
    if (!paymentModes.contains(selectedMode)) {
      if (paymentModes.any(
        (element) => element.toLowerCase() == selectedMode.toLowerCase(),
      )) {
        selectedMode = paymentModes.firstWhere(
          (element) => element.toLowerCase() == selectedMode.toLowerCase(),
        );
      } else {
        paymentModes.add(selectedMode);
      }
    }

    amountController = TextEditingController(
      text: widget.currentAmount.toString(),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFF2EFF8),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Payment',
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            PaymentEditInfoRow(label: 'Invoice No :', value: widget.invoiceNo),
            const SizedBox(height: 12),
            PaymentEditInfoRow(
              label: 'Invoice Amount :',
              value: widget.invoiceAmount.toStringAsFixed(2),
            ),
            if (selectedMode == PaymentMode.Wallet.name) ...[
              const SizedBox(height: 12),
              PaymentEditInfoRow(
                label: 'Wallet Balance :',
                value: 'AED ${widget.availableWalletBalance.toStringAsFixed(2)}',
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Type',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedMode,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: paymentModes.map((String mode) {
                        return DropdownMenuItem<String>(
                          value: mode,
                          child: Text(
                            mode,
                            style: GoogleFonts.rajdhani(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedMode = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                    style: GoogleFonts.rajdhani(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  top: 0,
                  child: Container(
                    color: const Color(0xFFF2EFF8),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '0.0',
                      style: GoogleFonts.rajdhani(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(amountController.text) ?? 0.0;
                    if (selectedMode == PaymentMode.Wallet.name) {
                      final double alreadyUsedWallet =
                          (widget.currentMode.toLowerCase() == 'wallet')
                              ? widget.currentAmount
                              : 0.0;
                      final double effectiveMaxWallet =
                          widget.availableWalletBalance + alreadyUsedWallet;

                      if (amount > effectiveMaxWallet) {
                        ToastHelper.showError(
                          "Wallet amount cannot exceed available balance (AED ${effectiveMaxWallet.toStringAsFixed(2)})",
                        );
                        return;
                      }
                    }
                    widget.onUpdate(selectedMode, amount);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.black),
                    ),
                  ),
                  child: Text(
                    'Update',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
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
}

class PaymentEditInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const PaymentEditInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
