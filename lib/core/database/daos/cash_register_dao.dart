import 'dart:developer';
import 'package:sqflite/sqflite.dart';

class CashRegisterDao {
  final Future<Database> _dbFuture;

  CashRegisterDao(this._dbFuture);

  Future<void> openCashRegister(Map<String, dynamic> data) async {
    log("Opening cash register");
    final db = await _dbFuture;
    await db.insert('cash_registers', data);
    log("Cash register opened");
  }

  Future<void> syncCashRegister(Map<String, dynamic> data) async {
   
    // log("Syncing cash register ${data['id']}");
    final db = await _dbFuture;
    await db.insert(
      'cash_registers',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> closeCashRegister(int id, Map<String, dynamic> data) async {
    log("Closing cash register $id");
    final db = await _dbFuture;
    await db.update('cash_registers', data, where: 'id = ?', whereArgs: [id]);
    log("Cash register closed");
  }

  Future<Map<String, dynamic>?> getLastOpenSyncedCashRegister() async {
    log("Fetching last open synced cash register");
    final db = await _dbFuture;
    final result = await db.query(
      'cash_registers',
      where: 'is_synced = 1 AND closed_at IS NULL',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> updateCashRegisterSyncStatus(int id, int isSynced) async {
    log("Updating cash register $id sync status to $isSynced");
    final db = await _dbFuture;
    await db.update(
      'cash_registers',
      {'is_synced': isSynced},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getLastOpenCashRegister() async {
    log("Fetching last open cash register");
    final db = await _dbFuture;
    final result = await db.query(
      'cash_registers',
      where: 'closed_at IS NULL',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getLastClosedCashRegister() async {
    log("Fetching last closed cash register");
    final db = await _dbFuture;
    final result = await db.query(
      'cash_registers',
      where: 'closed_at IS NOT NULL',
      orderBy: 'closed_at DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, double>> calculateSalesTotal(int cashRegisterId) async {
    log("Calculating sales total for register $cashRegisterId");
    final db = await _dbFuture;

    final registerResult = await db.query(
      'cash_registers',
      where: 'id = ?',
      whereArgs: [cashRegisterId],
    );

    if (registerResult.isEmpty) return {'total_sales': 0.0, 'cash_total': 0.0};

    final register = registerResult.first;
    final openedAt = register['opened_at'] as String;

    // Query transaction_payments after openedAt, linked to transactions for cash_register_id
    final result = await db.rawQuery(
      '''
      SELECT 
        COUNT(DISTINCT tp.transaction_id) as count,
        SUM(tp.amount) as total_sales,
        SUM(CASE WHEN tp.mode = 'cash' THEN tp.amount ELSE 0 END) as cash_total
      FROM transaction_payments tp
      JOIN transactions t ON tp.transaction_id = t.id
      WHERE tp.date >= ? AND t.cash_register_id = ?
    ''',
      [openedAt, cashRegisterId],
    );

    double totalSales = 0.0;
    double cashTotal = 0.0;
    int count = 0;

    if (result.isNotEmpty) {
      totalSales = (result.first['total_sales'] as num?)?.toDouble() ?? 0.0;
      cashTotal = (result.first['cash_total'] as num?)?.toDouble() ?? 0.0;
      count = (result.first['count'] as num?)?.toInt() ?? 0;
    }

    return {
      'total_sales': totalSales,
      'cash_total': cashTotal,
      'count': count.toDouble(),
    };
  }
}
