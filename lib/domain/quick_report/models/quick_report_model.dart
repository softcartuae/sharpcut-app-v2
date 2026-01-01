class QuickReportModel {
  final String salonName;
  final String branch;
  final String dateRange;
  final String printDatetime;
  final num totalInvoice;
  final num totalInvoiceSalesAmount;
  final num totalUnpaidAmount;
  final num grossTotalAmount;
  final num totalDiscount;
  final num totalCreditAmount;
  final num cashCustomerCount;
  final String cashCustomerAmount;
  final num cardCustomerCount;
  final String cardCustomerAmount;
  final List<SalesmanWiseDetail> salesmanWiseDetails;
  final num salesmanTotalAmount;
  final num salesmanTotalCount;

  QuickReportModel({
    required this.salonName,
    required this.branch,
    required this.dateRange,
    required this.printDatetime,
    required this.totalInvoice,
    required this.totalInvoiceSalesAmount,
    required this.totalUnpaidAmount,
    required this.grossTotalAmount,
    required this.totalDiscount,
    required this.totalCreditAmount,
    required this.cashCustomerCount,
    required this.cashCustomerAmount,
    required this.cardCustomerCount,
    required this.cardCustomerAmount,
    required this.salesmanWiseDetails,
    required this.salesmanTotalAmount,
    required this.salesmanTotalCount,
  });

  factory QuickReportModel.fromJson(Map<String, dynamic> json) {
    return QuickReportModel(
      salonName: json['salon_name'] ?? '',
      branch: json['branch'] ?? '',
      dateRange: json['date_range'] ?? '',
      printDatetime: json['print_datetime'] ?? '',
      totalInvoice: json['total_invoice'] ?? 0,
      totalInvoiceSalesAmount: json['total_invoice_sales_amount'] ?? 0,
      totalUnpaidAmount: json['total_unpaid_amount'] ?? 0,
      grossTotalAmount: json['gross_total_amount'] ?? 0,
      totalDiscount: json['total_discount'] ?? 0,
      totalCreditAmount: json['total_credit_amount'] ?? 0,
      cashCustomerCount: json['cash_customer_count'] ?? 0,
      cashCustomerAmount: json['cash_customer_amount']?.toString() ?? '0.00',
      cardCustomerCount: json['card_customer_count'] ?? 0,
      cardCustomerAmount: json['card_customer_amount']?.toString() ?? '0.00',
      salesmanWiseDetails:
          (json['salesman_wise_details'] as List?)
              ?.map((e) => SalesmanWiseDetail.fromJson(e))
              .toList() ??
          [],
      salesmanTotalAmount: json['salesman_total_amount'] ?? 0,
      salesmanTotalCount: json['salesman_total_count'] ?? 0,
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
