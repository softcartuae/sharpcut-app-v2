import 'package:sharp_cut/utils/helpers/icon_helper.dart';

abstract class SettlementCalculator {
  /// Calculates Gross Final Total = SubTotal + TaxTotal
  static double calculateGrossTotal({
    required double subTotal,
    required double taxTotal,
  }) {
    return round2(subTotal + taxTotal);
  }

  /// Calculates Net Total = GrossTotal - Discount
  static double calculateNetTotal({
    required double grossTotal,
    required double discount,
  }) {
    return round2(grossTotal - discount);
  }

  /// Calculates current payment total from cash, card, and wallet amounts
  static double calculateCurrentPayment({
    required double cashAmount,
    required double cardAmount,
    required double walletAmount,
  }) {
    return round2(cashAmount + cardAmount + walletAmount);
  }

  /// Calculates remaining balance
  static double calculateBalance({
    required double grossTotal,
    required double discount,
    required double alreadyPaid,
    required double curPayment,
  }) {
    final double netTotal = grossTotal - discount;
    final double balance = netTotal - alreadyPaid - curPayment;
    return balance < 0 ? 0.0 : round2(balance);
  }

  /// Calculates change from tender cash
  static double calculateTenderChange({
    required double tenderCash,
    required double cashAmount,
  }) {
    final double change = tenderCash - cashAmount;
    return change < 0 ? 0.0 : round2(change);
  }

  /// Determines payment status: "unpaid", "partial", or "full"
  static String determinePaymentStatus({
    required double totalPaid,
    required double finalTotal,
  }) {
    final double roundPaid = round2(totalPaid);
    final double roundFinal = round2(finalTotal);

    if (roundPaid == 0) return "unpaid";
    if (roundPaid < roundFinal) return "partial";
    return "full";
  }

  /// Validates wallet amount against available wallet balance
  static String? validateWalletAmount({
    required double enteredWallet,
    required double availableWallet,
  }) {
    if (enteredWallet > availableWallet) {
      return "Wallet amount cannot exceed available balance (AED ${availableWallet.toStringAsFixed(2)})";
    }
    return null;
  }

  /// Validates overpayment prevention
  static String? validateOverpayment({
    required double paid,
    required double discount,
    required double finalTotal,
  }) {
    if (round2(paid + discount) > round2(finalTotal)) {
      return "Total amount cannot be greater than Final Total";
    }
    return null;
  }
}
