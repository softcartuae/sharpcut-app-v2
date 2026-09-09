import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/booking/models/rebooking_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/presentation/expense/widgets/settlement_form_view.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';

Future<bool?> showResettmentScreen(
  BuildContext context, {
  required BookingResponseModel booking,
  required SettlePaymentRequestModel settlePayment,
  required String? staffName,
  required String? bookingTime,
  required String? invoiceNumber,
  required List<CartItemModel> cartItems,
  required String? paidAmount,
  required double balance,
  bool isAdmin = false,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => ResettlementScreen(
      booking: booking,
      paidAmount: paidAmount,
      invoiceNumber: invoiceNumber,
      settlePayment: settlePayment,
      staffName: staffName,
      bookingTime: bookingTime,
      cartItems: cartItems,
      balance: balance,
      isAdmin: isAdmin,
    ),
  );
}

class ResettlementScreen extends StatefulWidget {
  final BookingResponseModel booking;
  final SettlePaymentRequestModel settlePayment;
  final String? staffName;
  final String? bookingTime;
  final String? invoiceNumber;
  final List<CartItemModel> cartItems;
  final String? paidAmount;
  final double balance;
  final bool isAdmin;

  const ResettlementScreen({
    super.key,
    required this.booking,
    required this.settlePayment,
    required this.staffName,
    required this.bookingTime,
    required this.invoiceNumber,
    required this.cartItems,
    required this.paidAmount,
    required this.balance,
    required this.isAdmin,
  });

  @override
  State<ResettlementScreen> createState() => _ResettlementScreenState();
}

class _ResettlementScreenState extends State<ResettlementScreen> {
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
                chairId: null,
                printCount: printCubit.state.settings?.printCount.settlePayment.toInt(),
                balanceAmount: balanceAmt < 0 ? 0.0 : balanceAmt,
                request: updatedData,
                shopData: shopData,
                cartItems: widget.cartItems,
                staffName: widget.staffName,
                invoiceNumber: state.response.bookingResponse?.invoiceNo ?? widget.invoiceNumber,
                bookingTime: widget.bookingTime ?? "--:--",
                invoiceDate: state.response.bookingResponse?.invoiceDate,
              );
            }
          }
          Navigator.pop(context, true);
        }
      },
      child: SettlementFormView(
        settlePayment: widget.settlePayment,
        customer: widget.booking.customer,
        staffName: widget.staffName,
        bookingTime: widget.bookingTime,
        invoiceNumber: widget.invoiceNumber,
        paidAmount: widget.paidAmount,
        initialBalance: widget.balance,
        walletBalance: widget.booking.customer?.wallet ?? 0.0,
        isReSettlement: true,
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
          final ResettleModel resettleModel = ResettleModel(
            onlineBookingId: widget.settlePayment.onlineBookingId,
            discount: discount,
            transactionId: widget.settlePayment.transactionId,
            collectedUserId: widget.settlePayment.collectedUserId != null && widget.settlePayment.collectedUserId!.isNotEmpty
                ? List.filled(modes.length, widget.settlePayment.collectedUserId!.first)
                : [],
            mode: modes,
            amount: amounts,
            tenderCash: tenders,
            change: changes,
          );

          _pendingRequest = request;
          _shouldPrint = alsoPrint;
          context.read<BookingCubit>().reSettlePayment(resettleModel: resettleModel);
        },
      ),
    );
  }
}
