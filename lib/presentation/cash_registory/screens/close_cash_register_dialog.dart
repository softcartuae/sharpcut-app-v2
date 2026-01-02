import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_cubit.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_state.dart';
import 'package:sharp_cut/presentation/home/widgets/action_button.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

class CloseCashRegisterDialog extends StatefulWidget {
  const CloseCashRegisterDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CloseCashRegisterDialog(),
    );
  }

  @override
  State<CloseCashRegisterDialog> createState() =>
      _CloseCashRegisterDialogState();
}

class _CloseCashRegisterDialogState extends State<CloseCashRegisterDialog> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CashRegistoryCubit, CashRegistoryState>(
      listener: (context, state) {
        if (state is CashRegistoryAddSuccess) {
          Navigator.pop(context);
          ToastHelper.showSuccess(state.message);
          // Refresh status or handle post-close logic if needed
        } else if (state is CashRegistoryAddError) {
          ToastHelper.showError(state.message);
        }
      },
      child: Dialog(
        backgroundColor: const Color(0xFF1E1E2C),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "CLOSE CASH REGISTER",
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Closing Amount",
                style: GoogleFonts.rajdhani(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 18),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  hintText: "Enter amount",
                  hintStyle: GoogleFonts.rajdhani(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              BlocBuilder<CashRegistoryCubit, CashRegistoryState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: ActionButton(
                      label: "CLOSE REGISTER",
                      isPrimary: true,
                      isLoading: state is CashRegistoryLoading,
                      onTap: () {
                        if (_amountController.text.isEmpty) {
                          ToastHelper.showError("Please enter closing amount");
                          return;
                        }
                        final amount = double.tryParse(_amountController.text);
                        if (amount == null) {
                          ToastHelper.showError("Invalid amount");
                          return;
                        }
                        context.read<CashRegistoryCubit>().closeCashRegister(
                          amount: amount,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
