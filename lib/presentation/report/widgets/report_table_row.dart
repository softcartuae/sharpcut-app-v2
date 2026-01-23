import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';

class ReportTableRow extends StatelessWidget {
  final int index;
  final VoidCallback viewFunction;
  final BookingResponseModel transaction;
  final VoidCallback printTheInvoice;
  final VoidCallback paymentSettleFunction;
  final VoidCallback onBalanceTap;

  const ReportTableRow({
    super.key,
    required this.index,
    required this.transaction,
    required this.viewFunction,
    required this.printTheInvoice,
    required this.paymentSettleFunction,
    required this.onBalanceTap,
  });

  @override
  Widget build(BuildContext context) {
    final balenceAmount =
        (transaction.finalTotal ?? 0) - ((transaction.totalPayment ?? 0));
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.black)),
      ),
      child: Row(
        children: [
          _buildDataCell("${index + 1}", width: 50),
          _buildDataCell(transaction.transactionDate ?? "-", width: 100),
          _buildDataCell(transaction.invoiceNo ?? "-", width: 120),
          _buildDataCell(transaction.customerNumber ?? "-", width: 100),
          _buildDataCell(transaction.customerName ?? "-", width: 100),
          _buildDataCell(
            transaction.finalTotal?.toStringAsFixed(2) ?? "0.00",
            width: 80,
          ),
          _buildDataCell(
            transaction.totalPayment?.toStringAsFixed(2) ?? "0.00",
            width: 80,
          ),
          _buildDataCell(
            balenceAmount.toStringAsFixed(2),
            width: 80,
            isBalanceCell: balenceAmount > 0,
            onTap: balenceAmount > 0 ? onBalanceTap : null,
          ),
          _buildDataCell(
            transaction.discount?.toStringAsFixed(2) ?? "0.00",
            width: 80,
          ),
          _buildDataCell(transaction.staff?.name ?? "-", width: 100),

          _buildActionCell(
            Icons.payment,
            width: 60,
            onTap: paymentSettleFunction,
          ),
          _buildActionCell(
            Icons.receipt_long_outlined,
            width: 60,
            onTap: printTheInvoice,
          ),
          _buildActionCell(Icons.visibility, width: 60, onTap: viewFunction),
        ],
      ),
    );
  }

  Widget _buildDataCell(
    String text, {
    required double width,
    bool isCheckbox = false,
    bool isChecked = false,
    bool isBalanceCell = false,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: width,
      child: isCheckbox
          ? Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isChecked ? Colors.blue : Colors.transparent,
                  border: Border.all(
                    color: isChecked ? Colors.blue : Colors.grey,
                    width: .5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isChecked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            )
          : InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: GoogleFonts.rajdhani(
                      color: isBalanceCell ? Colors.red : Colors.grey[800],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      decoration: onTap != null
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildActionCell(
    IconData icon, {
    required double width,
    void Function()? onTap,
  }) {
    return SizedBox(
      width: width,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Icon(icon, size: 20, color: Colors.black),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final DateTime date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }
}
