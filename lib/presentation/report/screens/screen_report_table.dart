import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/presentation/home/widgets/home_appbar.dart';
import 'package:sharp_cut/presentation/report/cubit/report_cubit.dart';
import 'package:sharp_cut/presentation/report/widgets/report_action_button.dart';
import 'package:sharp_cut/presentation/report/widgets/report_filter_item.dart';
import 'package:sharp_cut/presentation/report/widgets/report_data_table.dart';
import 'package:sharp_cut/presentation/report/widgets/staff_filter_item.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

class ScreenReportTable extends StatefulWidget {
  const ScreenReportTable({super.key});

  @override
  State<ScreenReportTable> createState() => _ScreenReportTableState();
}

class _ScreenReportTableState extends State<ScreenReportTable> {
  DateTimeRange? _selectedRange;
  final TextEditingController _searchController = TextEditingController();

  String get _dateLabel {
    if (_selectedRange == null) {
      return "Select Date Range";
    }

    String format(DateTime d) =>
        "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";

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
      if (context.mounted) {
        context.read<ReportCubit>().updateFilter('date_range', _dateLabel);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<ReportCubit>().fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final chairCubit = context.read<ChairCubit>();

    List<StaffModel> staffListAll = List<StaffModel>.from(chairCubit.staffs);

    List<StaffModel> staffList = staffListAll
        .where((element) => element.role != Role.admin)
        .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const HomeAppBar(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 2,
                          child: StaffFilterItem(
                            label: "Staff Name",
                            items: staffList,
                            onChanged: (int? staffId) {
                              context.read<ReportCubit>().updateFilter(
                                'user_id',
                                staffId,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),

                        /// DATE RANGE PICKER
                        Expanded(
                          flex: 4,
                          child: GestureDetector(
                            onTap: () => _pickDateRange(context),
                            child: AbsorbPointer(
                              child: ReportFilterItem(
                                label: "Filter By Date",
                                initialValue: _dateLabel,
                                items: const [],
                                icon: Icons.calendar_today,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ReportFilterItem(
                            label: "Paid Status",
                            initialValue: "All",
                            items: const ["All", "Paid", "Unpaid", "Partial"],
                            onChanged: (value) {
                              context.read<ReportCubit>().updateFilter(
                                'paid_status',
                                value,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ReportFilterItem(
                            label: "Order Status",
                            initialValue: "All",
                            items: const [
                              "All",
                              "Completed",
                              "Pending",
                              "Cancelled",
                            ],
                            onChanged: (value) {
                              context.read<ReportCubit>().updateFilter(
                                'transaction_status',
                                value,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Keyword Search",
                                style: GoogleFonts.rajdhani(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _searchController,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: "Search here..",
                                  hintStyle: GoogleFonts.rajdhani(
                                    color: Colors.grey,
                                  ),
                                  suffixIcon: const Icon(Icons.search),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const ReportActionButton(
                                label: "Back",
                                bgColor: Colors.grey,
                                textColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                final cubit = context.read<ReportCubit>();
                                cubit.updateFilter(
                                  'search_query',
                                  _searchController.text,
                                );
                                cubit.fetchTransactions();
                              },
                              child: const ReportActionButton(
                                label: "Search",
                                bgColor: Colors.blue,
                                textColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Expanded(child: ReportDataTable()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
