class SettlementFormState {
  final bool isCashSelected;
  final bool isCardSelected;
  final bool isWalletSelected;
  final bool splitPayment;

  final double amount;
  final double cashAmount;
  final double cardAmount;
  final double walletAmount;
  final double tenderCash;
  final double discount;
  final double subTotal;
  final double taxTotal;
  final double paidAmount;

  final double grossTotal;
  final double netTotal;
  final double curPayment;
  final double balance;
  final double change;
  final double walletBalance;

  final String? walletError;
  final String? overpayError;
  final bool isReSettlement;

  const SettlementFormState({
    this.isCashSelected = true,
    this.isCardSelected = false,
    this.isWalletSelected = false,
    this.splitPayment = false,
    this.amount = 0.0,
    this.cashAmount = 0.0,
    this.cardAmount = 0.0,
    this.walletAmount = 0.0,
    this.tenderCash = 0.0,
    this.discount = 0.0,
    this.subTotal = 0.0,
    this.taxTotal = 0.0,
    this.paidAmount = 0.0,
    this.grossTotal = 0.0,
    this.netTotal = 0.0,
    this.curPayment = 0.0,
    this.balance = 0.0,
    this.change = 0.0,
    this.walletBalance = 0.0,
    this.walletError,
    this.overpayError,
    this.isReSettlement = false,
  });

  SettlementFormState copyWith({
    bool? isCashSelected,
    bool? isCardSelected,
    bool? isWalletSelected,
    bool? splitPayment,
    double? amount,
    double? cashAmount,
    double? cardAmount,
    double? walletAmount,
    double? tenderCash,
    double? discount,
    double? subTotal,
    double? taxTotal,
    double? paidAmount,
    double? grossTotal,
    double? netTotal,
    double? curPayment,
    double? balance,
    double? change,
    double? walletBalance,
    String? walletError,
    String? overpayError,
    bool? isReSettlement,
  }) {
    return SettlementFormState(
      isCashSelected: isCashSelected ?? this.isCashSelected,
      isCardSelected: isCardSelected ?? this.isCardSelected,
      isWalletSelected: isWalletSelected ?? this.isWalletSelected,
      splitPayment: splitPayment ?? this.splitPayment,
      amount: amount ?? this.amount,
      cashAmount: cashAmount ?? this.cashAmount,
      cardAmount: cardAmount ?? this.cardAmount,
      walletAmount: walletAmount ?? this.walletAmount,
      tenderCash: tenderCash ?? this.tenderCash,
      discount: discount ?? this.discount,
      subTotal: subTotal ?? this.subTotal,
      taxTotal: taxTotal ?? this.taxTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      grossTotal: grossTotal ?? this.grossTotal,
      netTotal: netTotal ?? this.netTotal,
      curPayment: curPayment ?? this.curPayment,
      balance: balance ?? this.balance,
      change: change ?? this.change,
      walletBalance: walletBalance ?? this.walletBalance,
      walletError: walletError,
      overpayError: overpayError,
      isReSettlement: isReSettlement ?? this.isReSettlement,
    );
  }
}
