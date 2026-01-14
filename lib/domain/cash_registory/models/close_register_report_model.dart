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
  });

  factory CloseRegisterReportModel.fromJson(Map<String, dynamic> json) {
    return CloseRegisterReportModel(
      totalSalesAmount: json['total_sales_amount'] ?? 0,
      totalSalesCount: json['total_sales_count'] ?? 0,
      expectedClosingAmount: json['expected_closing_amount'] ?? 0,
      discrepancy: json['discrepancy'] ?? 0,
      closedAt: json['closed_at'] ?? '',
      closedBy: json['closed_by'] ?? '',
      cashRegisterId: json['cash_register_id'] ?? 0,
      openingAmount: json['opening_amount'] ?? '',
      closingAmount: json['closing_amount'] ?? 0,
      openedAt: json['opened_at'] ?? '',
      openedBy: json['opened_by'] ?? '',
    );
  }
}
