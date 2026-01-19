import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sharp_cut/data/local_storage/database/entities/chair_entity.dart';
import 'package:sharp_cut/data/local_storage/database/entities/transaction_entity.dart';
import 'package:sharp_cut/data/local_storage/database/entities/transaction_service_entity.dart';
import 'package:sharp_cut/data/local_storage/database/entities/transaction_payment_entity.dart';
import 'package:sharp_cut/domain/home/models/chair_model.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/home/models/service_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'sharp_cut_offline.db');
    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chairs (
        id INTEGER PRIMARY KEY,
        shop_id INTEGER,
        name TEXT,
        description TEXT,
        position INTEGER,
        status INTEGER,
        live_status TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chair_id INTEGER,
        customer_name TEXT,
        customer_number TEXT,
        grand_total REAL,
        tax_total REAL,
        discount REAL,
        round_off REAL,
        final_total REAL,
        payment_status TEXT,
        status TEXT,
        created_at TEXT,
        FOREIGN KEY (chair_id) REFERENCES chairs (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER,
        service_id INTEGER,
        quantity INTEGER,
        rate REAL,
        tax REAL,
        tax_amount REAL,
        sub_total REAL,
        amount_total REAL,
        is_tip INTEGER,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER,
        collected_user_id INTEGER,
        mode TEXT,
        amount REAL,
        tender_cash REAL,
        change REAL,
        date TEXT,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- Functional Methods ---

  Future<int> createBooking({
    required TransactionEntity transaction,
    required List<TransactionServiceEntity> services,
  }) async {
    final db = await database;
    return await db.transaction((txn) async {
      final transactionId = await txn.insert(
        'transactions',
        transaction.toJson()..remove('id'), // Let DB auto-increment
      );

      for (var service in services) {
        await txn.insert(
          'transaction_services',
          service.toJson()
            ..remove('id')
            ..['transaction_id'] = transactionId,
        );
      }
      return transactionId;
    });
  }

  Future<void> addServices({
    required int transactionId,
    required List<TransactionServiceEntity> services,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var service in services) {
        await txn.insert(
          'transaction_services',
          service.toJson()
            ..remove('id')
            ..['transaction_id'] = transactionId,
        );
      }
    });
  }

  Future<void> settlePayment({
    required int transactionId,
    required String status,
    required String paymentStatus,
    required List<TransactionPaymentEntity> payments,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'transactions',
        {'status': status, 'payment_status': paymentStatus},
        where: 'id = ?',
        whereArgs: [transactionId],
      );

      for (var payment in payments) {
        await txn.insert(
          'transaction_payments',
          payment.toJson()
            ..remove('id')
            ..['transaction_id'] = transactionId,
        );
      }
    });
  }

  Future<ChairModel?> fetchChairWithActiveTransaction(int chairId) async {
    final db = await database;

    // Fetch Chair
    final chairMaps = await db.query(
      'chairs',
      where: 'id = ?',
      whereArgs: [chairId],
    );

    if (chairMaps.isEmpty) return null;

    final chairEntity = ChairEntity.fromJson(chairMaps.first);
    ChairModel chairModel = chairEntity.toModel();

    // Fetch Active Transaction (status != 'completed' or similar logic, assuming 'ongoing')
    final transactionMaps = await db.query(
      'transactions',
      where: 'chair_id = ? AND status = ?',
      whereArgs: [
        chairId,
        'ongoing',
      ], // Assuming 'ongoing' is the active status
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (transactionMaps.isNotEmpty) {
      final transactionEntity = TransactionEntity.fromJson(
        transactionMaps.first,
      );
      final bookingResponse = await _fetchBookingDetails(db, transactionEntity);

      // Attach transaction to chair (creating a new ChairModel as it's immutable usually, but here we can just return a new instance)
      // ChairModel has a 'transaction' field.
      chairModel = ChairModel(
        id: chairModel.id,
        shopId: chairModel.shopId,
        name: chairModel.name,
        description: chairModel.description,
        position: chairModel.position,
        status: chairModel.status,
        createdAt: chairModel.createdAt,
        updatedAt: chairModel.updatedAt,
        liveState: chairModel.liveState,
        transaction: bookingResponse,
      );
    }

    return chairModel;
  }

  Future<BookingResponseModel?> fetchBookingWithDetails(
    int transactionId,
  ) async {
    final db = await database;
    final transactionMaps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    if (transactionMaps.isEmpty) return null;

    final transactionEntity = TransactionEntity.fromJson(transactionMaps.first);
    return await _fetchBookingDetails(db, transactionEntity);
  }

  Future<BookingResponseModel> _fetchBookingDetails(
    DatabaseExecutor db,
    TransactionEntity transaction,
  ) async {
    // Fetch Services
    final serviceMaps = await db.query(
      'transaction_services',
      where: 'transaction_id = ?',
      whereArgs: [transaction.id],
    );

    final services = serviceMaps.map((map) {
      final entity = TransactionServiceEntity.fromJson(map);
      return BookingDetail(
        id: entity.id,
        quantity: entity.quantity,
        rate: entity.rate,
        amountTotal: entity.amountTotal,
        service: ServiceModel(
          id: entity.serviceId,
          charge: entity.rate, // Best effort mapping
          // Other fields are null as they are not in DB
        ),
      );
    }).toList();

    // Fetch Payments
    final paymentMaps = await db.query(
      'transaction_payments',
      where: 'transaction_id = ?',
      whereArgs: [transaction.id],
    );

    final payments = paymentMaps.map((map) {
      final entity = TransactionPaymentEntity.fromJson(map);
      return PaymentModel(
        id: entity.id,
        mode: entity.mode,
        amount: entity.amount,
        date: entity.date,
      );
    }).toList();

    return BookingResponseModel(
      id: transaction.id,
      chairId: transaction.chairId,
      customerName: transaction.customerName,
      customerNumber: transaction.customerNumber,
      finalTotal: transaction.finalTotal,
      taxTotal: transaction.taxTotal,
      discount: transaction.discount,
      paymentStatus: transaction.paymentStatus,
      status: transaction.status,
      createdAt: transaction.createdAt,
      details: services,
      payments: payments,
      // Map other fields if necessary
    );
  }
}
