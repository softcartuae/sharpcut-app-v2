import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/cubit/settlement/settlement_form_cubit.dart';
import 'package:sharp_cut/cubit/settlement/settlement_form_state.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_glass_container.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_text_fields.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class SettlementTotalsSection extends StatelessWidget {
  final TextEditingController totalQtyController;
  final TextEditingController subTotalController;
  final TextEditingController discountController;
  final TextEditingController vatController;
  final TextEditingController paidController;
  final TextEditingController curPaymentController;
  final TextEditingController balanceController;
  final VoidCallback onSettleAndPrint;
  final VoidCallback onSettle;

  const SettlementTotalsSection({
    super.key,
    required this.totalQtyController,
    required this.subTotalController,
    required this.discountController,
    required this.vatController,
    required this.paidController,
    required this.curPaymentController,
    required this.balanceController,
    required this.onSettleAndPrint,
    required this.onSettle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SettlementGlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SettlementRowInput(
                  label: "Total Qty",
                  controller: totalQtyController,
                  isReadOnly: true,
                ),
                const SizedBox(height: 10),
                SettlementRowInput(
                  label: "Sub Total",
                  controller: subTotalController,
                  isReadOnly: true,
                ),
                const SizedBox(height: 10),
                SettlementRowInput(
                  label: "P. Discount",
                  controller: discountController,
                  onChanged: (val) {
                    final double d = double.tryParse(val) ?? 0.0;
                    context.read<SettlementFormCubit>().updateDiscount(d);
                  },
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
                const SizedBox(height: 10),
                SettlementRowInput(
                  label: "VAT",
                  controller: vatController,
                  isReadOnly: true,
                ),
                const SizedBox(height: 10),
                SettlementRowInput(
                  isReadOnly: true,
                  label: "Paid",
                  controller: paidController,
                ),
                const SizedBox(height: 15),

                // Grand Total Badge driven by SettlementFormCubit
                BlocBuilder<SettlementFormCubit, SettlementFormState>(
                  buildWhen: (previous, current) => previous.netTotal != current.netTotal,
                  builder: (context, state) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.violetNormal,
                            AppColors.redNormal,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Grand Total",
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            state.netTotal.toStringAsFixed(2),
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cur. Payment",
                            style: GoogleFonts.rajdhani(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          SettlementSimpleInput(
                            controller: curPaymentController,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Balance",
                            style: GoogleFonts.rajdhani(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          SettlementSimpleInput(
                            controller: balanceController,
                            isReadOnly: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Action Buttons driven by BookingCubit state
          BlocBuilder<BookingCubit, BookingState>(
            builder: (context, bookingState) {
              final bool isLoading = bookingState is BookingLoading;
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: isLoading ? null : onSettleAndPrint,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoading ? Colors.grey : AppColors.violetNormal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      "SETTLE & PRINT",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : onSettle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoading ? Colors.grey : AppColors.violetNormal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      "SETTLE",
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
