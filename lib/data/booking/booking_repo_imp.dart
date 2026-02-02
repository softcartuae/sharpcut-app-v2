import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';
import 'package:sharp_cut/core/utils/date_formatter.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/booking/models/rebooking_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_response_model.dart';
import 'package:sharp_cut/core/database/database_helper.dart';
import 'package:sharp_cut/utils/helpers/convertion.dart';

class BookingRepoImp implements BookingRepo {
  @override
  Future<Either<String, String>> bookSlot({
    required int chairId,
    required int userId,
    required String userPassword,
  }) async {
    try {
      // Offline-only implementation

      final localUsers = await DatabaseHelper().getUsers();
      final user = localUsers.firstWhere((element) => element['id'] == userId);

      if (user['password'] == null) {
        return const Left("Reset Password Required");
      }

      if (user['password'] != userPassword) {
        return const Left("Invalid password.");
      }

      // Fetch invoice settings
      final invoiceSettings = await DatabaseHelper().getInvoiceSettings();
      String invoiceNo;
      if (invoiceSettings != null) {
        final prefix = invoiceSettings['invoice_prefix'];
        final year = invoiceSettings['financial_year'];
        final count = (invoiceSettings['count'] as int) + 1;
        invoiceNo = "$prefix/$year/$count";

        // Increment count in DB
        await DatabaseHelper().incrementInvoiceCount();
      } else {
        log("Invoice settings not found");
        return Left("Invoice settings not found");
      }

      final appid = generateUniqueInt();

      // Fetch last open cash register
      final cashRegister = await DatabaseHelper().getLastOpenCashRegister();
      final cashRegisterId = cashRegister?['id'] as int?;

      final transactionData = {
        'chair_id': chairId,
        'user_id': userId,
        'cash_register_id': cashRegisterId,
        'transaction_date': DateFormatter.now(),
        'status': 'Pending',
        'invoice_no': invoiceNo,
        'invoice_date': DateFormatter.dateonly(DateTime.now()),
        'app_id': appid,
        'grand_total': 0.0,
        'tax_total': 0.0,
        'discount': 0.0,
        'round_off': 0.0,
        'final_total': 0.0,
        'is_synced': 0,
      };

      await DatabaseHelper().createBooking(transactionData, []);
      return const Right("Booking successful");
    } catch (e) {
      log('Error booking slot: $e');
      return Left('Error booking slot: $e');
    }
  }

  @override
  Future<Either<String, String>> cancelBooking({
    required int transactionId,
    required int userId,
    required String userPassword,
    required String reason,
  }) async {
    try {
      // Offline-only implementation
      await DatabaseHelper().cancelBooking(transactionId, reason);
      return const Right("Transaction cancelled successfully");
    } catch (e) {
      return Left('Error cancelling booking: $e');
    }
  }

  // @override
  // Future<Either<String, String>> saveBooking(
  //   SaveBookingRequestModel request,
  // ) async {
  //   try {
  //     // Offline-only implementation
  //     // Convert SaveBookingRequestModel to SettlePaymentRequestModel for DatabaseHelper
  //     final settleRequest = SettlePaymentRequestModel(
  //       transactionId: request.transactionId,
  //       subTotalValue: request.grandTotal,
  //       taxTotal: request.taxTotal,
  //       discount: request.discount,
  //       roundOff: request.roundOff,
  //       finalTotal: request.finalTotal,
  //       paymentStatus: 'unpaid',
  //       mode: [],
  //       amount: [],
  //       tenderCash: [],
  //       change: [],
  //       collectedUserId: [],
  //       // Map service details
  //       serviceId: request.serviceId,
  //       quantity: request.quantity,
  //       rate: request.rate,
  //       taxAmount: request.taxAmount,
  //       currency: request.currency,
  //       amountTotal: request.amountTotal,
  //       tax: request.tax,
  //       subTotalList: request.subTotal,
  //       isTip: request.isTip,
  //       customerName: request.customerName,
  //       customerNumber: request.customerNumber,
  //     );

  //     await DatabaseHelper().settlePayment(settleRequest);

  //     return const Right("Booking saved successfully");
  //   } catch (e) {
  //     return Left('Error saving booking: $e');
  //   }
  // }

  @override
  Future<Either<String, SettlePaymentResponseModel>> settlePayment(
    SettlePaymentRequestModel request,
  ) async {
    try {
      // Offline-only implementation
      await DatabaseHelper().settlePayment(request);

      final transactionData = await DatabaseHelper().getBookingDetails(
        request.transactionId!,
      );

      BookingResponseModel? bookingResponse;
      if (transactionData != null) {
        bookingResponse = BookingResponseModel.fromJson(transactionData);
      }

      return Right(
        SettlePaymentResponseModel(
          bookingResponse: bookingResponse,
          success: true,
          message: 'Payment settlement successful',
        ),
      );
    } catch (e) {
      return Left('Error settling payment: $e');
    }
  }

  @override
  Future<Either<String, SettlePaymentResponseModel>> quickPayment(
    SettlePaymentRequestModel request,
  ) async {
    // Quick payment is essentially settle payment with default/single payment mode
    return settlePayment(request);
  }

  @override
  Future<Either<String, SettlePaymentResponseModel>> reSettlePayment(
    ResettleModel request,
  ) async {
    try {
      // Update local database
      await DatabaseHelper().reSettlePayment(request);

      // Fetch updated transaction details
      final transactionData = await DatabaseHelper().getBookingDetails(
        request.transactionId!,
      );

      BookingResponseModel? bookingResponse;
      if (transactionData != null) {
        bookingResponse = BookingResponseModel.fromJson(transactionData);
      }

      return Right(
        SettlePaymentResponseModel(
          bookingResponse: bookingResponse,
          success: true,
          message: 'Payment resettlement successful',
        ),
      );
    } catch (e) {
      return Left('Error settling payment: $e');
    }
  }

  @override
  Future<Either<String, String>> updatePaymentMode({
    required int paymentId,
    required int transactionId,
    required String mode,
    required double amount,
  }) async {
    try {
      await DatabaseHelper().updatePaymentMode(
        paymentId: paymentId,
        transactionId: transactionId,
        mode: mode,
        amount: amount,
      );
      return const Right("Payment updated successfully");
    } catch (e) {
      log('Error updating payment: $e');
      return Left(e.toString().replaceAll("Exception: ", ""));
    }
  }
}
