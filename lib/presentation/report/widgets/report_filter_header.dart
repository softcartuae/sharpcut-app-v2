import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/presentation/report/cubit/report_cubit.dart';
import 'package:sharp_cut/presentation/report/widgets/date_range_picker_helper.dart';
import 'package:sharp_cut/presentation/report/widgets/report_action_button.dart';
import 'package:sharp_cut/presentation/report/widgets/report_filter_item.dart';
import 'package:sharp_cut/presentation/report/widgets/staff_filter_item.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

class ReportFilterHeader extends StatefulWidget {
  final StaffModel? staff;
  final String? initialSearchKeyword;
  final bool filterByToday;

  const ReportFilterHeader({
    super.key,
    this.staff,
    this.initialSearchKeyword,
    this.filterByToday = false,
  });

  @override
  State<ReportFilterHeader> createState() => _ReportFilterHeaderState();
}

class _ReportFilterHeaderState extends State<ReportFilterHeader> {
  final ValueNotifier<DateTimeRange?> _selectedRangeNotifier = ValueNotifier<DateTimeRange?>(null);
  final ValueNotifier<int> _resetCounterNotifier = ValueNotifier<int>(0);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReportCubit>();

    if (widget.initialSearchKeyword != null &&
        widget.initialSearchKeyword!.isNotEmpty) {
      _searchController.text = widget.initialSearchKeyword!;
      cubit.updateFilter('search_query', widget.initialSearchKeyword);
    }

    if (widget.filterByToday) {
      final now = DateTime.now();
      _selectedRangeNotifier.value = DateTimeRange(start: now, end: now);
      cubit.updateFilter(
        'date_range',
        DateRangePickerHelper.formatDateRangeString(_selectedRangeNotifier.value),
      );
    }

    if (widget.staff != null && widget.staff!.role != Role.admin) {
      cubit.updateFilter('user_id', widget.staff!.id);
    }

    cubit.fetchTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _selectedRangeNotifier.dispose();
    _resetCounterNotifier.dispose();
    super.dispose();
  }

  void _onDateTap() async {
    final picked = await DateRangePickerHelper.showDateSelectionOptions(
      context,
      currentRange: _selectedRangeNotifier.value,
    );
    if (!mounted) return;
    _selectedRangeNotifier.value = picked;
    context.read<ReportCubit>().updateFilter(
          'date_range',
          DateRangePickerHelper.formatDateRangeString(picked),
        );
  }

  void _onReset() {
    _searchController.clear();
    _selectedRangeNotifier.value = null;
    _resetCounterNotifier.value++;

    final cubit = context.read<ReportCubit>();
    cubit.resetFilters();

    if (widget.staff != null && widget.staff!.role != Role.admin) {
      cubit.updateFilter('user_id', widget.staff!.id);
    }
    cubit.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final chairCubit = context.read<ChairCubit>();
    final List<StaffModel> staffList = List<StaffModel>.from(chairCubit.staffs)
        .where((element) => element.role != Role.admin)
        .toList();

    bool isStaffFilterEnabled = true;
    int? initialStaffId;

    if (widget.staff != null && widget.staff!.role != Role.admin) {
      isStaffFilterEnabled = false;
      initialStaffId = widget.staff!.id;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Staff Filter
        Expanded(
          flex: 2,
          child: ValueListenableBuilder<int>(
            valueListenable: _resetCounterNotifier,
            builder: (context, resetCounter, child) {
              return StaffFilterItem(
                key: ValueKey('staff_$resetCounter'),
                label: "Staff Name",
                items: staffList,
                initialValue: initialStaffId,
                enabled: isStaffFilterEnabled,
                onChanged: (int? staffId) {
                  context.read<ReportCubit>().updateFilter('user_id', staffId);
                },
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // Date Range Picker Filter
        Expanded(
          flex: 2,
          child: ValueListenableBuilder<DateTimeRange?>(
            valueListenable: _selectedRangeNotifier,
            builder: (context, range, child) {
              return GestureDetector(
                onTap: _onDateTap,
                child: ReportFilterItem(
                  label: "Filter By Date",
                  initialValue: DateRangePickerHelper.formatDateLabel(range),
                  items: const [],
                  icon: Icons.calendar_today,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // Paid Status Filter
        Expanded(
          flex: 2,
          child: ValueListenableBuilder<int>(
            valueListenable: _resetCounterNotifier,
            builder: (context, resetCounter, child) {
              return ReportFilterItem(
                key: ValueKey('paid_$resetCounter'),
                label: "Paid Status",
                initialValue: "All",
                items: const ["All", "Paid", "Unpaid", "Partial"],
                onChanged: (value) {
                  final String filterValue = value == "Paid" ? "Full" : value;
                  context.read<ReportCubit>().updateFilter('paid_status', filterValue);
                },
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // Keyword Search
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
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchController,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Search here..",
                    hintStyle: GoogleFonts.rajdhani(color: Colors.grey),
                    suffixIcon: const Icon(Icons.search, size: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Colors.black, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Search Button
        GestureDetector(
          onTap: () {
            final cubit = context.read<ReportCubit>();
            cubit.updateFilter('search_query', _searchController.text);
            cubit.fetchTransactions();
          },
          child: const ReportActionButton(
            label: "Search",
            bgColor: Colors.blue,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),

        // Reset Button
        GestureDetector(
          onTap: _onReset,
          child: const ReportActionButton(
            label: "Reset",
            bgColor: Colors.red,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),

        // Close Screen Button
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.black),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
