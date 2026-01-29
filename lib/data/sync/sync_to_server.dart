import 'dart:developer';
import 'package:sharp_cut/core/database/database_helper.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:dartz/dartz.dart';

class SyncToServer {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<Either<String, String>> syncTransactionsToServer() async {
    try {
      log("Starting transaction sync...");
      // 1. Fetch unsynced transactions
      final transactions = await _dbHelper.getUnsyncedTransactions();
      if (transactions.isEmpty) {
        log("No unsynced transactions found.");
        return const Right("No unsynced transactions found.");
      }

      log("Found ${transactions.length} unsynced transactions.");

      List<Map<String, dynamic>> payload = [];
      List<int> transactionIds = [];

      for (var transaction in transactions) {
        int id = transaction['id'];
        transactionIds.add(id);

        // Fetch related data
        final services = await _dbHelper.getTransactionServices(id);
        final payments = await _dbHelper.getTransactionPayments(id);

        // Construct lists for the payload
        List<String> detailIds = [];
        List<int> serviceIds = [];
        List<int> quantities = [];
        List<double> rates = [];
        List<double> taxAmounts = [];
        List<String> currencies = [];
        List<double> amountTotals = [];
        List<double> taxes = [];
        List<double> subTotals = [];
        List<int> isTips = [];

        for (var s in services) {
          detailIds.add(s['detail_id'] ?? ""); // Use actual detail_id
          serviceIds.add(s['service_id'] ?? 0);
          quantities.add(s['quantity'] ?? 0);
          rates.add(s['rate'] ?? 0.0);
          taxAmounts.add(s['tax_amount'] ?? 0.0);

          // Fetch currency for service
          String? currency = await _dbHelper.getCurrencyForService(
            s['service_id'],
          );
          currencies.add(currency ?? "AED"); // Default to AED if not found

          amountTotals.add(s['amount_total'] ?? 0.0);
          taxes.add(s['tax'] ?? 0.0);
          subTotals.add(s['sub_total'] ?? 0.0);
          isTips.add(s['is_tip'] ?? 0);
        }

        // Payments
        List<String> paymentIds = [];
        List<int> collectedUserIds = [];
        List<String> modes = [];
        List<double> amounts = [];
        List<double> tenderCash = [];
        List<double> changes = [];
        List<String> dates = [];

        for (var p in payments) {
          paymentIds.add(p['payment_id'] ?? ""); // Use actual payment_id
          collectedUserIds.add(p['collected_user_id'] ?? 0);
          modes.add(p['mode'] ?? "");
          amounts.add(p['amount'] ?? 0.0);
          tenderCash.add(p['tender_cash'] ?? 0.0);
          changes.add(p['change'] ?? 0.0);
          dates.add(p['date'] ?? "");
        }

        Map<String, dynamic> transactionMap = {
          "app_id": transaction['app_id'].toString(),
          "chair_id": transaction['chair_id'],
          "user_id": transaction['user_id'],
          "customer_name": transaction['customer_name'] ?? "",
          "customer_number": transaction['customer_number'] ?? "",
          "transaction_date": transaction['transaction_date'],
          "grand_total": transaction['grand_total'],
          "tax_total": transaction['tax_total'],
          "discount": transaction['discount'],
          "round_off": transaction['round_off'],
          "final_total": transaction['final_total'],
          "invoice_no": transaction['invoice_no'],
          "invoice_date": transaction['invoice_date'],
          "status": "final",
          "cancellation_reason": transaction['cancellation_reason'],

          "detail_id": detailIds,
          "service_id": serviceIds,
          "quantity": quantities,
          "rate": rates,
          "tax_amount": taxAmounts,
          "currency": currencies,
          "amount_total": amountTotals,
          "tax": taxes,
          "sub_total": subTotals,
          "is_tip": isTips,

          "payment_id": paymentIds,
          "collected_user_id": collectedUserIds,
          "mode": modes,
          "amount": amounts,
          "tender_cash": tenderCash,
          "change": changes,
          "date": dates,
        };
        payload.add(transactionMap);
      }

      log("Sending payload to server: ${payload.length} transactions");

      // Call API
      final response = await ApiClient.dio.post(
        ApiClient.transactionsSyncPOSTapi,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mark as synced
        await _dbHelper.markTransactionsAsSynced(transactionIds);
        log("Synced ${transactionIds.length} transactions successfully.");
        return Right(
          "Synced ${transactionIds.length} transactions successfully.",
        );
      } else {
        log(
          "Failed to sync transactions: ${response.statusCode} - ${response.statusMessage}",
        );
        return Left(
          "Failed to sync transactions: ${response.statusCode} - ${response.statusMessage}",
        );
      }
    } catch (e) {
      log("Error syncing transactions: $e");
      return Left("Error syncing transactions: $e");
    }
  }

  Future<Either<String, bool>> isFullySynced() async {
    try {
      final result = await _dbHelper.isFullySynced();
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
