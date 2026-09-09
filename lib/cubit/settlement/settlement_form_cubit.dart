import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/settlement/settlement_form_state.dart';
import 'package:sharp_cut/utils/helpers/settlement_calculator.dart';

class SettlementFormCubit extends Cubit<SettlementFormState> {
  SettlementFormCubit() : super(const SettlementFormState());

  void initForm({
    required double subTotal,
    required double taxTotal,
    required double discount,
    required double initialFinalTotal,
    required double walletBalance,
    required bool isReSettlement,
    required double paidAmount,
    required double initialBalance,
  }) {
    final double grossTotal = isReSettlement
        ? initialFinalTotal
        : SettlementCalculator.calculateGrossTotal(
            subTotal: subTotal,
            taxTotal: taxTotal,
          );

    final double netTotal = SettlementCalculator.calculateNetTotal(
      grossTotal: grossTotal,
      discount: discount,
    );

    final double amountVal = isReSettlement
        ? initialBalance
        : (netTotal < 0 ? 0.0 : netTotal);

    final double cashAmt = amountVal;
    const double cardAmt = 0.0;
    const double walletAmt = 0.0;

    final double curPayment = SettlementCalculator.calculateCurrentPayment(
      cashAmount: cashAmt,
      cardAmount: cardAmt,
      walletAmount: walletAmt,
    );

    final double balance = SettlementCalculator.calculateBalance(
      grossTotal: grossTotal,
      discount: discount,
      alreadyPaid: paidAmount,
      curPayment: curPayment,
    );

    final String? walletErr = SettlementCalculator.validateWalletAmount(
      enteredWallet: walletAmt,
      availableWallet: walletBalance,
    );

    final double totalPaidEffective = isReSettlement
        ? (curPayment + paidAmount)
        : curPayment;

    final String? overpayErr = SettlementCalculator.validateOverpayment(
      paid: totalPaidEffective,
      discount: discount,
      finalTotal: grossTotal,
    );

    emit(
      SettlementFormState(
        subTotal: subTotal,
        taxTotal: taxTotal,
        discount: discount,
        grossTotal: grossTotal,
        netTotal: netTotal,
        paidAmount: paidAmount,
        walletBalance: walletBalance,
        isReSettlement: isReSettlement,
        isCashSelected: true,
        isCardSelected: false,
        isWalletSelected: false,
        splitPayment: false,
        amount: amountVal,
        cashAmount: cashAmt,
        cardAmount: cardAmt,
        walletAmount: walletAmt,
        curPayment: curPayment,
        balance: balance,
        change: 0.0,
        walletError: walletErr,
        overpayError: overpayErr,
      ),
    );
  }

  void selectCashCardWallet({
    required bool isCash,
    required bool isCard,
    required bool isWallet,
  }) {
    if (state.splitPayment) {
      // Allow multi-selection in split payment, ensure at least one is selected
      if (!isCash && !isCard && !isWallet) return;
      _recalculateState(
        isCashSelected: isCash,
        isCardSelected: isCard,
        isWalletSelected: isWallet,
      );
    } else {
      // Single selection mode
      _recalculateState(
        isCashSelected: isCash,
        isCardSelected: isCard,
        isWalletSelected: isWallet,
      );
    }
  }

  void toggleSplitPayment(bool isSplit) {
    if (!isSplit) {
      _recalculateState(
        splitPayment: false,
        isCashSelected: true,
        isCardSelected: false,
        isWalletSelected: false,
        cashAmount: state.amount,
        cardAmount: 0.0,
        walletAmount: 0.0,
      );
    } else {
      _recalculateState(
        splitPayment: true,
        cashAmount: state.amount,
        cardAmount: 0.0,
        walletAmount: 0.0,
      );
    }
  }

  void updateAmount(double val) {
    _recalculateState(
      amount: val,
      cashAmount: state.isCashSelected ? val : state.cashAmount,
      cardAmount: state.isCardSelected ? val : state.cardAmount,
      walletAmount: state.isWalletSelected ? val : state.walletAmount,
    );
  }

  void updateCashAmount(double val) {
    _recalculateState(cashAmount: val);
  }

  void updateCardAmount(double val) {
    _recalculateState(cardAmount: val);
  }

  void updateWalletAmount(double val) {
    _recalculateState(walletAmount: val);
  }

  void updateDiscount(double val) {
    _recalculateState(discount: val);
  }

  void updateTenderCash(double val) {
    _recalculateState(tenderCash: val);
  }

  void _recalculateState({
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
  }) {
    final newIsCash = isCashSelected ?? state.isCashSelected;
    final newIsCard = isCardSelected ?? state.isCardSelected;
    final newIsWallet = isWalletSelected ?? state.isWalletSelected;
    final newSplit = splitPayment ?? state.splitPayment;

    final newAmount = amount ?? state.amount;
    double newCash = cashAmount ?? state.cashAmount;
    double newCard = cardAmount ?? state.cardAmount;
    double newWallet = walletAmount ?? state.walletAmount;
    final newTender = tenderCash ?? state.tenderCash;
    final newDiscount = discount ?? state.discount;

    if (!newSplit) {
      if (newIsCash) {
        newCash = newAmount;
        newCard = 0.0;
        newWallet = 0.0;
      } else if (newIsCard) {
        newCash = 0.0;
        newCard = newAmount;
        newWallet = 0.0;
      } else if (newIsWallet) {
        newCash = 0.0;
        newCard = 0.0;
        newWallet = newAmount;
      }
    } else {
      if (!newIsCash) newCash = 0.0;
      if (!newIsCard) newCard = 0.0;
      if (!newIsWallet) newWallet = 0.0;
    }

    final double grossTotal = state.grossTotal;
    final double netTotal = SettlementCalculator.calculateNetTotal(
      grossTotal: grossTotal,
      discount: newDiscount,
    );

    final double curPayment = SettlementCalculator.calculateCurrentPayment(
      cashAmount: newCash,
      cardAmount: newCard,
      walletAmount: newWallet,
    );

    final double balance = SettlementCalculator.calculateBalance(
      grossTotal: grossTotal,
      discount: newDiscount,
      alreadyPaid: state.paidAmount,
      curPayment: curPayment,
    );

    final double change = SettlementCalculator.calculateTenderChange(
      tenderCash: newTender,
      cashAmount: newCash,
    );

    final String? walletErr = SettlementCalculator.validateWalletAmount(
      enteredWallet: newWallet,
      availableWallet: state.walletBalance,
    );

    final double totalPaidEffective = state.isReSettlement
        ? (curPayment + state.paidAmount)
        : curPayment;

    final String? overpayErr = SettlementCalculator.validateOverpayment(
      paid: totalPaidEffective,
      discount: newDiscount,
      finalTotal: grossTotal,
    );

    emit(
      state.copyWith(
        isCashSelected: newIsCash,
        isCardSelected: newIsCard,
        isWalletSelected: newIsWallet,
        splitPayment: newSplit,
        amount: newAmount,
        cashAmount: newCash,
        cardAmount: newCard,
        walletAmount: newWallet,
        tenderCash: newTender,
        discount: newDiscount,
        netTotal: netTotal,
        curPayment: curPayment,
        balance: balance,
        change: change,
        walletError: walletErr,
        overpayError: overpayErr,
      ),
    );
  }
}
