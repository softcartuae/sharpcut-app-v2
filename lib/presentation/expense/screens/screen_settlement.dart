import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/domain/booking/models/customer_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_form_view.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';

Future<void> showSettlementDialog(
  BuildContext context, {
  required SettlePaymentRequestModel settlePayment,
  CustomerModel? customer,
  required String? staffName,
  required String? bookingTime,
  required List<CartItemModel> cartItems,
  required int? chairId,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => SettlementDialog(
      settlePayment: settlePayment,
      customer: customer,
      staffName: staffName,
      bookingTime: bookingTime,
      cartItems: cartItems,
      chairId: chairId,
    ),
  );
}

class SettlementDialog extends StatefulWidget {
  final SettlePaymentRequestModel settlePayment;
  final CustomerModel? customer;
  final String? staffName;
  final String? bookingTime;
  final List<CartItemModel> cartItems;
  final int? chairId;

  const SettlementDialog({
    super.key,
    required this.settlePayment,
    this.customer,
    required this.staffName,
    required this.bookingTime,
    required this.cartItems,
    required this.chairId,
  });

  @override
  State<SettlementDialog> createState() => _SettlementDialogState();
}

class _SettlementDialogState extends State<SettlementDialog> {
  SettlePaymentRequestModel? _pendingRequest;
  bool _shouldPrint = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingPaymentSettled) {
          if (_shouldPrint && _pendingRequest != null) {
            final shopData = context.read<AuthCubit>().currentShop;
            if (shopData != null) {
              final printCubit = context.read<PrintingCubit>();
              final SettlePaymentRequestModel updatedData = _pendingRequest!.copyWith(
                finalTotal: state.response.bookingResponse?.finalTotal,
                discount: state.response.bookingResponse?.discount,
                subTotalValue: state.response.bookingResponse?.subtotal,
                taxTotal: state.response.bookingResponse?.taxTotal,
                paymentStatus: state.response.bookingResponse?.paymentStatus,
                finalTotalbefore: state.response.bookingResponse?.finalTotalbefore,
              );

              final double paidSum = updatedData.amount?.fold<double>(0.0, (prev, element) => prev + element) ?? 0.0;
              final double balanceAmt = (updatedData.finalTotal ?? 0.0) - paidSum;

              printCubit.printInvoice(
                chairId: widget.chairId,
                printCount: printCubit.state.settings?.printCount.settlePayment.toInt(),
                balanceAmount: balanceAmt < 0 ? 0.0 : balanceAmt,
                request: updatedData,
                shopData: shopData,
                cartItems: widget.cartItems,
                staffName: widget.staffName,
                invoiceNumber: state.response.bookingResponse?.invoiceNo,
                bookingTime: widget.bookingTime ?? "--:--",
                invoiceDate: state.response.bookingResponse?.invoiceDate,
              );
            }
          }
          Navigator.pop(context);
        }
      },
      child: SettlementFormView(
        settlePayment: widget.settlePayment,
        customer: widget.customer,
        staffName: widget.staffName,
        bookingTime: widget.bookingTime,
        walletBalance: widget.customer?.wallet ?? 0.0,
        isReSettlement: false,
        onSettleSubmit: ({
          required bool alsoPrint,
          required SettlePaymentRequestModel request,
          required double discount,
          required double cashAmount,
          required double cardAmount,
          required double walletAmount,
          required double tenderCash,
          required double change,
          required List<String> modes,
          required List<double> amounts,
          required List<double> tenders,
          required List<double> changes,
          required String customerName,
          required String customerNumber,
        }) {
          _pendingRequest = request;
          _shouldPrint = alsoPrint;
          context.read<BookingCubit>().settlePayment(request: request);
        },
      ),
    );
  }
}
