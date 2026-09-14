import 'dart:async';
import 'dart:developer';
import 'package:sharp_cut/core/database/database_helper.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:intl/intl.dart';
import 'package:dartz/dartz.dart';

class SyncToServer {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  SyncToServer();



  Future<Either<String, String>> syncTransactionsToServer({
    void Function(int batchCount, int totalItems)? onProgress,
  }) async {
    try {
      log("Starting transaction sync...");

      final registerSyncResult = await _syncCashRegisterIfNeeded();

      String? registerSyncError;
      registerSyncResult.fold((l) => registerSyncError = l, (r) => null);

      if (registerSyncError != null) {
        log("Cash register sync failed: $registerSyncError");
        return Left(registerSyncError!);
      }

      const int batchLimit = 30;
      int chunkCount = 0;
      int totalSyncedCount = 0;

      while (true) {
        final transactions = await _dbHelper.getUnsyncedTransactions(
          limit: batchLimit,
        );
        if (transactions.isEmpty) {
          break;
        }

        log(
          "Found ${transactions.length} unsynced transactions for batch #${chunkCount + 1}.",
        );

        List<Map<String, dynamic>> payload = [];
        List<int> transactionIds = [];

        for (var transaction in transactions) {
          int id = transaction['id'];
          transactionIds.add(id);

          final services = await _dbHelper.getTransactionServices(id);
          final payments = await _dbHelper.getTransactionPayments(id);

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
            detailIds.add((s['detail_id'] ?? 0).toString());
            serviceIds.add(s['service_id'] ?? 0);
            quantities.add(s['quantity'] ?? 0);
            rates.add(s['rate'] ?? 0.0);
            taxAmounts.add(s['tax_amount'] ?? 0.0);

            String? currency = await _dbHelper.getCurrencyForService(
              s['service_id'],
            );
            currencies.add(currency ?? "AED"); // Default to AED if not found
            amountTotals.add(s['amount_total'] ?? 0.0);
            taxes.add(s['tax'] ?? 0.0);
            subTotals.add(s['sub_total'] ?? 0.0);
            isTips.add(s['is_tip'] ?? 0);
          }

          List<String> paymentIds = [];
          List<int> collectedUserIds = [];
          List<String> modes = [];
          List<double> amounts = [];
          List<double> tenderCash = [];
          List<double> changes = [];
          List<String> dates = [];

          for (var p in payments) {
            paymentIds.add((p['payment_id'] ?? 0).toString());
            collectedUserIds.add(p['collected_user_id'] ?? 0);
            modes.add(p['mode'] ?? "");
            amounts.add(p['amount'] ?? 0.0);
            tenderCash.add(p['tender_cash'] ?? 0.0);
            changes.add(p['change'] ?? 0.0);
            dates.add(
              (p['date'] != null && p['date'].toString().isNotEmpty)
                  ? DateFormat(
                      'dd/MM/yyyy hh:mm a',
                    ).parse(p['date']).toUtc().toIso8601String()
                  : "",
            );
          }

          Map<String, dynamic> transactionMap = {
            "app_id": transaction['app_id'],
            "chair_id": transaction['chair_id'],
            "user_id": transaction['user_id'],
            "cash_register_id": transaction['cash_register_id'],
            "customer_name": transaction['customer_name'] ?? "",
            "customer_number": transaction['customer_number'] ?? "",

            "transaction_date": DateFormat(
              'dd/MM/yyyy hh:mm a',
            ).parse(transaction['transaction_date']).toUtc().toIso8601String(),

            "grand_total": transaction['grand_total'],
            "tax_total": transaction['tax_total'],
            "discount": transaction['discount'],
            "round_off": transaction['round_off'],
            "final_total": transaction['final_total'],
            "final_total_before": transaction['final_total_before'],
            "grand_total_after": transaction['grand_total_after'] != null
                ? double.parse(
                    double.parse(
                      transaction['grand_total_after'].toString(),
                    ).toStringAsFixed(2),
                  )
                : null,
            "tax_total_after": transaction['tax_total_after'] != null
                ? double.parse(
                    double.parse(
                      transaction['tax_total_after'].toString(),
                    ).toStringAsFixed(2),
                  )
                : null,
            "final_total_after": transaction['final_total_after'] != null
                ? double.parse(
                    double.parse(
                      transaction['final_total_after'].toString(),
                    ).toStringAsFixed(2),
                  )
                : null,
            "invoice_no": transaction['invoice_no'],
            "invoice_date": transaction['invoice_date'],
            "status": transaction['status'],
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

        final invoiceSettings = await _dbHelper.getInvoiceSettings();
        final invoiceCount = invoiceSettings?['count'] ?? 0;

        log(
          "Sending batch #${chunkCount + 1} payload to server: ${payload.length} transactions, Invoice Count: $invoiceCount",
        );
        Map<String, dynamic> data = {
          "transactions": payload,
          "invoice_count": invoiceCount,
        };
        // Call API
        final response = await ApiClient.dio.post(
          ApiClient.transactionsSyncPOSTapi,
          data: data,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          await _dbHelper.markTransactionsAsSynced(transactionIds);
          chunkCount++;
          totalSyncedCount += transactionIds.length;
          if (onProgress != null) {
            onProgress(chunkCount, totalSyncedCount);
          }
          log(
            "Synced batch #$chunkCount (${transactionIds.length} transactions) successfully.",
          );
        } else {
          log(
            "Failed to sync transactions batch #${chunkCount + 1}: ${response.statusCode} - ${response.statusMessage}",
          );
          return Left(
            "Failed to sync transactions: ${response.statusCode} - ${response.statusMessage}",
          );
        }
      }

      if (totalSyncedCount == 0) {
        log("No unsynced transactions found.");
        return const Right("No unsynced transactions found.");
      }

      return Right(
        "Synced $totalSyncedCount transactions across $chunkCount batches successfully.",
      );
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



  Future<Either<String, bool>> _syncCashRegisterIfNeeded() async {
    try {
      final unsyncedRegisters = await _dbHelper.getUnsyncedCashRegisters();

      if (unsyncedRegisters.isEmpty) {
        log("No unsynced cash registers found. Proceeding with transaction upload.");
        return const Right(true);
      }

      log("Found ${unsyncedRegisters.length} unsynced cash registers to upload.");

      for (var register in unsyncedRegisters) {
        log("Syncing cash register ID #${register['id']}...");

        final payload = {
          "id": register['id'],
          "cash_register_id": register['cash_register_id'],
          "opened_by": register['opened_by'],
          "closed_by": register['closed_by'],
          "opened_by_type": register['opened_by_type'],
          "closed_by_type": register['closed_by_type'],
          "opening_amount": register['opening_amount'],
          "closing_amount": register['closing_amount'],
          "opened_at": register['opened_at'] != null &&
                  register['opened_at'].toString().isNotEmpty
              ? (register['opened_at'].toString().contains('/')
                  ? DateFormat('dd/MM/yyyy hh:mm a')
                      .parse(register['opened_at'])
                      .toUtc()
                      .toIso8601String()
                  : DateTime.parse(register['opened_at'])
                      .toUtc()
                      .toIso8601String())
              : null,
          "closed_at": register['closed_at'] != null &&
                  register['closed_at'].toString().isNotEmpty
              ? (register['closed_at'].toString().contains('/')
                  ? DateFormat('dd/MM/yyyy hh:mm a')
                      .parse(register['closed_at'])
                      .toUtc()
                      .toIso8601String()
                  : DateTime.parse(register['closed_at'])
                      .toUtc()
                      .toIso8601String())
              : null,
          "is_sync": true,
        };

        final response = await ApiClient.dio.post(
          ApiClient.cashRegistersSyncApi,
          data: payload,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          if (data['success'] == true) {
            log("Cash register #${register['id']} synced successfully.");
            await _dbHelper.updateCashRegisterSyncStatus(register['id'], 1);
          } else {
            log(
              "Failed to sync cash register #${register['id']}: ${data['message']}",
            );
            return Left(
              data['message'] ??
                  "Failed to sync cash register #${register['id']}.",
            );
          }
        } else {
          log(
            "Failed to sync cash register #${register['id']}: ${response.statusCode}",
          );
          return Left(
            "Failed to sync cash register #${register['id']}: ${response.statusCode}",
          );
        }
      }

      return const Right(true);
    } catch (e, stackTrace) {
      log("Error syncing cash registers: $e");
      log("StackTrace: $stackTrace");
      return Left("Error syncing cash registers: $e");
    }
  }

  

  Future<Either<String, String>> syncTransactionsFromServer({
    void Function(int chunkCount, int totalItems)? onProgress,
  }) async {
    final db = await _dbHelper.database;
    try {
      log("════════════════════════════════════════════════════");
      log("[SYNC GET] Starting transaction pull from server...");
      await db.execute('PRAGMA foreign_keys = OFF;');

      final hasData = await _dbHelper.hasTransactionData();
      final String? currentCursor = await _dbHelper.getSyncCheckpoint(
        ApiClient.transactionsGETApi,
      );

      log("[SYNC GET] Existing DB Has Data: $hasData");
      log(
        "[SYNC GET] Loaded Initial Checkpoint Cursor: ${currentCursor ?? 'null (First Sync)'}",
      );
      log("─────────s───────────────────────────────────────────");

      bool hasMore = true;
      int chunkCount = 0;
      int totalItemsSynced = 0;
      String? activeCursor = currentCursor;

      do {
        chunkCount++;
        Map<String, dynamic> queryParams = {'limit': 100};

        if (activeCursor != null && activeCursor.isNotEmpty) {
          queryParams['cursor'] = activeCursor;
        }

        log(
          "[SYNC GET] Chunk #$chunkCount ➔ Sending Request: GET ${ApiClient.transactionsGETApi} with params: $queryParams",
        );

        final response = await ApiClient.dio.get(
          ApiClient.transactionsGETApi,
          queryParameters: queryParams,
        );

        log(
          "[SYNC GET] Chunk #$chunkCount ➔ Response Received! Status Code: ${response.statusCode}",
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = response.data['data'] ?? [];
          final bool serverHasMore = response.data['has_more'] as bool? ?? false;
          final String? nextCursorFromServer = response.data['next_cursor'] as String?;

          log(
            "[SYNC GET] Chunk #$chunkCount ➔ Items in batch: ${data.length} | Next Cursor: ${nextCursorFromServer ?? 'null'} | Has More: $serverHasMore",
          );

          if (data.isNotEmpty) {
            int itemIndex = 1;
            for (var item in data) {
              log(
                "[SYNC GET] Chunk #$chunkCount ➔ Storing Item $itemIndex/${data.length}: Transaction ID #${item['id']} (App ID: ${item['app_id']})",
              );
              await _processTransaction(item);
              itemIndex++;
            }
            totalItemsSynced += data.length;
            log(
              "[SYNC GET] Chunk #$chunkCount ➔ Successfully stored ${data.length} items into local SQLite.",
            );
          } else {
            log("[SYNC GET] Chunk #$chunkCount ➔ Response contains 0 items.");
          }

          if (onProgress != null) {
            onProgress(chunkCount, totalItemsSynced);
          }

          // Check if cursor advanced
          if (nextCursorFromServer != null &&
              nextCursorFromServer.isNotEmpty &&
              nextCursorFromServer != activeCursor) {
            activeCursor = nextCursorFromServer;
            hasMore = serverHasMore;
            await _dbHelper.saveSyncCheckpoint(
              ApiClient.transactionsGETApi,
              cursor: activeCursor,
            );
            log(
              "[SYNC GET] Chunk #$chunkCount ➔ Saved new checkpoint cursor to SQLite: $activeCursor",
            );
          } else {
            log(
              "[SYNC GET] Chunk #$chunkCount ➔ Cursor did not change or returned null. Completing GET sync loop.",
            );
            hasMore = false;
          }
          log("────────────────────────────────────────────────────");
        } else {
          log(
            "[SYNC GET ERROR] Chunk #$chunkCount ➔ Failed HTTP status: ${response.statusCode} - ${response.statusMessage}",
          );
          return Left(
            "Failed to pull transactions at chunk #$chunkCount: ${response.statusCode}",
          );
        }
      } while (hasMore && activeCursor != null);

      log("════════════════════════════════════════════════════");
      log(
        "[SYNC GET COMPLETE] Successfully synced $totalItemsSynced items across $chunkCount chunks!",
      );
      log("════════════════════════════════════════════════════");

      return Right(
        "Pulled transactions successfully ($chunkCount chunks, $totalItemsSynced items).",
      );
    } catch (e, stackTrace) {
      log("[SYNC GET ERROR] Exception occurred during GET sync: $e");
      log("[SYNC GET STACKTRACE] $stackTrace");
      return Left("Error pulling transactions: $e");
    } finally {
      await db.execute('PRAGMA foreign_keys = ON;');
    }
  }

  Future<Either<String, String>> syncCashRegistersFromServer({  
    void Function(int chunkCount, int totalItems)? onProgress,
  }) async {
    try {
      log("════════════════════════════════════════════════════");
      log("[SYNC CASH REGISTERS] Starting cursor-based GET down-sync...");

      String? currentCursor = await _dbHelper.getSyncCheckpoint(
        ApiClient.cashRegistersGetApi,
      );
      log(
        "[SYNC CASH REGISTERS] Loaded Initial Checkpoint Cursor: ${currentCursor ?? 'null (First Sync)'}",
      );
      log("────────────────────────────────────────────────────");

      bool hasMore = true;
      int chunkCount = 0;
      int totalItemsSynced = 0;
      String? activeCursor = currentCursor;

      do {
        chunkCount++;
        Map<String, dynamic> queryParams = {'limit': 100};

        if (activeCursor != null && activeCursor.isNotEmpty) {
          queryParams['cursor'] = activeCursor;
        }

        log(
          "[SYNC CASH REGISTERS] Chunk #$chunkCount ➔ Sending Request: GET ${ApiClient.cashRegistersGetApi} with params: $queryParams",
        );

        final response = await ApiClient.dio.get(
          ApiClient.cashRegistersGetApi,
          queryParameters: queryParams,
        );

        log(
          "[SYNC CASH REGISTERS] Chunk #$chunkCount ➔ Response Received! Status Code: ${response.statusCode}",
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = response.data['data'] ?? [];
          final bool serverHasMore = response.data['has_more'] as bool? ?? false;
          final String? nextCursorFromServer =
              response.data['next_cursor'] as String?;

          log(
            "[SYNC CASH REGISTERS] Chunk #$chunkCount ➔ Items in batch: ${data.length} | Next Cursor: ${nextCursorFromServer ?? 'null'} | Has More: $serverHasMore",
          );

          if (data.isNotEmpty) {
            for (var item in data) {
              var registerData = Map<String, dynamic>.from(item);
              registerData['is_synced'] = 1;
              registerData.remove("is_sync");
              await _dbHelper.syncCashRegister(registerData);
            }

            totalItemsSynced += data.length;
            if (onProgress != null) {
              onProgress(chunkCount, totalItemsSynced);
            }
          }

          if (nextCursorFromServer != null &&
              nextCursorFromServer.isNotEmpty &&
              nextCursorFromServer != activeCursor) {
            activeCursor = nextCursorFromServer;
            hasMore = serverHasMore;
            await _dbHelper.saveSyncCheckpoint(
              ApiClient.cashRegistersGetApi,
              cursor: activeCursor,
            );
            log(
              "[SYNC CASH REGISTERS] Chunk #$chunkCount ➔ Saved new checkpoint cursor to SQLite: $activeCursor",
            );
          } else {
            log(
              "[SYNC CASH REGISTERS] Chunk #$chunkCount ➔ Cursor did not change or returned null. Completing GET sync loop.",
            );
            hasMore = false;
          }
          log("────────────────────────────────────────────────────");
        } else {
          log(
            "[SYNC CASH REGISTERS ERROR] Chunk #$chunkCount ➔ Failed HTTP status: ${response.statusCode} - ${response.statusMessage}",
          );
          return Left(
            "Failed to pull cash registers at chunk #$chunkCount: ${response.statusCode}",
          );
        }
      } while (hasMore && activeCursor != null);

      log("════════════════════════════════════════════════════");
      log(
        "[SYNC CASH REGISTERS COMPLETE] Successfully synced $totalItemsSynced cash registers across $chunkCount chunks!",
      );
      log("════════════════════════════════════════════════════");

      return Right(
        "Pulled cash registers successfully ($chunkCount chunks, $totalItemsSynced items).",
      );
    } catch (e, stackTrace) {
      log("[SYNC CASH REGISTERS ERROR] Exception occurred during GET sync: $e");
      log("[SYNC CASH REGISTERS STACKTRACE] $stackTrace");
      return Left("Error pulling cash registers: $e");
    }
  }

  Future<void> _processTransaction(Map<String, dynamic> transactionMap) async {
    try {
      // Extract details (services) and payments
      final details =
          (transactionMap['details'] as List<dynamic>?)?.map((e) {
            final map = Map<String, dynamic>.from(e as Map<String, dynamic>);
            map['is_synced'] = 1;
            map.remove("is_sync");
            return map;
          }).toList() ??
          [];

      final payments =
          (transactionMap['payments'] as List<dynamic>?)?.map((e) {
            final map = Map<String, dynamic>.from(e as Map<String, dynamic>);
            map.remove("is_sync");
            map['is_synced'] = 1;
            return map;
          }).toList() ??
          [];

      // Prepare transaction data for DB (remove nested lists/objects)
      final transactionForDb = Map<String, dynamic>.from(transactionMap);
      transactionForDb.remove('details');
      transactionForDb.remove('payments');
      transactionForDb.remove('user'); // If user object is nested
      transactionForDb.remove('chair'); // If chair object is nested

      // Force is_synced to 1 because we just got it from server
      transactionForDb['is_synced'] = 1;

      await _dbHelper.syncTransaction(
        transactionData: transactionForDb,
        services: details,
        payments: payments,
      );
    } catch (e) {
      log("Failed to sync transaction ${transactionMap['id']}: $e");
    }
  }
}
