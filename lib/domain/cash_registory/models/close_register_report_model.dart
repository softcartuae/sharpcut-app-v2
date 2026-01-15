import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';

class CloseRegisterReportModel {
  final num totalSalesAmount;
  final num totalSalesCount;
  final num expectedClosingAmount;
  final num discrepancy;
  final String closedAt;
  final String closedBy;
  final int cashRegisterId;
  final String openingAmount;
  final num closingAmount;
  final String openedAt;
  final String openedBy;
  final QuickReportModel? transactions;

  CloseRegisterReportModel({
    required this.totalSalesAmount,
    required this.totalSalesCount,
    required this.expectedClosingAmount,
    required this.discrepancy,
    required this.closedAt,
    required this.closedBy,
    required this.cashRegisterId,
    required this.openingAmount,
    required this.closingAmount,
    required this.openedAt,
    required this.openedBy,
    this.transactions,
  });

  factory CloseRegisterReportModel.fromJson(Map<String, dynamic> json) {
    final cashRegister = json['cash_register'] ?? {};
    final transactions = json['transactions'] != null
        ? QuickReportModel.fromJson(json['transactions'])
        : null;
    final totalSalesAmount =
        num.tryParse(cashRegister['total_sales_amount']?.toString() ?? '0') ??
        0;
    return CloseRegisterReportModel(
      totalSalesAmount: totalSalesAmount,
      totalSalesCount: cashRegister['total_sales_count'] ?? 0,
      expectedClosingAmount: cashRegister['expected_closing_amount'] ?? 0,
      discrepancy: cashRegister['discrepancy'] ?? 0,
      closedAt: cashRegister['closed_at'] ?? '',
      closedBy: cashRegister['closed_by'] ?? '',
      cashRegisterId: cashRegister['cash_register_id'] ?? 0,
      openingAmount: cashRegister['opening_amount'] ?? '',
      closingAmount: cashRegister['closing_amount'] ?? 0,
      openedAt: cashRegister['opened_at'] ?? '',
      openedBy: cashRegister['opened_by'] ?? '',
      transactions: transactions,
    );
  }
}
