class QuickReportModel {
  final String salonName;
  final String branch;
  final String dateRange;
  final String printDatetime;
  final Map<String, dynamic> invoiceDetails;
  final num cashCustomerCount;
  final String cashCustomerAmount;
  final num cardCustomerCount;
  final String cardCustomerAmount;
  final List<SalesmanWiseDetail> salesmanWiseDetails;
  final num salesmanTotalAmount;
  final num salesmanTotalCount;
  final ExpenseDetailsModel expenseDetails;

  QuickReportModel({
    required this.salonName,
    required this.branch,
    required this.dateRange,
    required this.printDatetime,
    required this.invoiceDetails,
    required this.cashCustomerCount,
    required this.cashCustomerAmount,
    required this.cardCustomerCount,
    required this.cardCustomerAmount,
    required this.salesmanWiseDetails,
    required this.salesmanTotalAmount,
    required this.salesmanTotalCount,
    required this.expenseDetails,
  });

  factory QuickReportModel.fromJson(Map<String, dynamic> json) {
    return QuickReportModel(
      salonName: json['salon_name'] ?? '',
      branch: json['branch'] ?? '',
      dateRange: json['date_range'] ?? '',
      printDatetime: json['print_datetime'] ?? '',
      invoiceDetails: json['invoice_details'] ?? {},
      cashCustomerCount:
          json['customer_type_details']?['cash_customer_count'] ?? 0,
      cashCustomerAmount:
          json['customer_type_details']?['cash_customer_amount']?.toString() ??
          '0.00',
      cardCustomerCount:
          json['customer_type_details']?['card_customer_count'] ?? 0,
      cardCustomerAmount:
          json['customer_type_details']?['card_customer_amount']?.toString() ??
          '0.00',
      salesmanWiseDetails:
          (json['salesman_wise_details'] as List?)
              ?.map((e) => SalesmanWiseDetail.fromJson(e))
              .toList() ??
          [],
      salesmanTotalAmount:
          json['salesman_totals']?['salesman_total_amount'] ?? 0,
      salesmanTotalCount: json['salesman_totals']?['salesman_total_count'] ?? 0,
      expenseDetails: ExpenseDetailsModel.fromJson(
        json['expense_details'] ?? {},
      ),
    );
  }
}

class ExpenseDetailsModel {
  final num totalShopExpense;
  final num totalUserExpense;

  ExpenseDetailsModel({
    required this.totalShopExpense,
    required this.totalUserExpense,
  });

  factory ExpenseDetailsModel.fromJson(Map<String, dynamic> json) {
    return ExpenseDetailsModel(
      totalShopExpense: json['total_shop_expense'] ?? 0,
      totalUserExpense: json['total_user_expense'] ?? 0,
    );
  }
}

class SalesmanWiseDetail {
  final String salesmanName;
  final String totalCashAmount;
  final String totalCardAmount;

  SalesmanWiseDetail({
    required this.salesmanName,
    required this.totalCashAmount,
    required this.totalCardAmount,
  });

  factory SalesmanWiseDetail.fromJson(Map<String, dynamic> json) {
    return SalesmanWiseDetail(
      salesmanName: json['salesman_name'] ?? '',
      totalCashAmount: json['total_cash_amount']?.toString() ?? '0.00',
      totalCardAmount: json['total_card_amount']?.toString() ?? '0.00',
    );
  }
}
