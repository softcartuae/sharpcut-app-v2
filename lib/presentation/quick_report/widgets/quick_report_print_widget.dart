import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';

class QuickReportPrintWidget extends StatelessWidget {
  final QuickReportModel report;
  final double? width;

  const QuickReportPrintWidget({super.key, required this.report, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 370, // Target width for 58mm printer
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            report.salonName,
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildInfoRow("Reports : Counter Cash"),
              _buildInfoRow("Date Range : ${report.dateRange}"),
              _buildInfoRow("Print Time: ${report.printDatetime}"),
              _buildInfoRow("Branch : ${report.branch}"),
              _buildInfoRow("Counter Sale (Cash Received)"),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Invoice Details - Delivered",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Divider(color: Colors.black, thickness: 1.5),

          // Summary Section
          // Summary Section
          ...report.invoiceDetails.entries.map((entry) {
            return _buildSummaryRow(
              _formatKey(entry.key),
              entry.value.toString(),
            );
          }),

          const SizedBox(height: 16),

          // Invoice Customer Details
          const Text(
            "Invoice Customer Details",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Divider(color: Colors.black, thickness: 1.5),
          _buildTableHeader("Customer", "Count", "Amount"),
          const Divider(color: Colors.grey, thickness: 0.5),
          _buildTableRow(
            "Cash Customer",
            report.cashCustomerCount.toString(),
            report.cashCustomerAmount,
          ),
          _buildTableRow(
            "Card Customer",
            report.cardCustomerCount.toString(),
            report.cardCustomerAmount,
          ),
          const SizedBox(height: 16),

          // Salesman Wise Details
          const Text(
            "Salesman Wise Details",
            style: TextStyle(
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
              children: const [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Staff",
                    style: TextStyle(
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
                    style: TextStyle(
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
                    style: TextStyle(
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
                    style: TextStyle(
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
          ...report.salesmanWiseDetails.map((detail) {
            final double cash = double.tryParse(detail.totalCashAmount) ?? 0.0;
            final double card = double.tryParse(detail.totalCardAmount) ?? 0.0;
            final double total = cash + card;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      detail.salesmanName,
                      style: const TextStyle(
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
                      style: const TextStyle(
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
                      style: const TextStyle(
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
                      style: const TextStyle(
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

              for (var detail in report.salesmanWiseDetails) {
                totalCash += double.tryParse(detail.totalCashAmount) ?? 0.0;
                totalCard += double.tryParse(detail.totalCardAmount) ?? 0.0;
              }
              final double grandTotal = totalCash + totalCard;

              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Total :${report.salesmanWiseDetails.length}",
                      style: const TextStyle(
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
                      style: const TextStyle(
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
                      style: const TextStyle(
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
                      style: const TextStyle(
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String col1, String col2, String col3) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              col1,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col3,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String col1, String col2, String col3) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              col1,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col3,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}
