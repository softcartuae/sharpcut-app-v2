import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

class ScreenQuickReport extends StatefulWidget {
  const ScreenQuickReport({super.key});

  @override
  State<ScreenQuickReport> createState() => _ScreenQuickReportState();
}

class _ScreenQuickReportState extends State<ScreenQuickReport> {
  DateTimeRange? _selectedRange;
  int? _selectedStaffId;

  String get _dateLabel {
    if (_selectedRange == null) {
      final now = DateTime.now();
      return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} - ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }

    String format(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    return "${format(_selectedRange!.start)} - ${format(_selectedRange!.end)}";
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _selectedRange,
    );

    if (picked != null) {
      setState(() {
        _selectedRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chairCubit = context.read<ChairCubit>();
    List<StaffModel> staffListAll = List<StaffModel>.from(chairCubit.staffs);
    List<StaffModel> staffList = staffListAll
        .where((element) => element.role != Role.admin)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(Icons.menu, color: Colors.blue),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            child: Text(
                              "Counter Cash",
                              style: GoogleFonts.rajdhani(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Custom Staff Name Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "STAFF NAME",
                          style: GoogleFonts.rajdhani(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 45,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedStaffId,
                              isExpanded: true,
                              hint: Text(
                                "All",
                                style: GoogleFonts.rajdhani(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black,
                              ),
                              dropdownColor: Colors.white,
                              style: GoogleFonts.rajdhani(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text("All"),
                                ),
                                ...staffList.map((StaffModel staff) {
                                  return DropdownMenuItem<int>(
                                    value: staff.id,
                                    child: Text(
                                      staff.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (int? newValue) {
                                setState(() {
                                  _selectedStaffId = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date Range Filter
                    GestureDetector(
                      onTap: () => _pickDateRange(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _dateLabel,
                              style: GoogleFonts.rajdhani(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Print Report Button
                    Center(
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement print functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF4CAF50,
                            ), // Green color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "Print Report",
                            style: GoogleFonts.rajdhani(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Report Preview Card
                    _buildReportPreview(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade200),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Text(
            "TAJ SHALEELA Salon test1",
            style: GoogleFonts.rajdhani(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _buildInfoRow("Reports : Counter Cash"),
          _buildInfoRow(
            "Reports Date Range : 01-01-2026 to 02-01-2026 07:30 AM to 02:30 AM,",
          ),
          _buildInfoRow("Printing Date / Time: 01-01-2026 11:47 AM"),
          _buildInfoRow("Branch : MAIN"),
          _buildInfoRow("Counter Sale (Cash Received)"),
          _buildInfoRow("Invoice Details - Delivered", isBold: true),
          const SizedBox(height: 8),
          const Divider(color: Colors.black, thickness: 1.5),

          // Summary Section
          _buildSummaryRow("Total Invoice", "0"),
          _buildSummaryRow("Total Invoice Sales Amount", "0.00"),
          _buildSummaryRow("Total Unpaid amount", "0.00"),
          _buildSummaryRow("Gross Total Amount", "0.00"),
          _buildSummaryRow("Total Discount", "0.00"),
          _buildSummaryRow("Total Credit Amount", "0.00"),
          const SizedBox(height: 16),

          // Invoice Customer Details
          Text(
            "Invoice Customer Details",
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Divider(color: Colors.black, thickness: 1.5),
          _buildTableHeader("Customer", "Invoice Count", "Amount"),
          const Divider(color: Colors.grey, thickness: 0.5),
          _buildTableRow("Cash Customer", "0", "0.00"),
          _buildTableRow("Card Customer", "0", "0.00"),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey, thickness: 0.5),

          // Salesman Wise Details
          Text(
            "Salesman Wise Details (payment method)",
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Divider(color: Colors.grey, thickness: 0.5),
          // Empty list in image, but we can add a placeholder or just the footer
          const SizedBox(height: 16),

          // Footer
          const Divider(color: Colors.grey, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "0",
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "0.00",
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        text,
        style: GoogleFonts.rajdhani(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String col1, String col2, String col3) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            col1,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            col2,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            col3,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(String col1, String col2, String col3) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              col1,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col2,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              col3,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
