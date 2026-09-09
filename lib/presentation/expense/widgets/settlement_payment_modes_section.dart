import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/settlement/settlement_form_cubit.dart';
import 'package:sharp_cut/cubit/settlement/settlement_form_state.dart';
import 'package:sharp_cut/presentation/expense/widgets/payment_mode_card.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class SettlementPaymentModesSection extends StatelessWidget {
  const SettlementPaymentModesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettlementFormCubit, SettlementFormState>(
      buildWhen: (previous, current) {
        return previous.isCashSelected != current.isCashSelected ||
            previous.isCardSelected != current.isCardSelected ||
            previous.isWalletSelected != current.isWalletSelected ||
            previous.cashAmount != current.cashAmount ||
            previous.cardAmount != current.cardAmount ||
            previous.walletAmount != current.walletAmount ||
            previous.walletBalance != current.walletBalance;
      },
      builder: (context, state) {
        final cubit = context.read<SettlementFormCubit>();
        return SingleChildScrollView(
          child: Column(
            children: [
              // Cash Card
              GestureDetector(
                onTap: () {
                  cubit.selectCashCardWallet(
                    isCash: state.splitPayment ? !state.isCashSelected : true,
                    isCard: state.splitPayment ? state.isCardSelected : false,
                    isWallet: state.splitPayment ? state.isWalletSelected : false,
                  );
                },
                child: PaymentModeCard(
                  title: "Cash",
                  amount: state.cashAmount == 0 ? "" : state.cashAmount.toStringAsFixed(2),
                  color1: state.isCashSelected
                      ? AppColors.violetNormal
                      : Colors.white10,
                  color2: state.isCashSelected
                      ? AppColors.redNormal
                      : Colors.transparent,
                ),
              ),
              const SizedBox(height: 10),

              // Card Card
              GestureDetector(
                onTap: () {
                  cubit.selectCashCardWallet(
                    isCash: state.splitPayment ? state.isCashSelected : false,
                    isCard: state.splitPayment ? !state.isCardSelected : true,
                    isWallet: state.splitPayment ? state.isWalletSelected : false,
                  );
                },
                child: PaymentModeCard(
                  title: "Card",
                  amount: state.cardAmount == 0 ? "" : state.cardAmount.toStringAsFixed(2),
                  color1: state.isCardSelected
                      ? AppColors.violetNormal
                      : Colors.white10,
                  color2: state.isCardSelected
                      ? AppColors.redNormal
                      : Colors.transparent,
                ),
              ),
              const SizedBox(height: 10),

              // Wallet Card
              GestureDetector(
                onTap: () {
                  cubit.selectCashCardWallet(
                    isCash: state.splitPayment ? state.isCashSelected : false,
                    isCard: state.splitPayment ? state.isCardSelected : false,
                    isWallet: state.splitPayment ? !state.isWalletSelected : true,
                  );
                },
                child: PaymentModeCard(
                  title: "Wallet (AED ${state.walletBalance.toStringAsFixed(2)})",
                  amount: state.walletAmount == 0 ? "" : state.walletAmount.toStringAsFixed(2),
                  color1: state.isWalletSelected
                      ? AppColors.violetNormal
                      : Colors.white10,
                  color2: state.isWalletSelected
                      ? AppColors.redNormal
                      : Colors.transparent,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
