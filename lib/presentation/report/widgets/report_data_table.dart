import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/presentation/report/cubit/report_cubit.dart';
import 'package:sharp_cut/presentation/report/widgets/report_table_header.dart';
import 'package:sharp_cut/presentation/report/widgets/report_table_row.dart';

class ReportDataTable extends StatelessWidget {
  const ReportDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
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
                          Expanded(
                            child: BlocBuilder<ReportCubit, ReportState>(
                              builder: (context, state) {
                                if (state is ReportLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (state is ReportFailure) {
                                  return Center(
                                    child: Text('Error: ${state.message}'),
                                  );
                                } else if (state is ReportSuccess) {
                                  if (state.transactions.isEmpty) {
                                    return const Center(
                                      child: Text('No transactions found'),
                                    );
                                  }
                                  return ListView.builder(
                                    itemCount: state.transactions.length,
                                    itemBuilder: (context, index) {
                                      return ReportTableRow(
                                        transaction: state.transactions[index],
                                        index: index,
                                      );
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
