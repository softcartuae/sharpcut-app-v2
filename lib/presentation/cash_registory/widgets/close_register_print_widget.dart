import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';

class CloseRegisterPrintWidget extends StatelessWidget {
  final CloseRegisterReportModel report;
  final ShopModel shop;

  const CloseRegisterPrintWidget({
    super.key,
    required this.report,
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380, // Standard receipt width
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          const Center(
            child: Icon(Icons.content_cut, size: 50, color: Colors.black),
          ),
          const SizedBox(height: 8),

          // Shop Name
          Text(
            shop.name ?? 'Shop Name',
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          // Address
          if (shop.address != null)
            Text(
              shop.address!,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

          // TRN
          if (shop.vatNo != null)
            Text(
              'TRN: ${shop.vatNo}',
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

          const SizedBox(height: 10),
          Text(
            "CLOSE REGISTER REPORT",
            style: GoogleFonts.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.black),
          const SizedBox(height: 10),
          _buildDetailRow("Register ID", report.cashRegisterId.toString()),
          _buildDetailRow("Opened By", report.openedBy),
          _buildDetailRow("Opened At", _formatDate(report.openedAt)),
          _buildDetailRow("Closed By", report.closedBy),
          _buildDetailRow("Closed At", _formatDate(report.closedAt)),
          const SizedBox(height: 10),
          const Divider(color: Colors.black),
          const SizedBox(height: 10),
          _buildDetailRow("Opening Amount", report.openingAmount),
          _buildDetailRow(
            "Total Sales Count",
            report.totalSalesCount.toString(),
          ),
          _buildDetailRow(
            "Total Sales Amount",
            report.totalSalesAmount.toString(),
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.black),
          const SizedBox(height: 10),
          _buildDetailRow(
            "Expected Closing",
            report.expectedClosingAmount.toString(),
          ),
          _buildDetailRow("Actual Closing", report.closingAmount.toString()),
          const SizedBox(height: 10),
          _buildDetailRow(
            "Discrepancy",
            report.discrepancy.toString(),
            isBold: true,
            color: report.discrepancy != 0 ? Colors.red : Colors.black,
          ),
          const SizedBox(height: 20),
          Text(
            "*** END OF REPORT ***",
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color color = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
