class SettlePaymentRequestModel {
  final int? transactionId;
  final String? customerName;
  final String? customerNumber;
  final double? subTotalValue;
  final double? taxTotal;
  final String? paymentStatus;
  final double? discount;
  final double? roundOff;
  final double? finalTotal;
  final double? finalTotalbefore;
  final List<int>? serviceId;
  final List<int>? quantity;
  final List<double>? rate;
  final List<double>? taxAmount;
  final List<String>? currency;
  final List<double>? amountTotal;
  final List<double>? tax;
  final List<double>? subTotalList;
  final List<int>? isTip;
  final List<int>? collectedUserId;
  final List<String>? mode;
  final List<double>? amount;
  final List<double>? tenderCash;
  final List<double>? change;
  final double? grandTotalAfter;
  final double? taxTotalAfter;

  SettlePaymentRequestModel({
    required this.finalTotalbefore,
    this.paymentStatus,
    this.transactionId,
    this.customerName,
    this.customerNumber,
    this.subTotalValue,
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
    this.subTotalList,
    this.isTip,
    this.collectedUserId,
    this.mode,
    this.amount,
    this.tenderCash,
    this.change,
    this.grandTotalAfter,
    this.taxTotalAfter,
  });

  SettlePaymentRequestModel copyWith({
    int? transactionId,
    String? customerName,
    String? customerNumber,
    double? subTotalValue,
    double? taxTotal,
    String? paymentStatus,
    double? discount,
    double? roundOff,
    double? finalTotal,
    double? finalTotalbefore,
    List<int>? serviceId,
    List<int>? quantity,
    List<double>? rate,
    List<double>? taxAmount,
    List<String>? currency,
    List<double>? amountTotal,
    List<double>? tax,
    List<double>? subTotalList,
    List<int>? isTip,
    List<int>? collectedUserId,
    List<String>? mode,
    List<double>? amount,
    List<double>? tenderCash,
    List<double>? change,
  }) {
    return SettlePaymentRequestModel(
      transactionId: transactionId ?? this.transactionId,
      customerName: customerName ?? this.customerName,
      customerNumber: customerNumber ?? this.customerNumber,
      subTotalValue: subTotalValue ?? this.subTotalValue,
      taxTotal: taxTotal ?? this.taxTotal,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      discount: discount ?? this.discount,
      roundOff: roundOff ?? this.roundOff,
      finalTotal: finalTotal ?? this.finalTotal,
      finalTotalbefore: finalTotalbefore ?? this.finalTotalbefore,
      serviceId: serviceId ?? this.serviceId,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      taxAmount: taxAmount ?? this.taxAmount,
      currency: currency ?? this.currency,
      amountTotal: amountTotal ?? this.amountTotal,
      tax: tax ?? this.tax,
      subTotalList: subTotalList ?? this.subTotalList,
      isTip: isTip ?? this.isTip,
      collectedUserId: collectedUserId ?? this.collectedUserId,
      mode: mode ?? this.mode,
      amount: amount ?? this.amount,
      tenderCash: tenderCash ?? this.tenderCash,
      change: change ?? this.change,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "transaction_id": transactionId,
      "customer_name": customerName,
      "customer_number": customerNumber,
      "grand_total": subTotalValue,
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
      "sub_total": subTotalList,
      "is_tip": isTip,
      "collected_user_id": collectedUserId,
      "mode": mode,
      "amount": amount,
      "tender_cash": tenderCash,
      "change": change,
    };
  }
}
