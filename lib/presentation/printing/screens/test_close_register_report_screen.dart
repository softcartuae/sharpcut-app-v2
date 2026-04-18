import 'package:flutter/material.dart';

import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';
import 'package:sharp_cut/presentation/cash_registory/widgets/close_register_print_widget.dart';

import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';

class TestCloseRegisterReportScreen extends StatelessWidget {
  const TestCloseRegisterReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyShop = ShopModel(
      isVatIncluded: true,
      isChargeOrServiceCanEdit: true,
      name: 'TAJ SHALEELA SALON',
      address: 'Abu Dhabi _ U.A.E',
      vatNo: '104426133500003',
    );

    // Dummy Transaction Report Data (QuickReportModel)
    final dummyTransactionReport = QuickReportModel(
      expenseDetails: ExpenseDetailsModel(totalShopExpense: 0, totalUserExpense: 9),
      salonName: "TAJ SHALEELA Salon test1",
      branch: "MAIN",
      dateRange: "14/01/2026 - 14/01/2026",
      printDatetime: "14/01/2026 02:02 PM",
      invoiceDetails: {
        "total_invoice": 3,
        "total_invoice_sales_amount": 242,
        "total_unpaid_amount": 71,
        "gross_total_amount": 242,
        "total_discount": 0,
        "total_credit_amount": 0,
      },
      cashCustomerCount: 2,
      cashCustomerAmount: "171.00",
      cardCustomerCount: 1,
      cardCustomerAmount: "96.00",
      salesmanWiseDetails: [
        SalesmanWiseDetail(
          salesmanName: "Rashid",
          totalCashAmount: "171.00",
          totalCardAmount: "96.00",
        ),
        SalesmanWiseDetail(
          salesmanName: "Ramzan",
          totalCashAmount: "0",
          totalCardAmount: "0",
        ),
      ],
      salesmanTotalAmount: 267,
      salesmanTotalCount: 2,
    );

    // Dummy Close Register Report Data
    final dummyReport = CloseRegisterReportModel(
      cashRegisterId: 3,
      openedBy: "Rashid",
      closedBy: "Ashique",
      openingAmount: "300.00",
      closingAmount: 500,
      openedAt: "2026-01-14 13:52:02",
      closedAt: "2026-01-14T10:02:57.988569Z",
      totalSalesAmount: 0,
      totalSalesCount: 0,
      expectedClosingAmount: 300,
      discrepancy: 200,
      transactions: dummyTransactionReport,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Close Register Report'),
        backgroundColor: Colors.grey[200],
      ),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: CloseRegisterPrintWidget(
            report: dummyReport,
            shop: dummyShop,
            width: 370,
          ),
        ),
      ),
    );
  }
}
