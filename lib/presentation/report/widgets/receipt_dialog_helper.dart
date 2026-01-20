import 'package:flutter/material.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/presentation/printing/widgets/receipt_widget.dart';

void showReceiptDialog(
  BuildContext context, {
  required BookingResponseModel booking,
  required ShopModel shopData,
}) {
  // Map BookingResponseModel to List<CartItemModel>
  final List<CartItemModel> cartItems =
      booking.details
          ?.where((detail) => detail.service != null)
          .map(
            (detail) => CartItemModel(
              service: detail.service!,
              quantity: detail.quantity ?? 1,
            ),
          )
          .toList() ??
      [];

  // Map BookingResponseModel to SettlePaymentRequestModel
  final request = SettlePaymentRequestModel(
    paymentStatus: booking.paymentStatus,
    subTotalValue: booking.subtotal,
    taxTotal: booking.taxTotal,
    finalTotal: (booking.finalTotal),
    discount:
        booking.discount, // Assuming no discount available in response for now
    subTotalList: [booking.subtotal ?? 0.0],
    mode: booking.payments?.map((e) => e.mode ?? '').toList(),
    amount: booking.payments?.map((e) => e.amount ?? 0.0).toList(),
  );

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ReceiptWidget(
                  
                  chairId: booking.chairId,
                  balanceAmount: 0,
                  width: MediaQuery.of(context).size.width > 600 ? 500 : 370,
                  staffName: booking.staff?.name,
                  invoiceNumber: booking.invoiceNo,
                  bookingTime: booking.transactionDate,
                  shopData: shopData,
                  request: request,
                  cartItems: cartItems,
                  invoiceDate: booking.invoiceDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
