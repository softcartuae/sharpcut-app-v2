import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/presentation/report/widgets/report_filter_item.dart';
import 'package:sharp_cut/presentation/report/widgets/report_action_button.dart';

class ReportFilters extends StatelessWidget {
  const ReportFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Row of Filters
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const ReportFilterItem(
              label: "Staff Name",
              initialValue: "Select",
              items: ["Select", "Ashraf", "Benjamin", "John Doe", "Jane Smith"],
              flex: 2,
            ),
            const SizedBox(width: 16),
            const ReportFilterItem(
              label: "Filter Branch",
              initialValue: "MAIN",
              items: ["MAIN", "Branch 1", "Branch 2", "Downtown"],
              flex: 2,
            ),
            const SizedBox(width: 16),
            const ReportFilterItem(
              label: "Filter Branch", // Label from image, likely Date Range
              initialValue: "07-06-2024 07:00AM To 08-06-2024 06:00 AM",
              items: [
                "07-06-2024 07:00AM To 08-06-2024 06:00 AM",
                "Today",
                "Yesterday",
                "Last 7 Days",
                "Last 30 Days",
              ],
              flex: 4,
              icon: Icons.calendar_today,
            ),
            const SizedBox(width: 16),
            const ReportFilterItem(
              label: "Paid Status",
              initialValue: "All",
              items: ["All", "Paid", "Unpaid", "Partial"],
              flex: 2,
            ),
            const SizedBox(width: 16),
            const ReportFilterItem(
              label: "Order Status",
              initialValue: "All",
              items: ["All", "Completed", "Pending", "Cancelled"],
              flex: 2,
            ),
            const SizedBox(width: 16),
            const ReportActionButton(
              label: "Search",
              bgColor: Colors.blue,
              textColor: Colors.white,
            ),
            const SizedBox(width: 16),
            const ReportActionButton(
              label: "Print",
              bgColor: Colors.black,
              textColor: Colors.white,
              icon: Icons.print,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Bottom Row of Filters
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const ReportFilterItem(
              label: "Show Entries",
              initialValue: "15",
              items: ["10", "15", "25", "50", "100"],
              flex: 1,
            ),
            const SizedBox(width: 16),
            const ReportFilterItem(
              label: "Customer Type",
              initialValue: "All",
              items: ["All", "New", "Returning", "VIP"],
              flex: 2,
            ),
            const SizedBox(width: 16),
            const ReportFilterItem(
              label: "Delivery Type",
              initialValue: "All",
              items: ["All", "Pickup", "Delivery"],
              flex: 2,
            ),
            const SizedBox(width: 16),
            const ReportFilterItem(
              label: "Payment Type",
              initialValue: "All",
              items: ["All", "Cash", "Card", "Online"],
              flex: 2,
            ),
            const Spacer(),
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
                    decoration: InputDecoration(
                      hintText: "Search here..",
                      hintStyle: GoogleFonts.rajdhani(color: Colors.grey),
                      suffixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Colors.grey),
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
          ],
        ),
      ],
    );
  }
}
