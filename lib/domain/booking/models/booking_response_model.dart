class BookingResponseModel {
  final int? id;
  final String? appId;
  final int? chairId;
  final int? userId;
  final String? customerName;
  final String? customerNumber;
  final String? transactionDate;
  final String? invoiceNo;
  final String? invoiceDate;
  final String? status;
  final String? createdAt;

  BookingResponseModel({
    this.id,
    this.appId,
    this.chairId,
    this.userId,
    this.customerName,
    this.customerNumber,
    this.transactionDate,
    this.invoiceNo,
    this.invoiceDate,
    this.status,
    this.createdAt,
  });

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingResponseModel(
      id: json['id'],
      appId: json['app_id'],
      chairId: json['chair_id'],
      userId: json['user_id'],
      customerName: json['customer_name'],
      customerNumber: json['customer_number'],
      transactionDate: json['transaction_date'],
      invoiceNo: json['invoice_no'],
      invoiceDate: json['invoice_date'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
