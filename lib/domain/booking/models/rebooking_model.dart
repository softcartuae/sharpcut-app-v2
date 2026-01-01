class ResettleModel {
  final int? transactionId;
  final List<int>? collectedUserId;
  final List<String>? mode;
  final List<double>? amount;
  final List<double>? tenderCash;
  final List<double>? change;

  ResettleModel({
    this.transactionId,
    this.collectedUserId,
    this.mode,
    this.amount,
    this.tenderCash,
    this.change,
  });

  Map<String, dynamic> toJson() {
    return {
      "transaction_id": transactionId,
      "collected_user_id": collectedUserId,
      "mode": mode,
      "amount": amount,
      "tender_cash": tenderCash,
      "change": change,
    };
  }
}
