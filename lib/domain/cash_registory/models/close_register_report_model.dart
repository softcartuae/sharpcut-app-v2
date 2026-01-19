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

  /// ✅ static so factory can use it
  static num numPars(dynamic value) {
    if (value == null) return 0;
    return num.tryParse(value.toString()) ?? 0;
  }

  factory CloseRegisterReportModel.fromJson(Map<String, dynamic> json) {
    final cashRegister = json['cash_register'] ?? {};

    return CloseRegisterReportModel(
      totalSalesAmount: numPars(cashRegister['total_sales_amount']),
      totalSalesCount: numPars(cashRegister['total_sales_count']),
      expectedClosingAmount: numPars(cashRegister['expected_closing_amount']),
      discrepancy: numPars(cashRegister['discrepancy']),
      closingAmount: numPars(cashRegister['closing_amount']),
      cashRegisterId: numPars(cashRegister['cash_register_id']).toInt(),

      // Strings (keep as-is)
      openingAmount: cashRegister['opening_amount']?.toString() ?? '',
      closedAt: cashRegister['closed_at'] ?? '',
      closedBy: cashRegister['closed_by'] ?? '',
      openedAt: cashRegister['opened_at'] ?? '',
      openedBy: cashRegister['opened_by'] ?? '',

      transactions: json['transactions'] != null
          ? QuickReportModel.fromJson(json['transactions'])
          : null,
    );
  }
}
