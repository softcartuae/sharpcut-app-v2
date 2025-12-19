import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/widgets/home_appbar.dart';
import 'package:sharp_cut/presentation/report/widgets/report_filters.dart';
import 'package:sharp_cut/presentation/report/widgets/report_data_table.dart';

class ScreenReportTable extends StatelessWidget {
  const ScreenReportTable({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const ReportFilters(),
                    const SizedBox(height: 20),
                    Expanded(child: const ReportDataTable()),
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
