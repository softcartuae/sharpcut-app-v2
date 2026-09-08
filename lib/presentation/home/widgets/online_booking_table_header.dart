import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/widgets/table_header_cell.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class OnlineBookingTableHeader extends StatelessWidget {
    final bool staffwise;

  const OnlineBookingTableHeader({super.key,this.staffwise = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.headerLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderLight,
        ),
      ),
      child:  Row(
        children: [
          TableHeaderCell(label: "CUSTOMER", flex: 3),
          TableHeaderCell(label: "DATE & TIME", flex: 3),
        if(staffwise == false)   TableHeaderCell(label: "STYLIST", flex: 2),
          TableHeaderCell(label: "SERVICES", flex: 3),
          TableHeaderCell(label: "TOTAL", flex: 2),
          TableHeaderCell(
            label: "STATUS",
            flex: 2,
            alignment: Alignment.center,
          ),
          TableHeaderCell(
            label: "ACTION",
            flex: 3,
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }
}
