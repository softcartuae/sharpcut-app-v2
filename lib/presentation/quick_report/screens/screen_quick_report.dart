import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/cubit/quick_report/quick_report_cubit.dart';
import 'package:sharp_cut/cubit/quick_report/quick_report_state.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';

import 'package:sharp_cut/presentation/quick_report/widgets/info_row.dart';
import 'package:sharp_cut/presentation/quick_report/widgets/quick_report_table_row.dart';
import 'package:sharp_cut/presentation/quick_report/widgets/summary_row.dart';
import 'package:sharp_cut/presentation/quick_report/widgets/table_header.dart';
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
      return "";
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (_selectedRange!.start == today && _selectedRange!.end == today) {
      return "Today";
    }

    if (_selectedRange!.start == yesterday &&
        _selectedRange!.end == yesterday) {
      return "Yesterday";
    }

    String format(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    return "${format(_selectedRange!.start)} - ${format(_selectedRange!.end)}";
  }

  @override
  void initState() {
    super.initState();
    // Fetch initial report with default range (null)
    _fetchReport();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _fetchReport() {
    String? dateRange;
    if (_selectedRange != null) {
      dateRange =
          "${_formatDate(_selectedRange!.start)} - ${_formatDate(_selectedRange!.end)}";
    }
    context.read<QuickReportCubit>().fetchQuickReport(
      dateRange: dateRange,
      userId: _selectedStaffId,
    );
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
      _fetchReport();
    }
  }

  void _showDateFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // ListTile(
                //   leading: const Icon(Icons.all_inclusive),
                //   title: const Text('All'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     setState(() {
                //       _selectedRange = null;
                //     });
                //     _fetchReport();
                //   },
                // ),
                ListTile(
                  leading: const Icon(Icons.today),
                  title: const Text('Today'),
                  onTap: () {
                    Navigator.pop(context);
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    setState(() {
                      _selectedRange = DateTimeRange(start: today, end: today);
                    });
                    _fetchReport();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Yesterday'),
                  onTap: () {
                    Navigator.pop(context);
                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final yesterday = today.subtract(const Duration(days: 1));
                    setState(() {
                      _selectedRange = DateTimeRange(
                        start: yesterday,
                        end: yesterday,
                      );
                    });
                    _fetchReport();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Custom Date'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickDateRange(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.black,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "Sales Report",
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
                  Expanded(
                    child: BlocBuilder<QuickReportCubit, QuickReportState>(
                      builder: (context, state) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: state is QuickReportLoaded
                                  ? () {
                                      final printCubit = context
                                          .read<PrintingCubit>();
                                      printCubit.printQuickReport(
                                        printCount: printCubit
                                            .state
                                            .settings
                                            ?.printCount
                                            .report
                                            .toInt(),
                                        report: state.report,
                                        userId: _selectedStaffId,
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF4CAF50,
                                ), // Green color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8),
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
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 45,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
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
                                      _fetchReport();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _showDateFilterOptions(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Report Preview Card
                    BlocBuilder<QuickReportCubit, QuickReportState>(
                      builder: (context, state) {
                        if (state is QuickReportLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is QuickReportError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        } else if (state is QuickReportLoaded) {
                          return _buildReportPreview(state.report);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview(QuickReportModel report) {
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
            report.salonName,
            style: GoogleFonts.rajdhani(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const InfoRow("Reports : Counter Cash"),
          InfoRow("Reports Date Range : ${report.dateRange}"),
          InfoRow("Printing Date / Time: ${report.printDatetime}"),
          InfoRow("Branch : ${report.branch}"),
          const InfoRow("Counter Sale (Cash Received)"),
          const InfoRow("Invoice Details - Delivered", isBold: true),
          const SizedBox(height: 8),
          const Divider(color: Colors.black, thickness: 1.5),

          // Summary Section
          // Summary Section
          ...report.invoiceDetails.entries.map((entry) {
            return SummaryRow(
              label: _formatKey(entry.key),
              value: entry.value.toStringAsFixed(2),
            );
          }),
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
          const TableHeader("Customer", "Invoice Count", "Amount"),
          const Divider(color: Colors.grey, thickness: 0.5),
          QuickReportTableRow(
            "Cash Customer",
            report.cashCustomerCount.toString(),
            report.cashCustomerAmount,
          ),
          QuickReportTableRow(
            "Card Customer",
            report.cardCustomerCount.toString(),
            report.cardCustomerAmount,
          ),
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
          const Divider(color: Colors.black, thickness: 1.5),

          // New 4-Column Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "Staff",
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
                    "Cash",
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
                    "Card",
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
                    "Total",
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.end,
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
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      detail.salesmanName,
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
                      detail.totalCashAmount,
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      detail.totalCardAmount,
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      total.toStringAsFixed(2),
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Footer
          const Divider(color: Colors.grey, thickness: 0.5),
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
                      totalCash.toStringAsFixed(2),
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
                      totalCard.toStringAsFixed(2),
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
                      grandTotal.toStringAsFixed(2),
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
            },
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
