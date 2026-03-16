import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:sharp_cut/core/database/database_helper.dart';
import 'package:sharp_cut/core/utils/date_formatter.dart';
import 'package:sharp_cut/domain/booking/models/rebooking_model.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/booking/models/customer_suggestion_model.dart';
import 'package:sharp_cut/utils/helpers/convertion.dart';

class TransactionDao {
  final Future<Database> _dbFuture;

  TransactionDao(this._dbFuture);

  /// Create a new booking (transaction + services)
  Future<int> createBooking(
    Map<String, dynamic> transactionData,
    List<Map<String, dynamic>> services,
  ) async {
    log("Creating booking for chair ${transactionData['chair_id']}");
    final db = await _dbFuture;
    return await db.transaction((txn) async {
      // 1. Insert Transaction
      if (transactionData['created_at'] == null) {
        transactionData['created_at'] = DateFormatter.now();
      }
      transactionData['updated_at'] = DateFormatter.now();

      int transactionId = await txn.insert('transactions', transactionData);
      log("Inserted transaction ID: $transactionId");

      // 2. Insert Services
      Batch batch = txn.batch();
      for (var service in services) {
        // Ensure transaction_id is set
        var serviceData = Map<String, dynamic>.from(service);
        serviceData['transaction_id'] = transactionId;
        serviceData['detail_id'] = generateUniqueInt();
        serviceData['created_at'] = DateFormatter.now();
        serviceData['updated_at'] = DateFormatter.now();
        batch.insert('transaction_services', serviceData);
      }
      await batch.commit(noResult: true);
      log(
        "Inserted ${services.length} services for transaction $transactionId",
      );

      return transactionId;
    });
  }

  /// Settle payment for a booking
  Future<void> settlePayment(SettlePaymentRequestModel request) async {
    log("Settling payment for transaction ${request.transactionId}");
    final db = await _dbFuture;

    // Retrieve the transaction to check its current invoice_no
    final transactionResult = await db.query(
      'transactions',
      columns: ['invoice_no'],
      where: 'id = ?',
      whereArgs: [request.transactionId],
    );

    String? newInvoiceNo;
    String? newInvoiceDate;

    if (transactionResult.isNotEmpty) {
      final currentInvoiceNo = transactionResult.first['invoice_no'] as String?;
      if (currentInvoiceNo == null) {
        final invoiceSettings = await DatabaseHelper().getInvoiceSettings();
        if (invoiceSettings != null) {
          final prefix = invoiceSettings['invoice_prefix'];
          final year = invoiceSettings['financial_year'];
          final count = (invoiceSettings['count'] as int) + 1;
          newInvoiceNo = "$prefix/$year/$count";

          // Increment count in DB
          await DatabaseHelper().incrementInvoiceCount();
        } else {
          newInvoiceNo = await DatabaseHelper().generateInvoiceNumber();
        }
        newInvoiceDate = DateFormatter.dateonly(DateTime.now());
      }
    }

    await db.transaction((txn) async {
      // Calculate Tax and Grand Total after Discount
      final double finalTotal = request.finalTotal ?? 0.0;
      final double discount = request.discount ?? 0.0;

      double? grandTotalAfter;
      double? taxTotalAfter;

      double netTotal = finalTotal;
      if (discount > 0) {
        netTotal = finalTotal - discount;
        grandTotalAfter = netTotal / 1.05;
        taxTotalAfter = netTotal - grandTotalAfter;
      }
      // Assuming 5% VAT

      final updateData = {
        'status': "completed",
        'payment_status': request.paymentStatus,
        'customer_name': request.customerName,
        'customer_number': request.customerNumber,
        'grand_total': request.subTotalValue,
        'tax_total': request.taxTotal,
        'discount': request.discount,
        'round_off': request.roundOff,
        'final_total': request.finalTotal,
        'final_total_before': request.finalTotalbefore ?? request.finalTotal,
        'final_total_after': netTotal,
        'grand_total_after': grandTotalAfter,
        'tax_total_after': taxTotalAfter,
        'total_payment':
            request.amount?.fold(0.0, (sum, item) => sum + item) ?? 0.0,
        'updated_at': DateFormatter.now(),
        'end_time': DateFormatter.now(),
        'is_synced': 0,
        if (newInvoiceNo != null) 'invoice_no': newInvoiceNo,
        if (newInvoiceDate != null) 'invoice_date': newInvoiceDate,
      };

      await txn.update(
        'transactions',
        updateData,
        where: 'id = ?',
        whereArgs: [request.transactionId],
      );

      log("Updated transaction ${request.transactionId} status");

      // 2. Insert Payments
      Batch batch = txn.batch();
      if (request.mode != null && request.amount != null) {
        for (int i = 0; i < request.mode!.length; i++) {
          final paymentData = {
            'transaction_id': request.transactionId,
            'mode': request.mode![i],
            'amount': request.amount![i],
            'tender_cash':
                (request.tenderCash != null && i < request.tenderCash!.length)
                ? request.tenderCash![i]
                : 0.0,
            'change': (request.change != null && i < request.change!.length)
                ? request.change![i]
                : 0.0,
            'date': DateFormatter.now(),
            'collected_user_id':
                (request.collectedUserId != null &&
                    i < request.collectedUserId!.length)
                ? request.collectedUserId![i]
                : null,
            'payment_id': generateUniqueInt(),
            'created_at': DateFormatter.now(),
            'updated_at': DateFormatter.now(),
          };
          batch.insert('transaction_payments', paymentData);
        }
      }

      // 3. Insert Services (if provided)
      if (request.serviceId != null && request.serviceId!.isNotEmpty) {
        // First delete existing services to avoid duplication/conflicts if re-settling or updating
        await txn.delete(
          'transaction_services',
          where: 'transaction_id = ?',
          whereArgs: [request.transactionId],
        );

        for (int i = 0; i < request.serviceId!.length; i++) {
          final serviceData = {
            'transaction_id': request.transactionId,
            'service_id': request.serviceId![i],
            'quantity':
                (request.quantity != null && i < request.quantity!.length)
                ? request.quantity![i]
                : 1,
            'rate': (request.rate != null && i < request.rate!.length)
                ? request.rate![i]
                : 0.0,
            'tax': (request.tax != null && i < request.tax!.length)
                ? request.tax![i]
                : 0.0,
            'tax_amount':
                (request.taxAmount != null && i < request.taxAmount!.length)
                ? request.taxAmount![i]
                : 0.0,
            'sub_total':
                (request.subTotalList != null &&
                    i < request.subTotalList!.length)
                ? request.subTotalList![i]
                : 0.0,
            'amount_total':
                (request.amountTotal != null && i < request.amountTotal!.length)
                ? request.amountTotal![i]
                : 0.0,
            'is_tip': (request.isTip != null && i < request.isTip!.length)
                ? request.isTip![i]
                : 0,
            'detail_id': generateUniqueInt(),
            'created_at': DateFormatter.now(),
            'updated_at': DateFormatter.now(),
          };
          batch.insert('transaction_services', serviceData);
        }
      }

      await batch.commit(noResult: true);
      log(
        "Inserted payments and services for transaction ${request.transactionId}",
      );
    });
  }

  /// Re-settle payment for a booking
  /// Updates discount, recalculates totals, and appends new payments
  Future<void> reSettlePayment(ResettleModel request) async {
    log("Re-settling payment for transaction ${request.transactionId}");
    final db = await _dbFuture;
    await db.transaction((txn) async {
      // 1. Fetch current transaction details
      final transactionResult = await txn.query(
        'transactions',
        columns: [
          'grand_total',
          'tax_total',
          'round_off',
          'final_total',
          'final_total_before',
        ],
        where: 'id = ?',
        whereArgs: [request.transactionId],
      );

      if (transactionResult.isEmpty) {
        throw Exception("Transaction not found");
      }

      final transaction = transactionResult.first;

      final finalTotal =
          (transaction['final_total'] as num?)?.toDouble() ?? 0.0;

      // 2. Calculate new Final Total
      final newDiscount = request.discount ?? 0.0;
      double? newGrandTotalAfter;
      double? newTaxTotalAfter;

      double netTotal = finalTotal;
      if (newDiscount > 0) {
        netTotal = finalTotal - newDiscount;
        newGrandTotalAfter = netTotal / 1.05;
        newTaxTotalAfter = netTotal - newGrandTotalAfter;
      }

      log("newGrandTotalAfter: $newGrandTotalAfter");
      log("newTaxTotalAfter: $newTaxTotalAfter");

      // 3. Insert NEW Payments (Append)
      if (request.mode != null && request.amount != null) {
        Batch batch = txn.batch();
        for (int i = 0; i < request.mode!.length; i++) {
          final paymentData = {
            'transaction_id': request.transactionId,
            'mode': request.mode![i],
            'amount': request.amount![i],
            'tender_cash':
                (request.tenderCash != null && i < request.tenderCash!.length)
                ? request.tenderCash![i]
                : 0.0,
            'change': (request.change != null && i < request.change!.length)
                ? request.change![i]
                : 0.0,
            'date': DateFormatter.now(),
            'collected_user_id':
                (request.collectedUserId != null &&
                    i < request.collectedUserId!.length)
                ? request.collectedUserId![i]
                : null,
            'payment_id': generateUniqueInt(),
            'created_at': DateFormatter.now(),
            'updated_at': DateFormatter.now(),
          };
          batch.insert('transaction_payments', paymentData);
        }
        await batch.commit(noResult: true);
      }

      // 4. Calculate New Total Payment (Sum of ALL payments)
      final paymentSumResult = await txn.rawQuery(
        'SELECT SUM(amount) as total FROM transaction_payments WHERE transaction_id = ?',
        [request.transactionId],
      );
      final newTotalPayment =
          (paymentSumResult.first['total'] as num?)?.toDouble() ?? 0.0;

      // 5. Determine Payment Status
      String newPaymentStatus = 'partial';
      if ((newTotalPayment + newDiscount + 0.01) >= finalTotal) {
        newPaymentStatus = 'full';
      }

      // 6. Update Transaction
      final updateData = {
        'discount': newDiscount,
        'total_payment': newTotalPayment,
        'payment_status': newPaymentStatus,
        'updated_at': DateFormatter.now(),
        'final_total_after': netTotal,
        if (newGrandTotalAfter != null) 'grand_total_after': newGrandTotalAfter,
        if (newTaxTotalAfter != null) 'tax_total_after': newTaxTotalAfter,
        'is_synced': 0,
      };

      await txn.update(
        'transactions',
        updateData,
        where: 'id = ?',
        whereArgs: [request.transactionId],
      );

      log(
        "Resettled transaction ${request.transactionId}. New Final: $finalTotal, Paid: $newTotalPayment, Status: $newPaymentStatus",
      );
    });
  }

  Map<String, dynamic> _sanitizeDbData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is bool) {
        sanitized[key] = value ? 1 : 0;
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  /// Sync a transaction from API to Local DB
  Future<void> syncTransaction({
    required Map<String, dynamic> transactionData,
    required List<Map<String, dynamic>> services,
    required List<Map<String, dynamic>> payments,
  }) async {
    log("Syncing transaction ${transactionData['id']} to local DB");
    final db = await _dbFuture;
    await db.transaction((txn) async {
      final transactionId = transactionData['id'];

      // Check for discount and update totals accordingly
      final discount = (transactionData['discount'] as num?)?.toDouble() ?? 0.0;
      if (discount > 0) {
        transactionData['final_total_after'] = transactionData['final_total'];
        transactionData['final_total'] = transactionData['final_total_before'];

        transactionData['tax_total_after'] = transactionData['tax_total'];
        transactionData['tax_total'] = transactionData['tax_total_before'];

        transactionData['grand_total_after'] = transactionData['grand_total'];
        transactionData['grand_total'] = transactionData['grand_total_before'];
      }

      // 1. Upsert Transaction
      await txn.insert(
        'transactions',
        _sanitizeDbData(transactionData),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Sync Services
      await txn.delete(
        'transaction_services',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      Batch serviceBatch = txn.batch();
      for (var service in services) {
        var serviceData = Map<String, dynamic>.from(service);
        serviceData.remove('service');
        serviceData['transaction_id'] = transactionId;
        if (serviceData['detail_id'] == null) {
          serviceData['detail_id'] = generateUniqueInt();
        }
        if (serviceData['created_at'] == null) {
          serviceData['created_at'] = DateFormatter.now();
        }
        if (serviceData['updated_at'] == null) {
          serviceData['updated_at'] = DateFormatter.now();
        }
        serviceBatch.insert(
          'transaction_services',
          _sanitizeDbData(serviceData),
        );
      }
      await serviceBatch.commit(noResult: true);

      // 3. Sync Payments
      await txn.delete(
        'transaction_payments',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      Batch paymentBatch = txn.batch();
      for (var payment in payments) {
        var paymentData = Map<String, dynamic>.from(payment);
        paymentData['transaction_id'] = transactionId;
        if (paymentData['payment_id'] == null) {
          paymentData['payment_id'] = generateUniqueInt();
        }
        if (paymentData['created_at'] == null) {
          paymentData['created_at'] = DateFormatter.now();
        }
        if (paymentData['updated_at'] == null) {
          paymentData['updated_at'] = DateFormatter.now();
        }
        paymentBatch.insert(
          'transaction_payments',
          _sanitizeDbData(paymentData),
        );
      }
      await paymentBatch.commit(noResult: true);
    });
    log("Synced transaction ${transactionData['id']} successfully");
  }

  /// Fetch full booking details by transaction ID
  Future<Map<String, dynamic>?> getBookingDetails(int transactionId) async {
    log("Fetching booking details for transaction $transactionId");
    final db = await _dbFuture;

    final transactionResult = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    if (transactionResult.isEmpty) return null;

    Map<String, dynamic> transactionData = Map<String, dynamic>.from(
      transactionResult.first,
    );

    // Fetch Services
    final servicesResult = await db.query(
      'transaction_services',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );

    // Fetch Payments
    final paymentsResult = await db.query(
      'transaction_payments',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );

    // Fetch User (Staff)
    final userId = transactionData['user_id'] as int;
    final userResult = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (userResult.isNotEmpty) {
      transactionData['user'] = userResult.first;
    }

    transactionData['details'] = servicesResult;
    transactionData['payments'] = paymentsResult;

    return transactionData;
  }

  Future<bool> hasPendingTransactions(int cashRegisterId) async {
    log("Checking for pending transactions for register $cashRegisterId");
    final db = await _dbFuture;
    final result = await db.query(
      'transactions',
      where: 'LOWER(status) = ? AND cash_register_id = ?',
      whereArgs: ['pending', cashRegisterId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getUnsyncedTransactions() async {
    log("Fetching unsynced transactions");
    final db = await _dbFuture;
    return await db.query(
      'transactions',
      where: 'is_synced = ? AND LOWER(status) = ?',
      whereArgs: [0, 'completed'],
    );
  }

  Future<void> markTransactionsAsSynced(List<int> ids) async {
    log("Marking transactions $ids as synced");
    final db = await _dbFuture;
    await db.transaction((txn) async {
      Batch batch = txn.batch();
      for (var id in ids) {
        batch.update(
          'transactions',
          {'is_synced': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Map<String, dynamic>>> getTransactionServices(
    int transactionId,
  ) async {
    final db = await _dbFuture;
    return await db.query(
      'transaction_services',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionPayments(
    int transactionId,
  ) async {
    final db = await _dbFuture;
    return await db.query(
      'transaction_payments',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
  }

  Future<void> cancelBooking(int transactionId, String reason) async {
    log("Cancelling transaction $transactionId");
    final db = await _dbFuture;
    await db.update(
      'transactions',
      {
        'status': 'cancelled',
        'cancellation_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [transactionId],
    );
    log("Transaction $transactionId cancelled");
  }

  Future<void> updatePaymentMode({
    required int paymentId,
    required int transactionId,
    required String mode,
    required double amount,
  }) async {
    log(
      "Updating payment $paymentId for transaction $transactionId. New Mode: $mode, New Amount: $amount",
    );
    final db = await _dbFuture;

    await db.transaction((txn) async {
      // 1. Fetch Transaction Final Total and Cash Register ID
      final transactionResult = await txn.query(
        'transactions',
        columns: ['final_total', 'cash_register_id'],
        where: 'id = ?',
        whereArgs: [transactionId],
      );

      if (transactionResult.isEmpty) {
        throw Exception("Transaction $transactionId not found");
      }

      final transactionRow = transactionResult.first;
      final finalTotal =
          (transactionRow['final_total'] as num?)?.toDouble() ?? 0.0;
      final cashRegisterId = transactionRow['cash_register_id'] as int?;

      if (cashRegisterId != null) {
        final cashRegisterResult = await txn.query(
          'cash_registers',
          columns: ['closed_at'],
          where: 'id = ?',
          whereArgs: [cashRegisterId],
        );

        if (cashRegisterResult.isNotEmpty) {
          final closedAt = cashRegisterResult.first['closed_at'];
          if (closedAt != null) {
            throw Exception(
              "this transaction cashregister is closed cant edit ",
            );
          }
        }
      }

      // 2. Calculate Sum of OTHER payments
      final otherPaymentsResult = await txn.rawQuery(
        'SELECT SUM(amount) as total FROM transaction_payments WHERE transaction_id = ? AND id != ?',
        [transactionId, paymentId],
      );

      final otherPaymentsTotal =
          (otherPaymentsResult.first['total'] as num?)?.toDouble() ?? 0.0;

      final potentialTotal = otherPaymentsTotal + amount;

      // 3. Validate
      if (potentialTotal > finalTotal) {
        throw Exception(
          "Total payment ($potentialTotal) exceeds transaction total ($finalTotal).",
        );
      }

      // 4. Update the Payment
      await txn.update(
        'transaction_payments',
        {'mode': mode, 'amount': amount, 'updated_at': DateFormatter.now()},
        where: 'id = ?',
        whereArgs: [paymentId],
      );

      // 5. Update Transaction Totals & Status
      String newPaymentStatus = 'partial';
      if (potentialTotal >= finalTotal) {
        newPaymentStatus = 'full';
      }

      await txn.update(
        'transactions',
        {
          'total_payment': potentialTotal,
          'payment_status': newPaymentStatus,
          'is_synced': 0, // Mark for sync
          'updated_at': DateFormatter.now(),
        },
        where: 'id = ?',
        whereArgs: [transactionId],
      );

      log(
        "Payment updated successfully. New Transaction Total: $potentialTotal, Status: $newPaymentStatus",
      );
    });
  }

  Future<Map<String, dynamic>> getTransactionsForRegister(
    String openedAt,
    String closedAt,
  ) async {
    log("Fetching transactions between $openedAt and $closedAt");
    final db = await _dbFuture;

    final result = await db.rawQuery(
      '''
      SELECT 
        t.id,
        t.invoice_no,
        t.final_total,
        t.payment_status,
        t.customer_name,
        t.transaction_date,
        tp.mode,
        tp.amount
      FROM transactions t
      LEFT JOIN transaction_payments tp ON t.id = tp.transaction_id
      WHERE t.created_at >= ? AND t.created_at <= ? AND LOWER(t.status) = 'completed'
      ''',
      [openedAt, closedAt],
    );

    double cashAmount = 0.0;
    int cashCount = 0;
    double cardAmount = 0.0;
    int cardCount = 0;

    for (var row in result) {
      final mode = row['mode'] as String?;
      final amount = (row['amount'] as num?)?.toDouble() ?? 0.0;

      if (mode == 'cash') {
        cashAmount += amount;
        cashCount++;
      } else if (mode == 'card' || mode == 'online') {
        cardAmount += amount;
        cardCount++;
      }
    }

    return {
      'cash_customer_count': cashCount,
      'cash_customer_amount': cashAmount,
      'card_customer_count': cardCount,
      'card_customer_amount': cardAmount,
    };
  }

  /// Generates data for the offline close register report
  Future<Map<String, dynamic>> getOfflineReportData(int registerId) async {
    log("Generating offline report data for register $registerId");
    final db = await _dbFuture;

    // 1. Get Register Details
    final registerResult = await db.query(
      'cash_registers',
      where: 'id = ?',
      whereArgs: [registerId],
    );
    if (registerResult.isEmpty) {
      throw Exception("Register not found");
    }
    final register = registerResult.first;
    final openedAt = register['opened_at'] as String;
    final closedAt = register['closed_at'] as String? ?? DateFormatter.now();

    // 2. Get Transactions in range
    final transactionsResult = await db.rawQuery(
      '''
      SELECT * FROM transactions 
      WHERE created_at >= ? AND LOWER(status) = 'completed' AND cash_register_id = ?
      ''',
      [openedAt, registerId],
    );

    final transactionIds = transactionsResult.map((t) => t['id']).toList();

    // 3. Calculate Invoice Details
    int totalInvoice = transactionsResult.length;
    double totalInvoiceSalesAmount = 0.0;
    double totalDiscount = 0.0;

    for (var t in transactionsResult) {
      totalInvoiceSalesAmount += (t['final_total'] as num?)?.toDouble() ?? 0.0;
      totalDiscount += (t['discount'] as num?)?.toDouble() ?? 0.0;
    }

    // 4. Get Payments for these transactions
    List<Map<String, dynamic>> paymentsResult = [];
    if (transactionIds.isNotEmpty) {
      final placeholders = List.filled(transactionIds.length, '?').join(',');
      paymentsResult = await db.rawQuery('''
        SELECT * FROM transaction_payments 
        WHERE transaction_id IN ($placeholders)
        ''', transactionIds);
    }

    double totalPayments = 0.0;
    double cashAmount = 0.0;
    int cashCount = 0;
    double cardAmount = 0.0;
    int cardCount = 0;

    // Track unique transactions for counts
    Set<int> cashTransactionIds = {};
    Set<int> cardTransactionIds = {};

    for (var p in paymentsResult) {
      double amount = (p['amount'] as num?)?.toDouble() ?? 0.0;
      String mode = p['mode'] as String;
      int tId = p['transaction_id'] as int;

      totalPayments += amount;

      if (mode == 'cash') {
        cashAmount += amount;
        cashTransactionIds.add(tId);
      } else if (mode == 'card' || mode == 'online') {
        cardAmount += amount;
        cardTransactionIds.add(tId);
      }
    }

    cashCount = cashTransactionIds.length;
    cardCount = cardTransactionIds.length;

    double totalUnpaidAmount = totalInvoiceSalesAmount - totalPayments;
    double totalCreditAmount = 0.0;

    // 5. Salesman Wise Details
    Map<int, Map<String, double>> salesmanStats = {};

    for (var p in paymentsResult) {
      int? userId = p['collected_user_id'] as int?;
      if (userId == null) continue;

      double amount = (p['amount'] as num?)?.toDouble() ?? 0.0;
      String mode = p['mode'] as String;

      salesmanStats.putIfAbsent(userId, () => {'cash': 0.0, 'card': 0.0});

      if (mode == 'cash') {
        salesmanStats[userId]!['cash'] =
            (salesmanStats[userId]!['cash'] ?? 0.0) + amount;
      } else {
        salesmanStats[userId]!['card'] =
            (salesmanStats[userId]!['card'] ?? 0.0) + amount;
      }
    }

    List<Map<String, dynamic>> salesmanDetails = [];
    double salesmanTotalCash = 0.0;
    double salesmanTotalCard = 0.0;

    for (var entry in salesmanStats.entries) {
      int userId = entry.key;
      double cash = entry.value['cash']!;
      double card = entry.value['card']!;

      salesmanTotalCash += cash;
      salesmanTotalCard += card;

      // Get user name
      String salesmanName = 'N/A';
      final userRes = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (userRes.isNotEmpty) {
        salesmanName = userRes.first['name'] as String;
      }

      salesmanDetails.add({
        'salesman_name': salesmanName,
        'total_cash_amount': cash,
        'total_card_amount': card,
        'total_amount': cash + card,
      });
    }

    return {
      'salon_name': 'Salon Name',
      'branch': 'MAIN',
      'date_range': '$openedAt - $closedAt',
      'print_datetime': DateFormatter.now(),
      'invoice_details': {
        'total_invoice': totalInvoice,
        'total_invoice_sales_amount': totalInvoiceSalesAmount,
        'total_paid_amount': totalPayments,
        'total_unpaid_amount': totalUnpaidAmount,
        'total_discount': totalDiscount,
        'total_credit_amount': totalCreditAmount,
      },
      'customer_type_details': {
        'cash_customer_count': cashCount,
        'cash_customer_amount': cashAmount,
        'card_customer_count': cardCount,
        'card_customer_amount': cardAmount,
      },
      'salesman_wise_details': salesmanDetails,
      'salesman_totals': {
        'salesman_total_cash_amount': salesmanTotalCash,
        'salesman_total_card_amount': salesmanTotalCard,
        'salesman_total_amount': salesmanTotalCash + salesmanTotalCard,
        'salesman_total_count': salesmanDetails.length,
      },
    };
  }

  Future<List<CustomerSuggestionModel>> searchCustomers(
    String? name,
    String? number,
  ) async {
    final db = await _dbFuture;
    String? query;
    List<String> args = [];

    if (name != null && name.isNotEmpty) {
      query = "customer_name LIKE ?";
      args.add('%$name%');
    }

    if (number != null && number.isNotEmpty) {
      if (query != null) {
        query += " OR customer_number LIKE ?";
      } else {
        query = "customer_number LIKE ?";
      }
      args.add('%$number%');
    }

    if (query == null) return [];

    final result = await db.query(
      'transactions',
      distinct: true,
      columns: ['customer_name', 'customer_number'],
      where: query,
      whereArgs: args,
      limit: 20,
    );

    return result
        .map((json) => CustomerSuggestionModel.fromJson(json))
        .toList();
  }

  Future<void> updateCustomerDetails({
    required int transactionId,
    required String customerName,
    required String customerNumber,
  }) async {
    log("Updating customer details for transaction $transactionId");
    final db = await _dbFuture;
    await db.update(
      'transactions',
      {
        'customer_name': customerName,
        'customer_number': customerNumber,
        'updated_at': DateFormatter.now(),
        'is_synced': 0,
      },
      where: 'id = ?',
      whereArgs: [transactionId],
    );
  }
}
