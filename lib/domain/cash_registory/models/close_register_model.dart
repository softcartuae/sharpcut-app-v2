class CloseRegisterModel {
  final num totalSales;
  final num openingAmount;
  final num expectedClosingAmount;
  final String? openingDate;

  CloseRegisterModel({
    required this.totalSales,
    required this.openingAmount,
    required this.expectedClosingAmount,
    required this.openingDate,
  });

  factory CloseRegisterModel.fromJson(Map<String, dynamic> json) {
    return CloseRegisterModel(
      openingDate: json['opening_datetime'] ?? '',
      totalSales: json['total_sales'] ?? 0,
      openingAmount: json['opening_amount'] ?? 0,
      expectedClosingAmount: json['expected_closing_amount'] ?? 0,
    );
  }
}
