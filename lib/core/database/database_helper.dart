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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        email_verified_at TEXT,
        password TEXT NOT NULL,
        remember_token TEXT,
        created_at TEXT,
        updated_at TEXT,
        status INTEGER DEFAULT 1,
        position INTEGER,
        is_admin INTEGER,
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
        charge REAL NOT NULL,
        before_vat REAL DEFAULT 0.00,
        tax_option TEXT NOT NULL,
        currency TEXT NOT NULL,
        tax_percentage REAL DEFAULT 0.00,
        unit_tax REAL NOT NULL,
        status INTEGER NOT NULL,
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
        is_synced INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Transaction Details Table
    await db.execute('''
      CREATE TABLE transaction_details (
        id INTEGER PRIMARY KEY,
        detail_id TEXT NOT NULL,
        transaction_id INTEGER NOT NULL,
        service_id INTEGER NOT NULL,
        is_tip INTEGER DEFAULT 0,
        quantity INTEGER NOT NULL,
        rate REAL NOT NULL,
        tax_amount REAL NOT NULL,
        currency TEXT NOT NULL,
        amount_total REAL NOT NULL,
        tax REAL NOT NULL,
        sub_total REAL NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // Transaction Payments Table
    await db.execute('''
      CREATE TABLE transaction_payments (
        id INTEGER PRIMARY KEY,
        payment_id TEXT NOT NULL,
        transaction_id INTEGER NOT NULL,
        collected_user_id INTEGER,
        mode TEXT NOT NULL,
        amount REAL NOT NULL,
        tender_cash REAL,
        change REAL,
        date TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // User Expenses Table
    // await db.execute('''
    //   CREATE TABLE user_expenses (
    //     id INTEGER PRIMARY KEY,
    //     app_id TEXT NOT NULL,
    //     user_id INTEGER NOT NULL,
    //     item_name TEXT NOT NULL,
    //     price REAL NOT NULL,
    //     purchase_date TEXT NOT NULL,
    //     created_at TEXT,
    //     updated_at TEXT,
    //     is_synced INTEGER DEFAULT 0
    //   )
    // ''');
  }

  // --- Users ---
  Future<void> insertUsers(List<Map<String, dynamic>> users) async {
    final db = await database;
    Batch batch = db.batch();
    for (var user in users) {
      batch.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // --- Chairs ---
  Future<void> insertChairs(List<Map<String, dynamic>> chairs) async {
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
  }

  Future<List<Map<String, dynamic>>> getChairs() async {
    final db = await database;
    return await db.query('chairs');
  }

  // --- Service Categories ---
  Future<void> insertServiceCategories(
    List<Map<String, dynamic>> categories,
  ) async {
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
  }

  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    final db = await database;
    return await db.query('service_categories');
  }

  // --- Services ---
  Future<void> insertServices(List<Map<String, dynamic>> services) async {
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
  }

  Future<List<Map<String, dynamic>>> getServices({int? categoryId}) async {
    final db = await database;
    if (categoryId != null) {
      return await db.query(
        'services',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );
    }
    return await db.query('services');
  }
}
