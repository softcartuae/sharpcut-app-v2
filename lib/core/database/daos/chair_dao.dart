import 'dart:developer';
import 'package:sqflite/sqflite.dart';

class ChairDao {
  final Future<Database> _dbFuture;

  ChairDao(this._dbFuture);

  Future<void> insertChairs(List<Map<String, dynamic>> chairs) async {
    log("Inserting ${chairs.length} chairs into database");
    final db = await _dbFuture;
    await db.transaction((txn) async {
      Batch batch = txn.batch();
      for (var chair in chairs) {
        batch.rawInsert(
          '''
          INSERT INTO chairs (id, shop_id, name, live_status, description, position, status, created_at, updated_at) 
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET 
            shop_id=excluded.shop_id, 
            name=excluded.name, 
            live_status=excluded.live_status,
            description=excluded.description,
            position=excluded.position,
            status=excluded.status,
            created_at=excluded.created_at,
            updated_at=excluded.updated_at
          ''',
          [
            chair['id'],
            chair['shop_id'],
            chair['name'],
            chair['live_status'],
            chair['description'],
            chair['position'],
            chair['status'],
            chair['created_at'],
            chair['updated_at'],
          ],
        );
      }
      await batch.commit(noResult: true);
    });
    log("Chairs insertion completed");
  }

  Future<List<Map<String, dynamic>>> getChairs() async {
    log("Fetching chairs from database");
    final db = await _dbFuture;
    final result = await db.query('chairs');
    log("Fetched ${result.length} chairs");
    return result;
  }

  /// Fetch Chair with its active transaction (status = 'ongoing')
  Future<Map<String, dynamic>?> getChairWithActiveTransaction(
    int chairId,
  ) async {
    log("Fetching chair $chairId with active transaction");
    final db = await _dbFuture;

    // 1. Fetch Chair
    final chairResult = await db.query(
      'chairs',
      where: 'id = ?',
      whereArgs: [chairId],
    );

    if (chairResult.isEmpty) return null;

    Map<String, dynamic> chairData = Map<String, dynamic>.from(
      chairResult.first,
    );

    // 2. Fetch Active Transaction
    final transactionResult = await db.query(
      'transactions',
      where: 'chair_id = ? AND status = ?',
      whereArgs: [chairId, 'Pending'],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (transactionResult.isNotEmpty) {
      Map<String, dynamic> transactionData = Map<String, dynamic>.from(
        transactionResult.first,
      );
      int transactionId = transactionData['id'] as int;

      // 3. Fetch Services for this transaction
      final servicesResult = await db.query(
        'transaction_services',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      // 4. Fetch Payments for this transaction
      final paymentsResult = await db.query(
        'transaction_payments',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      // 5. Fetch User (Staff) for this transaction
      final userId = transactionData['user_id'] as int;
      final userResult = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (userResult.isNotEmpty) {
        transactionData['user'] = userResult.first;
      }

      // Construct BookingResponseModel-like map
      // Note: The caller is responsible for mapping this Map to the actual Model
      transactionData['details'] = servicesResult;
      transactionData['payments'] = paymentsResult;

      chairData['transaction'] = transactionData;
    } else {
      chairData['transaction'] = null;
    }

    return chairData;
  }

  Future<int?> getShopIdForChair(int chairId) async {
    final db = await _dbFuture;
    final result = await db.query(
      'chairs',
      columns: ['shop_id'],
      where: 'id = ?',
      whereArgs: [chairId],
    );
    if (result.isNotEmpty) {
      return result.first['shop_id'] as int?;
    }
    return null;
  }
}
