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
  const ScreenReportTable({
    super.key,
    this.staff,
    this.initialSearchKeyword,
    this.filterByToday = false,
  });

  final StaffModel? staff;
  final String? initialSearchKeyword;
  final bool filterByToday;

  @override
  State<ScreenReportTable> createState() => _ScreenReportTableState();
}

class _ScreenReportTableState extends State<ScreenReportTable> {
  DateTimeRange? _selectedRange;
  final TextEditingController _searchController = TextEditingController();
  Key _filterKey = UniqueKey();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String get _dateLabel {
    if (_selectedRange == null) {
      return "All";
    }

    final now = DateTime.now();
    if (_isSameDay(_selectedRange!.start, now) &&
        _isSameDay(_selectedRange!.end, now)) {
      return "Today";
    }

    String format(DateTime d) =>
        "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";

    return "${format(_selectedRange!.start)} - ${format(_selectedRange!.end)}";
  }

  String get _dateFilterValue {
    if (_selectedRange == null) {
      return "";
    }

    String format(DateTime d) =>
        "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";

    return "${format(_selectedRange!.start)} - ${format(_selectedRange!.end)}";
  }

  Future<void> _showDateSelectionOptions(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Date Option'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'All');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('All'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Custom Date');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Custom Date'),
              ),
            ),
          ],
        );
      },
    );

    if (result == 'All') {
      setState(() {
        _selectedRange = null;
      });
      if (context.mounted) {
        context.read<ReportCubit>().updateFilter(
          'date_range',
          _dateFilterValue,
        );
      }
    } else if (result == 'Custom Date') {
      if (context.mounted) {
        _pickDateRange(context);
      }
    }
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
        context.read<ReportCubit>().updateFilter(
          'date_range',
          _dateFilterValue,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReportCubit>();

    // Handle initial search keyword
    if (widget.initialSearchKeyword != null &&
        widget.initialSearchKeyword!.isNotEmpty) {
      _searchController.text = widget.initialSearchKeyword!;
      cubit.updateFilter('search_query', widget.initialSearchKeyword);
      _searchController.text = widget.initialSearchKeyword!;
    }

    // Handle filter by today
    if (widget.filterByToday) {
      final now = DateTime.now();
      _selectedRange = DateTimeRange(start: now, end: now);
      cubit.updateFilter('date_range', _dateFilterValue);
    }

    // Handle staff filter
    if (widget.staff != null && widget.staff!.role != Role.admin) {
      cubit.updateFilter('user_id', widget.staff!.id);
    }

    cubit.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final chairCubit = context.read<ChairCubit>();

    List<StaffModel> staffListAll = List<StaffModel>.from(chairCubit.staffs);

    List<StaffModel> staffList = staffListAll
        .where((element) => element.role != Role.admin)
        .toList();

    bool isStaffFilterEnabled = true;
    int? initialStaffId;

    if (widget.staff != null && widget.staff!.role != Role.admin) {
      isStaffFilterEnabled = false;
      initialStaffId = widget.staff!.id;
    }

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
                            key: _filterKey,
                            label: "Staff Name",
                            items: staffList,
                            initialValue: initialStaffId,
                            enabled: isStaffFilterEnabled,
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
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => _showDateSelectionOptions(context),
                            child: ReportFilterItem(
                              label: "Filter By Date",
                              initialValue: _dateLabel,
                              items: const [],
                              icon: Icons.calendar_today,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ReportFilterItem(
                            key: ValueKey('paid_$_filterKey'),
                            label: "Paid Status",
                            initialValue: "All",
                            items: const ["All", "Full", "Unpaid", "Partial"],
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
                            key: ValueKey('order_$_filterKey'),
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
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedRange = null;
                                  _filterKey =
                                      UniqueKey(); // Force rebuild of filters
                                });
                                context.read<ReportCubit>().resetFilters();
                                // Re-apply staff filter if not admin
                                if (widget.staff != null &&
                                    widget.staff!.role != Role.admin) {
                                  context.read<ReportCubit>().updateFilter(
                                    'user_id',
                                    widget.staff!.id,
                                  );
                                }
                                context.read<ReportCubit>().fetchTransactions();
                              },
                              child: const ReportActionButton(
                                label: "Reset",
                                bgColor: Colors.red,
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
                    Expanded(child: ReportDataTable()),
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
