import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/presentation/expense/screens/screen_re_settlement.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/presentation/report/widgets/edit_customer_name_dialog.dart';
import 'package:sharp_cut/presentation/report/widgets/payment_details_dialog.dart';
import 'package:sharp_cut/presentation/report/widgets/paymentedit_dialoge.dart';
import 'package:sharp_cut/presentation/report/widgets/receipt_dialog_helper.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/utils/helpers/payment_request_mapper.dart';

class ReportDialogHelper {
  /// Opens [PaymentDetailsDialog] and handles nested [PaymentEditDialog]
  static void showPaymentDetails(
    BuildContext context, {
    required BookingResponseModel booking,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => PaymentDetailsDialog(
        booking: booking,
        onEdit: (payment) {
          showDialog(
            context: dialogContext,
            builder: (context) => PaymentEditDialog(
              currentMode: payment.mode ?? "Cash",
              currentAmount: payment.amount ?? 0.0,
              invoiceNo: booking.invoiceNo ?? "",
              invoiceAmount: booking.finalTotal ?? 0.0,
              availableWalletBalance: booking.customer?.wallet ?? 0.0,
              onUpdate: (mode, amount) {
                dialogContext.read<BookingCubit>().updatePaymentMode(
                      paymentId: payment.id!,
                      mode: mode,
                      amount: amount,
                    );
              },
            ),
          );
        },
      ),
    );
  }

  /// Opens [EditCustomerNameDialog] and dispatches customer details update
  static void showEditCustomerName(
    BuildContext context, {
    required BookingResponseModel booking,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => EditCustomerNameDialog(
        booking: booking,
        currentName: booking.customerName ?? "",
        currentNumber: booking.customerNumber ?? "",
        onSave: (newName, newNumber) {
          dialogContext.read<BookingCubit>().updateCustomerDetails(
                booking: booking,
                customerName: newName,
                customerNumber: newNumber,
              );
        },
      ),
    );
  }

  /// Handles Balance Resettlement action and opens [ScreenReSettlement]
  static void showResettlement(
    BuildContext context, {
    required BookingResponseModel booking,
    StaffModel? staff,
  }) {
    final cartItems = PaymentRequestMapper.extractCartItems(booking);
    final request = PaymentRequestMapper.fromBookingResponse(
      booking,
      cartItems: cartItems,
    );

    final balanceAmount =
        (booking.finalTotal ?? 0.0) - (booking.totalPayment ?? 0.0);
    final bool isAdmin = staff?.role == Role.admin;

    showResettmentScreen(
      booking: booking,
      isAdmin: isAdmin,
      balance: balanceAmount,
      paidAmount: booking.totalPayment?.toString(),
      context,
      settlePayment: request,
      staffName: booking.staff?.name,
      bookingTime: booking.transactionDate,
      invoiceNumber: booking.invoiceNo,
      cartItems: cartItems,
    );
  }

  /// Handles invoice printing action using [PrintingCubit]
  static void printInvoice(
    BuildContext context, {
    required BookingResponseModel booking,
  }) {
    final shopData = context.read<AuthCubit>().currentShop;
    if (shopData == null) return;

    final cartItems = PaymentRequestMapper.extractCartItems(booking);
    final request = PaymentRequestMapper.fromBookingResponse(
      booking,
      cartItems: cartItems,
    );

    final balanceAmount =
        (booking.finalTotal ?? 0.0) - (booking.totalPayment ?? 0.0);
    final printCubit = context.read<PrintingCubit>();

    printCubit.printInvoice(
      chairId: booking.chairId,
      printCount: printCubit.state.settings?.printCount.invoiceList.toInt(),
      balanceAmount: balanceAmount,
      request: request,
      shopData: shopData,
      cartItems: cartItems,
      staffName: booking.staff?.name,
      invoiceNumber: booking.invoiceNo,
      bookingTime: booking.transactionDate,
      invoiceDate: booking.invoiceDate,
      endTime: booking.endTime,
    );
  }

  /// Opens the receipt dialog
  static void showReceipt(
    BuildContext context, {
    required BookingResponseModel booking,
  }) {
    final shopData = context.read<AuthCubit>().currentShop;
    if (shopData != null) {
      showReceiptDialog(
        context,
        booking: booking,
        shopData: shopData,
      );
    }
  }
}

