class TransactionServiceEntity {
  final int? id;
  final int? transactionId;
  final int? serviceId;
  final int? quantity;
  final double? rate;
  final double? tax;
  final double? taxAmount;
  final double? subTotal;
  final double? amountTotal;
  final int? isTip;

  TransactionServiceEntity({
    this.id,
    this.transactionId,
    this.serviceId,
    this.quantity,
    this.rate,
    this.tax,
    this.taxAmount,
    this.subTotal,
    this.amountTotal,
    this.isTip,
  });

  factory TransactionServiceEntity.fromJson(Map<String, dynamic> json) {
    return TransactionServiceEntity(
      id: json['id'] as int?,
      transactionId: json['transaction_id'] as int?,
      serviceId: json['service_id'] as int?,
      quantity: json['quantity'] as int?,
      rate: (json['rate'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      taxAmount: (json['tax_amount'] as num?)?.toDouble(),
      subTotal: (json['sub_total'] as num?)?.toDouble(),
      amountTotal: (json['amount_total'] as num?)?.toDouble(),
      isTip: json['is_tip'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'service_id': serviceId,
      'quantity': quantity,
      'rate': rate,
      'tax': tax,
      'tax_amount': taxAmount,
      'sub_total': subTotal,
      'amount_total': amountTotal,
      'is_tip': isTip,
    };
  }
}
