import 'package:flutter_test/flutter_test.dart';
import 'package:sharp_cut/cubit/settlement/settlement_form_cubit.dart';
import 'package:sharp_cut/utils/helpers/settlement_calculator.dart';

void main() {
  group('SettlementFormCubit Tests', () {
    late SettlementFormCubit cubit;

    setUp(() {
      cubit = SettlementFormCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initForm with auto-populated discount sets amount to netTotal and overpayError to null when valid', () {
      cubit.initForm(
        subTotal: 25.0,
        taxTotal: 0.0,
        discount: 2.0,
        initialFinalTotal: 25.0,
        walletBalance: 100.0,
        isReSettlement: false,
        paidAmount: 0.0,
        initialBalance: 0.0,
      );

      final state = cubit.state;
      expect(state.grossTotal, 25.0);
      expect(state.discount, 2.0);
      expect(state.netTotal, 23.0);
      expect(state.amount, 23.0);
      expect(state.cashAmount, 23.0);
      expect(state.curPayment, 23.0);
      expect(state.overpayError, isNull);
    });

    test('initForm validates overpayment if initial paid + discount > grossTotal', () {
      cubit.initForm(
        subTotal: 25.0,
        taxTotal: 0.0,
        discount: 5.0,
        initialFinalTotal: 25.0,
        walletBalance: 100.0,
        isReSettlement: true,
        paidAmount: 22.0,
        initialBalance: 5.0,
      );

      final state = cubit.state;
      // 5 (curPayment) + 22 (paidAmount) + 5 (discount) = 32 > 25 (grossTotal)
      expect(state.overpayError, isNotNull);
      expect(state.overpayError, 'Total amount cannot be greater than Final Total');
    });

    test('updateAmount triggers overpayment validation when paid + discount > grossTotal', () {
      cubit.initForm(
        subTotal: 25.0,
        taxTotal: 0.0,
        discount: 2.0,
        initialFinalTotal: 25.0,
        walletBalance: 100.0,
        isReSettlement: false,
        paidAmount: 0.0,
        initialBalance: 0.0,
      );

      expect(cubit.state.overpayError, isNull);

      // User manually edits payment amount from 23 to 25 while discount is 2
      cubit.updateAmount(25.0);

      // 25 + 2 = 27 > 25
      expect(cubit.state.overpayError, 'Total amount cannot be greater than Final Total');
    });
  });

  group('SettlementCalculator Tests', () {
    test('validateOverpayment returns error when paid + discount > finalTotal', () {
      final result = SettlementCalculator.validateOverpayment(
        paid: 25.0,
        discount: 2.0,
        finalTotal: 25.0,
      );
      expect(result, 'Total amount cannot be greater than Final Total');
    });

    test('validateOverpayment returns null when paid + discount <= finalTotal', () {
      final result = SettlementCalculator.validateOverpayment(
        paid: 23.0,
        discount: 2.0,
        finalTotal: 25.0,
      );
      expect(result, isNull);
    });
  });
}
