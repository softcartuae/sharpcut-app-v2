import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';

class CloseRegisterPrintWidget extends StatelessWidget {
  final CloseRegisterReportModel report;
  final ShopModel shop;
  final double? width;

  const CloseRegisterPrintWidget({
    super.key,
    required this.report,
    required this.shop,
    this.width,
  });

  String _formatKey(String key) {
    return key
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 370, // Standard receipt width
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
                fontSize: 20,
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

          const SizedBox(height: 2),
          Text(
            "CLOSE REGISTER REPORT",
            style: GoogleFonts.rajdhani(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          const Divider(color: Colors.black),
          const SizedBox(height: 2),
          _buildDetailRow("Register ID", report.cashRegisterId.toString()),
          _buildDetailRow("Opened By", report.openedBy),
          _buildDetailRow("Opened At", _formatDate(report.openedAt)),
          _buildDetailRow("Closed By", report.closedBy),
          _buildDetailRow("Closed At", _formatDate(report.closedAt)),
          const SizedBox(height: 2),
          const Divider(color: Colors.black),
          const SizedBox(height: 2),
          _buildDetailRow("Opening Amount", report.openingAmount),
          _buildDetailRow(
            "Total Sales Count",
            report.totalSalesCount.toString(),
          ),
          _buildDetailRow(
            "Total Sales Amount",
            report.totalSalesAmount.toString(),
          ),
          const SizedBox(height: 2),
          const Divider(color: Colors.black),
          const SizedBox(height: 2),
          _buildDetailRow(
            "Expected Closing",
            report.expectedClosingAmount.toString(),
          ),
          _buildDetailRow("Actual Closing", report.closingAmount.toString()),
          const SizedBox(height: 2),
          _buildDetailRow(
            "Discrepancy",
            report.discrepancy.toString(),
            isBold: true,
            color: Colors.black,
          ),
          if (report.transactions != null) ...[
            const SizedBox(height: 2),
            const Divider(color: Colors.black),
            const SizedBox(height: 2),
            Text(
              "TRANSACTION DETAILS",
              style: GoogleFonts.rajdhani(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            ...report.transactions!.invoiceDetails.entries.map((entry) {
              return _buildDetailRow(
                _formatKey(entry.key),
                entry.value.toString(),
              );
            }),

            const SizedBox(height: 2),
            const Divider(color: Colors.black),
            const SizedBox(height: 2),
            Text(
              "CUSTOMER TYPE DETAILS",
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            _buildDetailRow(
              "Cash Customers",
              "${report.transactions!.cashCustomerCount} (${report.transactions!.cashCustomerAmount})",
            ),
            _buildDetailRow(
              "Card Customers",
              "${report.transactions!.cardCustomerCount} (${report.transactions!.cardCustomerAmount})",
            ),
            const SizedBox(height: 2),
            const Divider(color: Colors.black),
            const SizedBox(height: 2),
            Text(
              "SALESMAN WISE DETAILS",
              style: GoogleFonts.rajdhani(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Divider(color: Colors.black, thickness: 1.5),

            // 4-Column Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Staff",
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Cash",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Card",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Total",
                      textAlign: TextAlign.end,
                      style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey, thickness: 0.5),

            // Rows
            ...report.transactions!.salesmanWiseDetails.map((detail) {
              final double cash =
                  double.tryParse(detail.totalCashAmount) ?? 0.0;
              final double card =
                  double.tryParse(detail.totalCardAmount) ?? 0.0;
              final double total = cash + card;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        detail.salesmanName,
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        detail.totalCashAmount,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        detail.totalCardAmount,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rajdhani(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        total.toStringAsFixed(2),
                        textAlign: TextAlign.end,
                        style: GoogleFonts.rajdhani(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),
            const Divider(color: Colors.black, thickness: 1),

            // Footer Totals
            Builder(
              builder: (context) {
                double totalCash = 0.0;
                double totalCard = 0.0;

                for (var detail in report.transactions!.salesmanWiseDetails) {
                  totalCash += double.tryParse(detail.totalCashAmount) ?? 0.0;
                  totalCard += double.tryParse(detail.totalCardAmount) ?? 0.0;
                }
                final double grandTotal = totalCash + totalCard;

                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Total :${report.transactions!.salesmanWiseDetails.length}",
                        style: GoogleFonts.rajdhani(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        totalCash.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rajdhani(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        totalCard.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rajdhani(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        grandTotal.toStringAsFixed(2),
                        textAlign: TextAlign.end,
                        style: GoogleFonts.rajdhani(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
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
    bool isBold = true,
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
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.rajdhani(
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
