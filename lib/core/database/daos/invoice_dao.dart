import 'dart:developer';
import 'package:sqflite/sqflite.dart';

class InvoiceDao {
  final Future<Database> _dbFuture;

  InvoiceDao(this._dbFuture);

  Future<void> saveInvoiceSettings(Map<String, dynamic> settings) async {
    log("Saving invoice settings");
    final db = await _dbFuture;

    // Check if settings already exist
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM invoice_settings'),
    );

    if (count != null && count > 0) {
      log(
        "Invoice settings already exist. Skipping save to preserve local count.",
      );
      return;
    }

    await db.transaction((txn) async {
      await txn.delete(
        'invoice_settings',
      ); // Clear old settings (safety, though we checked count)
      await txn.insert('invoice_settings', settings);
    });
    log("Invoice settings saved");
  }

  Future<Map<String, dynamic>?> getInvoiceSettings() async {
    log("Fetching invoice settings");
    final db = await _dbFuture;
    final result = await db.query('invoice_settings', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> incrementInvoiceCount() async {
    log("Incrementing invoice count");
    final db = await _dbFuture;
    await db.rawUpdate('UPDATE invoice_settings SET count = count + 1');
    log("Invoice count incremented");
  }

  Future<String> generateInvoiceNumber() async {
    final db = await _dbFuture;

      final now = DateTime.now();
      final year = now.year;
      final month = now.month;

      // Financial year starts in April
      final fyStart = month >= 4 ? year : year - 1;
      final fyEnd = fyStart + 1;
      final currentFY = '$fyStart-$fyEnd';

      db.insert('invoice_settings', {
        'invoice_prefix': 'INV',
        'financial_year': currentFY,
        'count': 1,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      return 'INV/$currentFY/1';
    
  }

}

