import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';

import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/presentation/expense/screens/screen_re_settlement.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';

import 'package:sharp_cut/presentation/report/cubit/report_cubit.dart';
import 'package:sharp_cut/presentation/report/widgets/report_table_header.dart';
import 'package:sharp_cut/presentation/report/widgets/report_table_row.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:sharp_cut/presentation/report/widgets/receipt_dialog_helper.dart';
import 'package:sharp_cut/presentation/report/widgets/payment_details_dialog.dart';
import 'package:sharp_cut/presentation/report/widgets/paymentedit_dialoge.dart';
import 'package:sharp_cut/presentation/report/widgets/edit_customer_name_dialog.dart';

class ReportDataTable extends StatefulWidget {
  const ReportDataTable({super.key, this.staff});

  final StaffModel? staff;

  @override
  State<ReportDataTable> createState() => _ReportDataTableState();
}

class _ReportDataTableState extends State<ReportDataTable> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
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
                                        padding: EdgeInsets.zero,
                                        itemCount: state.transactions.length,
                                        itemBuilder: (context, index) {
                                          return ReportTableRow(
                                            paymentSettleFunction: () {
                                              final booking =
                                                  state.transactions[index];
                                              showDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                builder: (context) => PaymentDetailsDialog(
                                                  booking: booking,
                                                  onEdit: (payment) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          PaymentEditDialog(
                                                            invoiceNo:
                                                                booking
                                                                    .invoiceNo ??
                                                                "",
                                                            invoiceAmount:
                                                                booking
                                                                    .finalTotal ??
                                                                0.0,
                                                            currentMode:
                                                                payment.mode ??
                                                                "Cash",
                                                            currentAmount:
                                                                payment
                                                                    .amount ??
                                                                0.0,
                                                            onUpdate: (mode, amount) {
                                                              context
                                                                  .read<
                                                                    BookingCubit
                                                                  >()
                                                                  .updatePaymentMode(
                                                                    paymentId:
                                                                        payment
                                                                            .id!,
                                                                    mode: mode,
                                                                    amount:
                                                                        amount,
                                                                  );
                                                            },
                                                          ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            onBalanceTap: () {
                                              final booking =
                                                  state.transactions[index];
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
                                                          service: detail
                                                              .service!
                                                              .copyWith(
                                                                charge:
                                                                    detail
                                                                        .rate ??
                                                                    detail
                                                                        .service!
                                                                        .charge,
                                                              ),
                                                          quantity:
                                                              detail.quantity ??
                                                              1,
                                                        ),
                                                      )
                                                      .toList() ??
                                                  [];

                                              SettlePaymentRequestModel
                                              request = SettlePaymentRequestModel(
                                                finalTotalbefore:
                                                    booking.finalTotalbefore,
                                                paymentStatus:
                                                    booking.paymentStatus,
                                                transactionId: booking.id,
                                                customerName:
                                                    booking.customerName,
                                                customerNumber:
                                                    booking.customerNumber,
                                                subTotalValue:
                                                    booking.subtotal ?? 0,
                                                taxTotal: booking.taxTotal ?? 0,
                                                discount: booking.discount ?? 0,
                                                roundOff: 0.0,
                                                finalTotal:
                                                    booking.finalTotal ?? 0,
                                                serviceId: [],
                                                quantity: cartItems
                                                    .map((e) => e.quantity)
                                                    .toList(),
                                                rate: cartItems
                                                    .map(
                                                      (e) =>
                                                          e.service.price ??
                                                          0.0,
                                                    )
                                                    .toList(),
                                                taxAmount: cartItems
                                                    .map((e) => 0.0)
                                                    .toList(), // Placeholder
                                                currency: cartItems
                                                    .map((e) => "AED")
                                                    .toList(),
                                                amountTotal: cartItems
                                                    .map(
                                                      (e) =>
                                                          (e.service.price ??
                                                              0.0) *
                                                          e.quantity,
                                                    )
                                                    .toList(),
                                                tax: cartItems
                                                    .map(
                                                      (e) =>
                                                          (e.service.unitTax ??
                                                              0.0) *
                                                          e.quantity,
                                                    )
                                                    .toList(), // Placeholder
                                                subTotalList: cartItems.map((
                                                  e,
                                                ) {
                                                  final price =
                                                      e.service.price ?? 0.0;
                                                  final tax =
                                                      e.service.unitTax ?? 0.0;
                                                  return (price + tax) *
                                                      e.quantity;
                                                }).toList(),
                                                isTip: cartItems
                                                    .map(
                                                      (e) =>
                                                          e.service.isTip ?? 0,
                                                    )
                                                    .toList(),
                                                collectedUserId: [
                                                  booking.userId!,
                                                ], // Placeholder
                                                mode: [],
                                                amount: [],
                                                tenderCash: [0.0],
                                                change: [0.0],
                                              );

                                              final balenceAmount =
                                                  (booking.finalTotal ?? 0) -
                                                  ((booking.totalPayment ?? 0));

                                              final bool isAdmin =
                                                  widget.staff?.role ==
                                                  Role.admin;

                                              showResettmentScreen(
                                                booking: booking,
                                                isAdmin: isAdmin,
                                                balance: balenceAmount,
                                                paidAmount: booking.totalPayment
                                                    ?.toString(),
                                                context,
                                                settlePayment: request,
                                                staffName: booking.staff?.name,
                                                bookingTime:
                                                    booking.transactionDate,
                                                invoiceNumber:
                                                    booking.invoiceNo,
                                                cartItems: cartItems,
                                              );
                                            },
                                            onCustomerNameTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return EditCustomerNameDialog(
                                                    booking: state.transactions[index],
                                                    currentName:
                                                        state
                                                            .transactions[index]
                                                            .customerName ??
                                                        "",
                                                    onSave: (newName) {
                                                      
                                                       
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            printTheInvoice: () {
                                              final ShopModel? shopData =
                                                  context
                                                      .read<AuthCubit>()
                                                      .currentUser;

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
                                                          service: detail
                                                              .service!
                                                              .copyWith(
                                                                charge:
                                                                    detail
                                                                        .rate ??
                                                                    detail
                                                                        .service!
                                                                        .charge,
                                                              ),
                                                          quantity:
                                                              detail.quantity ??
                                                              1,
                                                        ),
                                                      )
                                                      .toList() ??
                                                  [];
                                              final String? staffName =
                                                  booking.staff?.name;
                                              final String? invoiceNumber =
                                                  booking.invoiceNo;
                                              final String? bookingTime =
                                                  booking.transactionDate;

                                              SettlePaymentRequestModel
                                              request = SettlePaymentRequestModel(
                                                finalTotalbefore:
                                                    booking.finalTotalbefore,
                                                paymentStatus:
                                                    booking.paymentStatus,
                                                transactionId: booking.id,
                                                customerName:
                                                    booking.customerName,
                                                customerNumber:
                                                    booking.customerNumber,
                                                subTotalValue:
                                                    booking.subtotal ?? 0,
                                                taxTotal: booking.taxTotal ?? 0,
                                                discount: booking.discount,
                                                roundOff: 0.0,
                                                finalTotal:
                                                    booking.finalTotal ?? 0,
                                                serviceId: [],
                                                quantity: cartItems
                                                    .map((e) => e.quantity)
                                                    .toList(),
                                                rate: cartItems
                                                    .map(
                                                      (e) =>
                                                          e.service.price ??
                                                          0.0,
                                                    )
                                                    .toList(),
                                                taxAmount: cartItems
                                                    .map((e) => 0.0)
                                                    .toList(), // Placeholder
                                                currency: cartItems
                                                    .map((e) => "AED")
                                                    .toList(),
                                                amountTotal: cartItems
                                                    .map(
                                                      (e) =>
                                                          (e.service.price ??
                                                              0.0) *
                                                          e.quantity,
                                                    )
                                                    .toList(),
                                                tax: cartItems
                                                    .map((e) => 0.0)
                                                    .toList(), // Placeholder
                                                subTotalList: cartItems.map((
                                                  e,
                                                ) {
                                                  final price =
                                                      e.service.price ?? 0.0;
                                                  final tax =
                                                      e.service.unitTax ?? 0.0;
                                                  return (price + tax) *
                                                      e.quantity;
                                                }).toList(),

                                                isTip: cartItems
                                                    .map(
                                                      (e) =>
                                                          e.service.isTip ?? 0,
                                                    )
                                                    .toList(),
                                                collectedUserId: [
                                                  booking.userId!,
                                                ], // Placeholder
                                                mode: booking.payments
                                                    ?.map((e) => e.mode ?? '')
                                                    .toList(),
                                                amount: booking.payments
                                                    ?.map(
                                                      (e) => e.amount ?? 0.0,
                                                    )
                                                    .toList(),
                                                tenderCash: [0.0],
                                                change: [0.0],
                                              );

                                              if (shopData != null) {
                                                final balenceAmount =
                                                    (booking.finalTotal ?? 0) -
                                                    ((booking.totalPayment ??
                                                        0));

                                                final printCubit = context
                                                    .read<PrintingCubit>();
                                                printCubit.printInvoice(
                                                  chairId: booking.chairId,
                                                  printCount: printCubit
                                                      .state
                                                      .settings
                                                      ?.printCount
                                                      .invoiceList
                                                      .toInt(),
                                                  balanceAmount: balenceAmount,
                                                  request: request,
                                                  shopData: shopData,
                                                  cartItems: cartItems,
                                                  staffName: staffName,
                                                  invoiceNumber: invoiceNumber,
                                                  bookingTime: bookingTime,
                                                  invoiceDate:
                                                      booking.invoiceDate,
                                                  endTime: booking.endTime,
                                                );
                                              }
                                            },
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
                        Center(child: Text('Something went wrong'))
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
