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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
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
