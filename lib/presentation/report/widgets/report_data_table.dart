import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/domain/auth/models/user_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/presentation/expense/screens/screen_re_settlement.dart';

import 'package:sharp_cut/presentation/report/cubit/report_cubit.dart';
import 'package:sharp_cut/presentation/report/widgets/report_table_header.dart';
import 'package:sharp_cut/presentation/report/widgets/report_table_row.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:sharp_cut/presentation/report/widgets/receipt_dialog_helper.dart';

class ReportDataTable extends StatelessWidget {
  const ReportDataTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                              maxHeight: constraints.maxHeight,
                            ),
                            child: SizedBox(
                              width: 1500,
                              child: Column(
                                children: [
                                  // Header Row
                                  const ReportTableHeader(),
                                  // Data Rows
                                  if (state is ReportSuccess &&
                                      state.transactions.isNotEmpty)
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: state.transactions.length,
                                        itemBuilder: (context, index) {
                                          return ReportTableRow(
                                            paymentSettleFunction: () {
                                              final booking =
                                                  state.transactions[index];
                                              // Map BookingResponseModel to List<CartItemModel>
                                              final List<CartItemModel>
                                              cartItems =
                                                  booking.details
                                                      ?.where(
                                                        (detail) =>
                                                            detail.service !=
                                                            null,
                                                      )
                                                      .map(
                                                        (
                                                          detail,
                                                        ) => CartItemModel(
                                                          service:
                                                              detail.service!,
                                                          quantity:
                                                              detail.quantity ??
                                                              1,
                                                        ),
                                                      )
                                                      .toList() ??
                                                  [];

                                              final request =
                                                  SettlePaymentRequestModel(
                                                    transactionId: booking.id,
                                                    grandTotal: double.tryParse(
                                                      booking.grandTotal ?? '0',
                                                    ),
                                                    taxTotal: double.tryParse(
                                                      booking.taxTotal ?? '0',
                                                    ),
                                                    finalTotal: double.tryParse(
                                                      booking.finalTotal ?? '0',
                                                    ),
                                                    discount:
                                                        0.0, // Assuming no discount available in response for now
                                                    subTotal: [
                                                      double.tryParse(
                                                            booking.grandTotal ??
                                                                '0',
                                                          ) ??
                                                          0.0,
                                                    ],
                                                    mode: booking.payments
                                                        ?.map(
                                                          (e) => e.mode ?? '',
                                                        )
                                                        .toList(),
                                                    amount: booking.payments
                                                        ?.map(
                                                          (e) =>
                                                              double.tryParse(
                                                                e.amount ?? '0',
                                                              ) ??
                                                              0.0,
                                                        )
                                                        .toList(),
                                                  );

                                              showResettmentScreen(
                                                context,
                                                settlePayment: request,
                                                staffName: booking.staff?.name,
                                                bookingTime: booking.createdAt,
                                                invoiceNumber:
                                                    booking.invoiceNo,
                                                cartItems: cartItems,
                                              );
                                            },
                                            printTheInvoice: () {},
                                            viewFunction: () {
                                              final ShopModel? shopData =
                                                  context
                                                      .read<AuthCubit>()
                                                      .currentUser;

                                              if (shopData != null) {
                                                showReceiptDialog(
                                                  context,
                                                  booking:
                                                      state.transactions[index],
                                                  shopData: shopData,
                                                );
                                              }
                                            },
                                            transaction:
                                                state.transactions[index],
                                            index: index,
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (state is ReportLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (state is ReportFailure)
                        Center(child: Text(state.message))
                      else if (state is ReportSuccess &&
                          state.transactions.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions found',
                                style: GoogleFonts.rajdhani(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
