import 'package:flutter/material.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';
import 'package:sharp_cut/presentation/quick_report/widgets/quick_report_print_widget.dart';

class TestQuickReportScreen extends StatelessWidget {
  const TestQuickReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Quick Report Data
    final dummyReport = QuickReportModel(
      salonName: 'TAJ SHALEELA SALON',
      branch: 'Abu Dhabi Branch',
      dateRange: '01/01/2026 - 03/01/2026',
      printDatetime: '03/01/2026 10:30 AM',
      totalInvoice: 15,
      totalInvoiceSalesAmount: 1500.00,
      totalUnpaidAmount: 50.00,
      grossTotalAmount: 1550.00,
      totalDiscount: 100.00,
      totalCreditAmount: 0.00,
      cashCustomerCount: 10,
      cashCustomerAmount: '1000.00',
      cardCustomerCount: 5,
      cardCustomerAmount: '500.00',
      salesmanWiseDetails: [
        SalesmanWiseDetail(
          salesmanName: 'Ahmed',
          totalCashAmount: '500.00',
          totalCardAmount: '200.00',
        ),
        SalesmanWiseDetail(
          salesmanName: 'Mohammed',
          totalCashAmount: '300.00',
          totalCardAmount: '150.00',
        ),
        SalesmanWiseDetail(
          salesmanName: 'Ali',
          totalCashAmount: '200.00',
          totalCardAmount: '150.00',
        ),
      ],
      salesmanTotalAmount: 1500.00,
      salesmanTotalCount: 15,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Quick Report Widget'),
        backgroundColor: Colors.grey[200],
      ),
      backgroundColor:
          Colors.grey[300], // Darker background to see the receipt clearly
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: QuickReportPrintWidget(report: dummyReport),
        ),
      ),
    );
  }
}
