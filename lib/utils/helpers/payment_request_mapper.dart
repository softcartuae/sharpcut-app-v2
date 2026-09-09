import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

abstract class PaymentRequestMapper {
  /// Extracts cart items from [BookingResponseModel]
  static List<CartItemModel> extractCartItems(BookingResponseModel booking) {
    return booking.details
            ?.where((detail) => detail.service != null)
            .map(
              (detail) => CartItemModel(
                service: detail.service!.copyWith(
                  charge: detail.rate ?? detail.service!.charge,
                ),
                quantity: detail.quantity ?? 1,
              ),
            )
            .toList() ??
        [];
  }

  /// Maps [BookingResponseModel] into [SettlePaymentRequestModel]
  static SettlePaymentRequestModel fromBookingResponse(
    BookingResponseModel booking, {
    List<CartItemModel>? cartItems,
  }) {
    final items = cartItems ?? extractCartItems(booking);

    return SettlePaymentRequestModel(
      onlineBookingId: booking.onlineBookingId,
      finalTotalbefore: booking.finalTotalbefore,
      paymentStatus: booking.paymentStatus,
      transactionId: booking.id,
      customerName: booking.customerName,
      customerNumber: booking.customerNumber,
      subTotalValue: booking.subtotal ?? 0.0,
      taxTotal: booking.taxTotal ?? 0.0,
      discount: booking.discount ?? 0.0,
      roundOff:  0.0,
      finalTotal: booking.finalTotal ?? 0.0,
      serviceId: items.map((e) => e.service.id!).toList(),
      quantity: items.map((e) => e.quantity).toList(),
      rate: items.map((e) => e.service.price ?? 0.0).toList(),
      taxAmount: items.map((e) => e.service.unitTax ?? 0.0).toList(),
      currency: items.map((e) => "AED").toList(),
      amountTotal: items
          .map((e) => (e.service.price ?? 0.0) * e.quantity)
          .toList(),
      tax: items.map((e) => (e.service.unitTax ?? 0.0) * e.quantity).toList(),
      subTotalList: items.map((e) {
        final price = e.service.price ?? 0.0;
        final tax = e.service.unitTax ?? 0.0;
        return (price + tax) * e.quantity;
      }).toList(),
      isTip: items.map((e) => e.service.isTip ?? 0).toList(),
      collectedUserId: booking.userId != null ? [booking.userId!] : [],
      mode: booking.payments?.map((e) => e.mode ?? '').toList() ?? [],
      amount: booking.payments?.map((e) => e.amount ?? 0.0).toList() ?? [],
      tenderCash: [0.0],
      change: [0.0],
    );
  }
  /// Maps Quick Payment parameters into [SettlePaymentRequestModel]
  static SettlePaymentRequestModel fromQuickPayment({
    required int? transactionId,
    required int? onlineBookingId,
    required String? customerName,
    required String? customerNumber,
    required double subTotal,
    required double taxTotal,
    required double discount,
    required double finalTotal,
    required List<CartItemModel> cartItems,
    required int? userId,
    required String paymentMode,
  }) {
    final bool isUnpaid = paymentMode == PaymentMode.Unpaid.name;
    final double amount = isUnpaid ? 0.0 : (subTotal - discount);

    return SettlePaymentRequestModel(
      paymentStatus: isUnpaid ? "unpaid" : "full",
      transactionId: transactionId,
      onlineBookingId: onlineBookingId,
      customerName: customerName,
      customerNumber: customerNumber,
      subTotalValue: subTotal,
      taxTotal: taxTotal,
      discount: discount,
      roundOff: 0.0,
      finalTotal: finalTotal,
      finalTotalbefore: finalTotal,
      serviceId: cartItems.map((e) => e.service.id!).toList(),
      quantity: cartItems.map((e) => e.quantity).toList(),
      rate: cartItems.map((e) => e.service.price ?? 0.0).toList(),
      taxAmount: cartItems.map((e) => e.service.unitTax ?? 0.0).toList(),
      currency: cartItems.map((e) => "AED").toList(),
      amountTotal: cartItems
          .map((e) => (e.service.price ?? 0.0) * e.quantity)
          .toList(),
      tax: cartItems.map((e) => (e.service.unitTax ?? 0.0) * e.quantity).toList(),
      subTotalList: cartItems.map((e) {
        final price = e.service.price ?? 0.0;
        final tax = e.service.unitTax ?? 0.0;
        return (price + tax) * e.quantity;
      }).toList(),
      isTip: cartItems.map((e) => e.service.isTip ?? 0).toList(),
      collectedUserId: userId != null ? [userId] : [],
      mode: [isUnpaid ? "Cash" : paymentMode],
      amount: [amount],
      tenderCash: [0.0],
      change: [0.0],
    );
  }

  /// Maps Save & Settle Bill parameters into [SettlePaymentRequestModel]
  static SettlePaymentRequestModel fromSaveAndSettle({
    required int? transactionId,
    required int? onlineBookingId,
    required String? customerName,
    required String? customerNumber,
    required double subTotal,
    required double taxTotal,
    required double total,
    required List<CartItemModel> cartItems,
    required int? userId,
  }) {
    return SettlePaymentRequestModel(
      finalTotalbefore: total,
      transactionId: transactionId,
      onlineBookingId: onlineBookingId,
      customerName: customerName,
      customerNumber: customerNumber,
      subTotalValue: subTotal,
      taxTotal: taxTotal,
      discount: 0.0,
      roundOff: 0.0,
      finalTotal: total,
      serviceId: cartItems.map((e) => e.service.id!).toList(),
      quantity: cartItems.map((e) => e.quantity).toList(),
      rate: cartItems.map((e) => e.service.price ?? 0.0).toList(),
      taxAmount: cartItems.map((e) => e.service.unitTax ?? 0.0).toList(),
      currency: cartItems.map((e) => "AED").toList(),
      amountTotal: cartItems
          .map((e) => (e.service.price ?? 0.0) * e.quantity)
          .toList(),
      tax: cartItems.map((e) => (e.service.unitTax ?? 0.0) * e.quantity).toList(),
      subTotalList: cartItems.map((e) {
        final price = e.service.price ?? 0.0;
        final tax = e.service.unitTax ?? 0.0;
        return (price + tax) * e.quantity;
      }).toList(),
      isTip: cartItems.map((e) => e.service.isTip ?? 0).toList(),
      collectedUserId: userId != null ? [userId] : [],
      mode: [],
      amount: [total],
      tenderCash: [0.0],
      change: [0.0],
    );
  }

  /// Constructs a full [SettlePaymentRequestModel] from settlement form values
  static SettlePaymentRequestModel fromSettlementForm({
    required String paymentStatus,
    required int? transactionId,
    required int? onlineBookingId,
    required String? customerName,
    required String? customerNumber,
    required double subTotal,
    required double taxTotal,
    required double discount,
    required double finalTotal,
    required double? finalTotalbefore,
    required List<int>? serviceId,
    required List<int>? quantity,
    required List<double>? rate,
    required List<double>? taxAmount,
    required List<String>? currency,
    required List<double>? amountTotal,
    required List<double>? tax,
    required List<double>? subTotalList,
    required List<int>? isTip,
    required List<int>? collectedUserId,
    required List<String> mode,
    required List<double> amount,
    required List<double> tenderCash,
    required List<double> change,
  }) {
    return SettlePaymentRequestModel(
      paymentStatus: paymentStatus,
      transactionId: transactionId,
      onlineBookingId: onlineBookingId,
      customerName: customerName,
      customerNumber: customerNumber,
      subTotalValue: subTotal,
      taxTotal: taxTotal,
      discount: discount,
      roundOff: 0.0,
      finalTotal: finalTotal,
      finalTotalbefore: finalTotalbefore,
      serviceId: serviceId,
      quantity: quantity,
      rate: rate,
      taxAmount: taxAmount,
      currency: currency,
      amountTotal: amountTotal,
      tax: tax,
      subTotalList: subTotalList,
      isTip: isTip,
      collectedUserId: collectedUserId != null && collectedUserId.isNotEmpty
          ? List.filled(mode.length, collectedUserId.first)
          : [],
      mode: mode,
      amount: amount,
      tenderCash: tenderCash,
      change: change,
    );
  }
}
