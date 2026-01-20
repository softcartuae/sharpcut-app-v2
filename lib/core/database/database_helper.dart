import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sharp_cut_offline.db');
    log("path: $path");
    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        password TEXT,
        role TEXT
      )
    ''');

    // Chairs Table
    await db.execute('''
      CREATE TABLE chairs (
        id INTEGER PRIMARY KEY,
        shop_id INTEGER,
        name TEXT NOT NULL,
        live_status TEXT,
        description TEXT,
        position INTEGER,
        status INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Service Categories Table
    await db.execute('''
      CREATE TABLE service_categories (
        id INTEGER PRIMARY KEY,
        shop_id INTEGER,
        name TEXT NOT NULL,
        description TEXT,
        status INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Services Table
    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        name_arabic TEXT,
        description TEXT,
        is_tip INTEGER DEFAULT 0,
        charge REAL,
        before_vat REAL DEFAULT 0.00,
        tax_option TEXT,
        currency TEXT,
        tax_percentage REAL DEFAULT 0.00,
        unit_tax REAL,
        status INTEGER,
        image TEXT,
        position INTEGER,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (category_id) REFERENCES service_categories (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // Invoice Settings Table
    await db.execute('''
      CREATE TABLE invoice_settings (
        id INTEGER PRIMARY KEY,
        invoice_prefix TEXT,
        financial_year TEXT NOT NULL,
        count INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Cash Registers Table
    await db.execute('''
      CREATE TABLE cash_registers (
        id INTEGER PRIMARY KEY,
        opened_by INTEGER NOT NULL,
        closed_by INTEGER,
        opened_by_type TEXT NOT NULL,
        closed_by_type TEXT,
        opening_amount REAL NOT NULL,
        closing_amount REAL,
        opened_at TEXT NOT NULL,
        closed_at TEXT,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY,
        app_id TEXT NOT NULL,
        cash_register_id INTEGER,
        chair_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        customer_name TEXT,
        customer_number TEXT,
        transaction_date TEXT NOT NULL,
        grand_total REAL NOT NULL,
        before_vat REAL,
        tax_total REAL NOT NULL,
        discount REAL NOT NULL,
        round_off REAL NOT NULL,
        final_total REAL NOT NULL,
        grand_total_after REAL,
        before_vat_after REAL,
        tax_total_after REAL,
        final_total_after REAL,
        invoice_no TEXT NOT NULL,
        invoice_date TEXT NOT NULL,
        status TEXT NOT NULL,
        cancellation_reason TEXT,
        is_updated INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        payment_status TEXT,
        total_payment REAL,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (chair_id) REFERENCES chairs (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // Transaction Services Table
    await db.execute('''
      CREATE TABLE transaction_services (
        id INTEGER PRIMARY KEY,
        transaction_id INTEGER NOT NULL,
        service_id INTEGER,
        quantity INTEGER NOT NULL,
        rate REAL NOT NULL,
        tax REAL DEFAULT 0.0,
        tax_amount REAL DEFAULT 0.0,
        sub_total REAL NOT NULL,
        amount_total REAL NOT NULL,
        is_tip INTEGER DEFAULT 0,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // Transaction Payments Table
    await db.execute('''
      CREATE TABLE transaction_payments (
        id INTEGER PRIMARY KEY,
        transaction_id INTEGER NOT NULL,
        collected_user_id INTEGER,
        mode TEXT NOT NULL,
        amount REAL NOT NULL,
        tender_cash REAL DEFAULT 0.0,
        change REAL DEFAULT 0.0,
        date TEXT NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
  }

  // --- Users ---
  Future<void> insertUsers(List<Map<String, dynamic>> users) async {
    log("Inserting ${users.length} users into database");
    final db = await database;
    Batch batch = db.batch();
    for (var user in users) {
      batch.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    log("Users insertion completed");
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    log("Fetching users from database");
    final db = await database;
    final result = await db.query('users');
    log("Fetched ${result.length} users");
    return result;
  }

  // --- Chairs ---
  Future<void> insertChairs(List<Map<String, dynamic>> chairs) async {
    log("Inserting ${chairs.length} chairs into database");
    final db = await database;
    Batch batch = db.batch();
    for (var chair in chairs) {
      batch.insert(
        'chairs',
        chair,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    log("Chairs insertion completed");
  }

  Future<List<Map<String, dynamic>>> getChairs() async {
    log("Fetching chairs from database");
    final db = await database;
    final result = await db.query('chairs');
    log("Fetched ${result.length} chairs");
    return result;
  }

  // --- Service Categories ---
  Future<void> insertServiceCategories(
    List<Map<String, dynamic>> categories,
  ) async {
    log("Inserting ${categories.length} service categories into database");
    final db = await database;
    Batch batch = db.batch();
    for (var category in categories) {
      batch.insert(
        'service_categories',
        category,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    log("Service categories insertion completed");
  }

  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    log("Fetching service categories from database");
    final db = await database;
    final result = await db.query('service_categories');
    log("Fetched ${result.length} service categories");
    return result;
  }

  // --- Services ---
  Future<void> insertServices(List<Map<String, dynamic>> services) async {
    log("Inserting ${services.length} services into database");
    final db = await database;
    Batch batch = db.batch();
    for (var service in services) {
      batch.insert(
        'services',
        service,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    log("Services insertion completed");
  }

  Future<List<Map<String, dynamic>>> getServices({int? categoryId}) async {
    log(
      "Fetching services from database${categoryId != null ? " for category $categoryId" : ""}",
    );
    final db = await database;
    if (categoryId != null) {
      final result = await db.query(
        'services',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );
      log("Fetched ${result.length} services for category $categoryId");
      return result;
    }
    final result = await db.query('services');
    log("Fetched ${result.length} services");
    return result;
  }

  // --- Transaction & Booking Flows ---

  /// Create a new booking (transaction + services)
  Future<int> createBooking(
    Map<String, dynamic> transactionData,
    List<Map<String, dynamic>> services,
  ) async {
    log("Creating booking for chair ${transactionData['chair_id']}");
    final db = await database;
    return await db.transaction((txn) async {
      // 1. Insert Transaction
      int transactionId = await txn.insert('transactions', transactionData);
      log("Inserted transaction ID: $transactionId");

      // 2. Insert Services
      Batch batch = txn.batch();
      for (var service in services) {
        // Ensure transaction_id is set
        var serviceData = Map<String, dynamic>.from(service);
        serviceData['transaction_id'] = transactionId;
        batch.insert('transaction_services', serviceData);
      }
      await batch.commit(noResult: true);
      log(
        "Inserted ${services.length} services for transaction $transactionId",
      );

      return transactionId;
    });
  }

  /// Add services to an existing booking
  Future<void> addServicesToBooking(
    int transactionId,
    List<Map<String, dynamic>> services,
  ) async {
    log("Adding ${services.length} services to transaction $transactionId");
    final db = await database;
    Batch batch = db.batch();
    for (var service in services) {
      var serviceData = Map<String, dynamic>.from(service);
      serviceData['transaction_id'] = transactionId;
      batch.insert('transaction_services', serviceData);
    }
    await batch.commit(noResult: true);
    log("Services added successfully");
  }

  /// Settle payment for a booking
  Future<void> settlePayment(
    int transactionId,
    Map<String, dynamic> updateData,
    List<Map<String, dynamic>> payments,
  ) async {
    log("Settling payment for transaction $transactionId");
    final db = await database;
    await db.transaction((txn) async {
      // 1. Update Transaction Status & Totals
      await txn.update(
        'transactions',
        updateData,
        where: 'id = ?',
        whereArgs: [transactionId],
      );
      log("Updated transaction $transactionId status");

      // 2. Insert Payments
      Batch batch = txn.batch();
      for (var payment in payments) {
        var paymentData = Map<String, dynamic>.from(payment);
        paymentData['transaction_id'] = transactionId;
        batch.insert('transaction_payments', paymentData);
      }
      await batch.commit(noResult: true);
      log(
        "Inserted ${payments.length} payments for transaction $transactionId",
      );
    });
  }

  /// Fetch Chair with its active transaction (status = 'ongoing')
  Future<Map<String, dynamic>?> getChairWithActiveTransaction(
    int chairId,
  ) async {
    log("Fetching chair $chairId with active transaction");
    final db = await database;

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
      whereArgs: [chairId, 'ongoing'],
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

  /// Fetch full booking details by transaction ID
  Future<Map<String, dynamic>?> getBookingDetails(int transactionId) async {
    log("Fetching booking details for transaction $transactionId");
    final db = await database;

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

    transactionData['details'] = servicesResult;
    transactionData['payments'] = paymentsResult;

    return transactionData;
  }

  // --- Generic Helper Methods for Viewer ---
  Future<List<String>> getTables() async {
    log("Fetching all table names");
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );
    final tables = result.map((row) => row['name'] as String).toList();
    log("Fetched ${tables.length} tables: $tables");
    return tables;
  }

  Future<List<Map<String, dynamic>>> getTableData(String tableName) async {
    log("Fetching data from table: $tableName");
    final db = await database;
    final result = await db.query(tableName);
    log("Fetched ${result.length} rows from $tableName");
    return result;
  }

  Future<void> updateUserPassword(int id, String newPassword) async {
    log("Updating password for user $id");
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
    log("Password updated for user $id");
  }
}
