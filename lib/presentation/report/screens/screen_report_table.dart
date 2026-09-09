import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/presentation/home/widgets/home_appbar.dart';
import 'package:sharp_cut/presentation/report/cubit/report_cubit.dart';
import 'package:sharp_cut/presentation/report/widgets/report_data_table.dart';
import 'package:sharp_cut/presentation/report/widgets/report_filter_header.dart';

class ScreenReportTable extends StatelessWidget {
  final StaffModel? staff;
  final String? initialSearchKeyword;
  final bool filterByToday;

  const ScreenReportTable({
    super.key,
    this.staff,
    this.initialSearchKeyword,
    this.filterByToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            BlocListener<BookingCubit, BookingState>(
              listener: (context, state) {
                if (state is BookingPaymentSettled) {
                  context.read<ReportCubit>().fetchTransactions();
                }
              },
              child: const HomeAppBar(),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ReportFilterHeader(
                      staff: staff,
                      initialSearchKeyword: initialSearchKeyword,
                      filterByToday: filterByToday,
                    ),
                    const SizedBox(height: 10),
                    Expanded(child: ReportDataTable(staff: staff)),
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
