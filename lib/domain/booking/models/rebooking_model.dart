class ResettleModel {
  final int? transactionId;
  final int? onlineBookingId;
  final List<int>? collectedUserId;
  final List<String>? mode;
  final List<double>? amount;
  final List<double>? tenderCash;
  final List<double>? change;
  final double? discount;

  ResettleModel({
    this.discount,
    this.onlineBookingId,
    this.transactionId,
    this.collectedUserId,
    this.mode,
    this.amount,
    this.tenderCash,
    this.change,
  });

  Map<String, dynamic> toJson() {
    return {
      "online_booking_id": onlineBookingId,
      "transaction_id": transactionId,
      "collected_user_id": collectedUserId,
      "mode": mode,
      "amount": amount,
      "tender_cash": tenderCash,
      "change": change,
      "discount": discount,
    };
  }
}
