class CloseRegisterModel {
  final num totalSales;
  final num openingAmount;
  final num expectedClosingAmount;

  CloseRegisterModel({
    required this.totalSales,
    required this.openingAmount,
    required this.expectedClosingAmount,
  });

  factory CloseRegisterModel.fromJson(Map<String, dynamic> json) {
    return CloseRegisterModel(
      totalSales: json['total_sales'] ?? 0,
      openingAmount: json['opening_amount'] ?? 0,
      expectedClosingAmount: json['expected_closing_amount'] ?? 0,
    );
  }
}
