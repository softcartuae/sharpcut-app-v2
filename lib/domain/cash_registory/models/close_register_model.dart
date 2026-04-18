import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';

class CloseRegisterModel {
  final num totalSales;
  final num openingAmount;
  final num expectedClosingAmount;
  final String? openingDate;
  final ExpenseDetailsModel expenseDetails;

  CloseRegisterModel({
    required this.totalSales,
    required this.openingAmount,
    required this.expectedClosingAmount,
    required this.openingDate,
    required this.expenseDetails,
  });

  factory CloseRegisterModel.fromJson(Map<String, dynamic> json) {
    return CloseRegisterModel(
      openingDate: json['opening_datetime'] ?? '',
      totalSales: json['total_sales'] ?? 0,
      openingAmount: json['opening_amount'] ?? 0,
      expectedClosingAmount: json['expected_closing_amount'] ?? 0,
      expenseDetails: ExpenseDetailsModel.fromJson(
        json['expense_details'] ?? {},
      ),
    );
  }
}
