import 'package:flutter/material.dart';
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
                            child: ListView.builder(
                              itemCount: 15,
                              itemBuilder: (context, index) {
                                return ReportTableRow(index: index);
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
        // Pagination
        // const ReportPagination(),
      ],
    );
  }
}
