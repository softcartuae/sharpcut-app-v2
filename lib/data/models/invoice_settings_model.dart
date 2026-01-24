class InvoiceSettingsModel {
  final int? id;
  final String? invoicePrefix;
  final String? financialYear;
  final int? count;
  final String? createdAt;
  final String? updatedAt;

  InvoiceSettingsModel({
    this.id,
    this.invoicePrefix,
    this.financialYear,
    this.count,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceSettingsModel.fromJson(Map<String, dynamic> json) {
    return InvoiceSettingsModel(
      id: json['id'],
      invoicePrefix: json['invoice_prefix'],
      financialYear: json['financial_year'],
      count: json['count'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_prefix': invoicePrefix,
      'financial_year': financialYear,
      'count': count,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
