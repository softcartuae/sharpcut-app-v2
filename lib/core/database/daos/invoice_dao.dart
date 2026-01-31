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
}
