import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/domain/booking/models/rebooking_model.dart';

// Import DAOs
import 'package:sharp_cut/core/database/daos/user_dao.dart';
import 'package:sharp_cut/core/database/daos/chair_dao.dart';
import 'package:sharp_cut/core/database/daos/service_dao.dart';
import 'package:sharp_cut/core/database/daos/transaction_dao.dart';
import 'package:sharp_cut/core/database/daos/cash_register_dao.dart';
import 'package:sharp_cut/core/database/daos/invoice_dao.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // DAOs
  late final UserDao userDao;
  late final ChairDao chairDao;
  late final ServiceDao serviceDao;
  late final TransactionDao transactionDao;
  late final CashRegisterDao cashRegisterDao;
  late final InvoiceDao invoiceDao;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal() {
    userDao = UserDao(database);
    chairDao = ChairDao(database);
    serviceDao = ServiceDao(database);
    transactionDao = TransactionDao(database);
    cashRegisterDao = CashRegisterDao(database);
    invoiceDao = InvoiceDao(database);
  }

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
        short_name TEXT,
        password TEXT,
        role TEXT,
        photo TEXT,
        is_synced INTEGER DEFAULT 0
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
        cash_register_id INTEGER NOT NULL,
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
        is_synced INTEGER DEFAULT 0,
        total_sales REAL,
        expected_closing REAL,
        discrepancy REAL
      )
    ''');

    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY,
        app_id INTEGER NOT NULL,
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
        final_total_before REAL,
        invoice_no TEXT NOT NULL,
        invoice_date TEXT NOT NULL,
        status TEXT NOT NULL,
        cancellation_reason TEXT,
        is_updated INTEGER DEFAULT 0,
        created_at TEXT,
        end_time TEXT,
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
        detail_id INTEGER,
        quantity INTEGER NOT NULL,
        rate REAL NOT NULL,
        tax REAL DEFAULT 0.0,
        tax_amount REAL DEFAULT 0.0,
        sub_total REAL NOT NULL,
        amount_total REAL NOT NULL,
        currency TEXT DEFAULT 'AED',
        is_tip INTEGER DEFAULT 0,
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
        transaction_id INTEGER NOT NULL,
        payment_id INTEGER,
        collected_user_id INTEGER,
        mode TEXT NOT NULL,
        amount REAL NOT NULL,
        tender_cash REAL DEFAULT 0.0,
        change REAL DEFAULT 0.0,
        date TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
  }

  // --- Delegate to DAOs ---

  // User
  Future<void> insertUsers(List<Map<String, dynamic>> users) =>
      userDao.insertUsers(users);
  Future<List<Map<String, dynamic>>> getUsers() => userDao.getUsers();
  Future<void> updateUserPassword(int id, String newPassword) =>
      userDao.updateUserPassword(id, newPassword);

  // Chair
  Future<void> insertChairs(List<Map<String, dynamic>> chairs) =>
      chairDao.insertChairs(chairs);
  Future<List<Map<String, dynamic>>> getChairs() => chairDao.getChairs();
  Future<Map<String, dynamic>?> getChairWithActiveTransaction(int chairId) =>
      chairDao.getChairWithActiveTransaction(chairId);
  Future<int?> getShopIdForChair(int chairId) =>
      chairDao.getShopIdForChair(chairId);

  // Service
  Future<void> insertServiceCategories(List<Map<String, dynamic>> categories) =>
      serviceDao.insertServiceCategories(categories);
  Future<List<Map<String, dynamic>>> getServiceCategories() =>
      serviceDao.getServiceCategories();
  Future<void> insertServices(List<Map<String, dynamic>> services) =>
      serviceDao.insertServices(services);
  Future<List<Map<String, dynamic>>> getServices({int? categoryId}) =>
      serviceDao.getServices(categoryId: categoryId);
  Future<String?> getCurrencyForService(int serviceId) =>
      serviceDao.getCurrencyForService(serviceId);

  // Transaction
  Future<int> createBooking(
    Map<String, dynamic> transactionData,
    List<Map<String, dynamic>> services,
  ) => transactionDao.createBooking(transactionData, services);

  Future<void> settlePayment(SettlePaymentRequestModel request) =>
      transactionDao.settlePayment(request);

  Future<void> reSettlePayment(ResettleModel request) =>
      transactionDao.reSettlePayment(request);

  Future<void> syncTransaction({
    required Map<String, dynamic> transactionData,
    required List<Map<String, dynamic>> services,
    required List<Map<String, dynamic>> payments,
  }) => transactionDao.syncTransaction(
    transactionData: transactionData,
    services: services,
    payments: payments,
  );

  Future<Map<String, dynamic>?> getBookingDetails(int transactionId) =>
      transactionDao.getBookingDetails(transactionId);

  Future<bool> hasPendingTransactions(int cashRegisterId) =>
      transactionDao.hasPendingTransactions(cashRegisterId);

  Future<List<Map<String, dynamic>>> getUnsyncedTransactions() =>
      transactionDao.getUnsyncedTransactions();

  Future<void> markTransactionsAsSynced(List<int> ids) =>
      transactionDao.markTransactionsAsSynced(ids);

  Future<List<Map<String, dynamic>>> getTransactionServices(
    int transactionId,
  ) => transactionDao.getTransactionServices(transactionId);

  Future<List<Map<String, dynamic>>> getTransactionPayments(
    int transactionId,
  ) => transactionDao.getTransactionPayments(transactionId);

  Future<void> cancelBooking(int transactionId, String reason) =>
      transactionDao.cancelBooking(transactionId, reason);

  Future<void> updatePaymentMode({
    required int paymentId,
    required int transactionId,
    required String mode,
    required double amount,
  }) => transactionDao.updatePaymentMode(
    paymentId: paymentId,
    transactionId: transactionId,
    mode: mode,
    amount: amount,
  );

  Future<Map<String, dynamic>> getTransactionsForRegister(
    String openedAt,
    String closedAt,
  ) => transactionDao.getTransactionsForRegister(openedAt, closedAt);

  Future<Map<String, dynamic>> getOfflineReportData(int registerId) =>
      transactionDao.getOfflineReportData(registerId);

  // Cash Register
  Future<void> openCashRegister(Map<String, dynamic> data) =>
      cashRegisterDao.openCashRegister(data);

  Future<void> syncCashRegister(Map<String, dynamic> data) =>
      cashRegisterDao.syncCashRegister(data);

  Future<void> closeCashRegister(int id, Map<String, dynamic> data) =>
      cashRegisterDao.closeCashRegister(id, data);

  Future<Map<String, dynamic>?> getLastOpenSyncedCashRegister() =>
      cashRegisterDao.getLastOpenSyncedCashRegister();

  Future<void> updateCashRegisterSyncStatus(int id, int isSynced) =>
      cashRegisterDao.updateCashRegisterSyncStatus(id, isSynced);

  Future<Map<String, dynamic>?> getLastOpenCashRegister() =>
      cashRegisterDao.getLastOpenCashRegister();

  Future<Map<String, dynamic>?> getLastClosedCashRegister() =>
      cashRegisterDao.getLastClosedCashRegister();

  Future<Map<String, double>> calculateSalesTotal(int cashRegisterId) =>
      cashRegisterDao.calculateSalesTotal(cashRegisterId);

  // Invoice
  Future<void> saveInvoiceSettings(Map<String, dynamic> settings) =>
      invoiceDao.saveInvoiceSettings(settings);

  Future<Map<String, dynamic>?> getInvoiceSettings() =>
      invoiceDao.getInvoiceSettings();

  Future<void> incrementInvoiceCount() => invoiceDao.incrementInvoiceCount();

  Future<String> generateInvoiceNumber() => invoiceDao.generateInvoiceNumber();

  // Helper
  Future<bool> isFullySynced() async {
    log("Checking if local DB is fully synced");
    final db = await database;

    final registersResult = await db.query(
      'cash_registers',
      where: 'is_synced = ?',
      whereArgs: [0],
      limit: 1,
    );
    if (registersResult.isNotEmpty) return false;

    final transactionsResult = await db.query(
      'transactions',
      where: 'is_synced = ?',
      whereArgs: [0],
      limit: 1,
    );
    if (transactionsResult.isNotEmpty) return false;

    return true;
  }

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

  Future<bool> hasChairData() async {
    final db = await database;
    final chairs = await db.query('chairs', limit: 1);
    if (chairs.isNotEmpty) return true;

    // final users = await db.query('users', limit: 1);
    // if (users.isNotEmpty) return true;

    return false;
  }

  Future<bool> hasServiceData() async {
    final db = await database;
    final services = await db.query('services', limit: 1);
    if (services.isNotEmpty) return true;
    return false;
  }

  Future<bool> hasCategoryData() async {
    final db = await database;
    final categories = await db.query('service_categories', limit: 1);
    if (categories.isNotEmpty) return true;
    return false;
  }

  Future<bool> hasTransactionData() async {
    final db = await database;
    // Also check transactions
    final transactions = await db.query('transactions', limit: 1);
    if (transactions.isNotEmpty) return true;

    return false;
  }
}
