import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';
import 'package:sharp_cut/presentation/cash_registory/widgets/close_register_print_widget.dart';

class TestCloseRegisterReportScreen extends StatelessWidget {
  const TestCloseRegisterReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyShop = ShopModel(
      name: 'TAJ SHALEELA SALON',
      address: 'Abu Dhabi _ U.A.E',
      vatNo: '104426133500003',
      startTime: '09:00',
      endTime: '22:00',
    );

    // Dummy Close Register Report Data
    final dummyReport = CloseRegisterReportModel(
      cashRegisterId: 6,
      openedBy: "Rashid",
      closedBy: "Ashique",
      openingAmount: "200.00",
      closingAmount: 500,
      openedAt: "2026-01-13 16:18:28",
      closedAt: "2026-01-13T12:18:45.250580Z",
      totalSalesAmount: 0,
      totalSalesCount: 0,
      expectedClosingAmount: 200,
      discrepancy: 300,
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
          child: CloseRegisterPrintWidget(report: dummyReport, shop: dummyShop),
        ),
      ),
    );
  }
}
