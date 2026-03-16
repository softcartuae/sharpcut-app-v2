class CustomerSuggestionModel {
  final String customerName;
  final String customerNumber;

  CustomerSuggestionModel({
    required this.customerName,
    required this.customerNumber,
  });

  factory CustomerSuggestionModel.fromJson(Map<String, dynamic> json) {
    return CustomerSuggestionModel(
      customerName: json['customer_name'] ?? '',
      customerNumber: json['customer_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'customer_name': customerName, 'customer_number': customerNumber};
  }
}
