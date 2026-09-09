import 'package:flutter/material.dart';

abstract class DateRangePickerHelper {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String formatDateLabel(DateTimeRange? range) {
    if (range == null) {
      return "All";
    }
    final now = DateTime.now();
    if (isSameDay(range.start, now) && isSameDay(range.end, now)) {
      return "Today";
    }
    return formatDateRangeString(range);
  }

  static String formatDateRangeString(DateTimeRange? range) {
    if (range == null) {
      return "";
    }
    String format(DateTime d) =>
        "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";

    return "${format(range.start)} - ${format(range.end)}";
  }

  static Future<DateTimeRange?> showDateSelectionOptions(
    BuildContext context, {
    DateTimeRange? currentRange,
  }) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
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
      return null;
    } else if (result == 'Custom Date') {
      if (context.mounted) {
        return await pickDateRange(context, currentRange: currentRange);
      }
    }
    return currentRange;
  }

  static Future<DateTimeRange?> pickDateRange(
    BuildContext context, {
    DateTimeRange? currentRange,
  }) async {
    final now = DateTime.now();
    return await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: currentRange,
    );
  }
}
