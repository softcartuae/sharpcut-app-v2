import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit_state.dart';
import 'package:sharp_cut/presentation/home/widgets/added_item.dart';
import 'package:sharp_cut/presentation/home/widgets/common_container.dart';
import 'package:sharp_cut/presentation/home/widgets/features_bottons.dart';
import 'package:sharp_cut/presentation/home/widgets/tip_dialoge.dart';
import 'package:sharp_cut/utils/helpers/check_no_chair.dart';

class HomeCartSummaryPanel extends StatelessWidget {
  const HomeCartSummaryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 6,
      child: CommonContainer(
        height: MediaQuery.of(context).size.height,
        borderRadius: BorderRadius.circular(15),
        backgroundImageUrl: "lib/utils/images/Card.png",
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Table Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Name",
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Qty",
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Amount",
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 32),

            // Cart Items List
            Expanded(
              child: BlocBuilder<ServiceCubit, ServiceState>(
                builder: (context, state) {
                  if (state is ServiceStateSuccess) {
                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemCount: state.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = state.cartItems[index];
                        return AddedItem(
                          onEditCharge: () {
                            final shop = context.read<AuthCubit>().currentShop;
                            final canEdit = CheckNoChair.checkShopCanEditServiceOrCharge(shop);
                            if (!canEdit) return;

                            showDialog(
                              context: context,
                              builder: (context) => TipDialog(
                                title: "EDIT CHARGE",
                                onTipSelected: (amount) {
                                  context.read<ServiceCubit>().updateCharge(item, amount);
                                },
                              ),
                            );
                          },
                          item: item,
                          onIncrement: () {
                            context.read<ServiceCubit>().updateQuantity(item, 1);
                          },
                          onDecrement: () {
                            context.read<ServiceCubit>().updateQuantity(item, -1);
                          },
                          onRemove: () {
                            context.read<ServiceCubit>().removeFromCart(item);
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),

            const Divider(color: Colors.white24, height: 32),

            // Totals Footer
            BlocBuilder<ServiceCubit, ServiceState>(
              builder: (context, state) {
                double subTotal = 0;
                double vat = 0;
                double total = 0;

                if (state is ServiceStateSuccess) {
                  subTotal = state.subTotal;
                  vat = state.vat;
                  total = state.total;
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TotalItem(
                      label: "Sub Total",
                      value: subTotal.toStringAsFixed(2),
                    ),
                    const TotalItem(label: "Discount", value: "0"),
                    TotalItem(
                      label: "Vat",
                      value: vat.toStringAsFixed(2),
                    ),
                    TotalItem(
                      label: "Total",
                      value: total.toStringAsFixed(2),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
