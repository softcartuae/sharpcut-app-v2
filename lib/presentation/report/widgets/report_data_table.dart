import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/presentation/report/cubit/report_cubit.dart';
import 'package:sharp_cut/presentation/report/widgets/report_dialog_helper.dart';
import 'package:sharp_cut/presentation/report/widgets/report_table_header.dart';
import 'package:sharp_cut/presentation/report/widgets/report_table_row.dart';

class ReportDataTable extends StatefulWidget {
  const ReportDataTable({super.key, this.staff});

  final StaffModel? staff;

  @override
  State<ReportDataTable> createState() => _ReportDataTableState();
}

class _ReportDataTableState extends State<ReportDataTable> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _verticalScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _verticalScrollController.removeListener(_onScroll);
    _verticalScrollController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_verticalScrollController.hasClients &&
        _verticalScrollController.position.pixels >=
            _verticalScrollController.position.maxScrollExtent - 200) {
      context.read<ReportCubit>().fetchMoreTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                              maxHeight: constraints.maxHeight,
                            ),
                            child: SizedBox(
                              width: 1500,
                              child: Column(
                                children: [
                                  // Header Row
                                  const ReportTableHeader(),
                                  // Data Rows
                                  if (state is ReportSuccess &&
                                      state.transactions.isNotEmpty)
                                    Expanded(
                                      child: ListView.builder(
                                        controller: _verticalScrollController,
                                        padding: EdgeInsets.zero,
                                        itemCount: state.transactions.length +
                                            (state.isLoadingMore ? 1 : 0),
                                        itemBuilder: (context, index) {
                                          if (index ==
                                              state.transactions.length) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 16,
                                              ),
                                              alignment: Alignment.center,
                                              child: const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                ),
                                              ),
                                            );
                                          }

                                          final booking =
                                              state.transactions[index];

                                          return ReportTableRow(
                                            paymentSettleFunction: () =>
                                                ReportDialogHelper
                                                    .showPaymentDetails(
                                              context,
                                              booking: booking,
                                            ),
                                            onBalanceTap: () =>
                                                ReportDialogHelper
                                                    .showResettlement(
                                              context,
                                              booking: booking,
                                              staff: widget.staff,
                                            ),
                                            onCustomerNameTap: () =>
                                                ReportDialogHelper
                                                    .showEditCustomerName(
                                              context,
                                              booking: booking,
                                            ),
                                            printTheInvoice: () =>
                                                ReportDialogHelper.printInvoice(
                                              context,
                                              booking: booking,
                                            ),
                                            viewFunction: () =>
                                                ReportDialogHelper.showReceipt(
                                              context,
                                              booking: booking,
                                            ),
                                            transaction: booking,
                                            index: index,
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (state is ReportLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (state is ReportFailure)
                        const Center(child: Text('Something went wrong'))
                      else if (state is ReportSuccess &&
                          state.transactions.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions found',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}


