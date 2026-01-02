class SettlePaymentRequestModel {
  final int? transactionId;
  final String? customerName;
  final String? customerNumber;
  final double? grandTotal;
  final double? taxTotal;
  final double? discount;
  final double? roundOff;
  final double? finalTotal;
  final List<int>? serviceId;
  final List<int>? quantity;
  final List<double>? rate;
  final List<double>? taxAmount;
  final List<String>? currency;
  final List<double>? amountTotal;
  final List<double>? tax;
  final List<double>? subTotal;
  final List<int>? isTip;
  final List<int>? collectedUserId;
  final List<String>? mode;
  final List<double>? amount;
  final List<double>? tenderCash;
  final List<double>? change;

  SettlePaymentRequestModel({
    this.transactionId,
    this.customerName,
    this.customerNumber,
    this.grandTotal,
    this.taxTotal,
    this.discount,
    this.roundOff,
    this.finalTotal,
    this.serviceId,
    this.quantity,
    this.rate,
    this.taxAmount,
    this.currency,
    this.amountTotal,
    this.tax,
    this.subTotal,
    this.isTip,
    this.collectedUserId,
    this.mode,
    this.amount,
    this.tenderCash,
    this.change,
  });

  Map<String, dynamic> toJson() {
    return {
      "transaction_id": transactionId,
      "customer_name": customerName,
      "customer_number": customerNumber,
      "grand_total": grandTotal,
      "tax_total": taxTotal,
      "discount": discount,
      "round_off": roundOff,
      "final_total": finalTotal,
      "service_id": serviceId,
      "quantity": quantity,
      "rate": rate,
      "tax_amount": taxAmount,
      "currency": currency,
      "amount_total": amountTotal,
      "tax": tax,
      "sub_total": subTotal,
      "is_tip": isTip,
      "collected_user_id": collectedUserId,
      "mode": mode,
      "amount": amount,
      "tender_cash": tenderCash,
      "change": change,
    };
  }
}
