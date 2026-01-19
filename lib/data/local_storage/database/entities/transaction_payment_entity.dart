class TransactionPaymentEntity {
  final int? id;
  final int? transactionId;
  final int? collectedUserId;
  final String? mode;
  final double? amount;
  final double? tenderCash;
  final double? change;
  final String? date;

  TransactionPaymentEntity({
    this.id,
    this.transactionId,
    this.collectedUserId,
    this.mode,
    this.amount,
    this.tenderCash,
    this.change,
    this.date,
  });

  factory TransactionPaymentEntity.fromJson(Map<String, dynamic> json) {
    return TransactionPaymentEntity(
      id: json['id'] as int?,
      transactionId: json['transaction_id'] as int?,
      collectedUserId: json['collected_user_id'] as int?,
      mode: json['mode'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      tenderCash: (json['tender_cash'] as num?)?.toDouble(),
      change: (json['change'] as num?)?.toDouble(),
      date: json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'collected_user_id': collectedUserId,
      'mode': mode,
      'amount': amount,
      'tender_cash': tenderCash,
      'change': change,
      'date': date,
    };
  }
}
