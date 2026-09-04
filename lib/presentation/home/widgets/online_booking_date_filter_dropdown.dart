import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/utils/app_colors.dart';

enum DateFilterOption { all, today, yesterday, custom }

class OnlineBookingDateFilterDropdown extends StatelessWidget {
  final String? activeDateFilter;
  final ValueChanged<String?> onDateFilterChanged;

  const OnlineBookingDateFilterDropdown({
    super.key,
    required this.activeDateFilter,
    required this.onDateFilterChanged,
  });

  String _formatSingleDate(DateTime dt) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final formatted = formatter.format(dt);
    return "$formatted - $formatted";
  }

  String get _todayDateString => _formatSingleDate(DateTime.now());

  String get _yesterdayDateString =>
      _formatSingleDate(DateTime.now().subtract(const Duration(days: 1)));

  DateFilterOption get _activeOption {
    if (activeDateFilter == null || activeDateFilter!.isEmpty) {
      return DateFilterOption.all;
    }
    if (activeDateFilter == _todayDateString) {
      return DateFilterOption.today;
    }
    if (activeDateFilter == _yesterdayDateString) {
      return DateFilterOption.yesterday;
    }
    return DateFilterOption.custom;
  }

  String get _displayLabel {
    final option = _activeOption;
    switch (option) {
      case DateFilterOption.all:
        return "ALL DATES";
      case DateFilterOption.today:
        return "TODAY";
      case DateFilterOption.yesterday:
        return "YESTERDAY";
      case DateFilterOption.custom:
        if (activeDateFilter != null) {
          final parts = activeDateFilter!.split(' - ');
          if (parts.isNotEmpty) {
            return parts[0];
          }
        }
        return "CUSTOM DATE";
    }
  }

  Future<void> _pickCustomDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.violetNormal,
              onPrimary: Colors.white,
              surface: AppColors.surfaceLight,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateFilterChanged(_formatSingleDate(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeOption = _activeOption;
    final isCustom = activeOption == DateFilterOption.custom;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: activeOption != DateFilterOption.all
              ? AppColors.violetNormal.withValues(alpha: 0.4)
              : AppColors.borderMediumLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<DateFilterOption>(
        tooltip: "Filter by Date",
        offset: const Offset(0, 50),
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        onSelected: (option) {
          switch (option) {
            case DateFilterOption.all:
              onDateFilterChanged(null);
              break;
            case DateFilterOption.today:
              onDateFilterChanged(_todayDateString);
              break;
            case DateFilterOption.yesterday:
              onDateFilterChanged(_yesterdayDateString);
              break;
            case DateFilterOption.custom:
              _pickCustomDate(context);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<DateFilterOption>(
            value: DateFilterOption.all,
            child: Text(
              "ALL DATES",
              style: GoogleFonts.rajdhani(
                color: activeOption == DateFilterOption.all
                    ? AppColors.violetNormal
                    : AppColors.textPrimaryLight,
                fontWeight: activeOption == DateFilterOption.all
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          PopupMenuItem<DateFilterOption>(
            value: DateFilterOption.today,
            child: Text(
              "TODAY",
              style: GoogleFonts.rajdhani(
                color: activeOption == DateFilterOption.today
                    ? AppColors.violetNormal
                    : AppColors.textPrimaryLight,
                fontWeight: activeOption == DateFilterOption.today
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          PopupMenuItem<DateFilterOption>(
            value: DateFilterOption.yesterday,
            child: Text(
              "YESTERDAY",
              style: GoogleFonts.rajdhani(
                color: activeOption == DateFilterOption.yesterday
                    ? AppColors.violetNormal
                    : AppColors.textPrimaryLight,
                fontWeight: activeOption == DateFilterOption.yesterday
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          PopupMenuItem<DateFilterOption>(
            value: DateFilterOption.custom,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: isCustom
                      ? AppColors.violetNormal
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 8),
                Text(
                  isCustom ? "CUSTOM DATE ($_displayLabel)" : "CUSTOM DATE...",
                  style: GoogleFonts.rajdhani(
                    color: isCustom
                        ? AppColors.violetNormal
                        : AppColors.textPrimaryLight,
                    fontWeight: isCustom ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: activeOption != DateFilterOption.all
                  ? AppColors.violetNormal
                  : AppColors.textSecondaryLight,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _displayLabel,
              style: GoogleFonts.rajdhani(
                color: activeOption != DateFilterOption.all
                    ? AppColors.violetDark
                    : AppColors.textBodyLight,
                fontSize: 14,
                fontWeight: activeOption != DateFilterOption.all
                    ? FontWeight.bold
                    : FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondaryLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
