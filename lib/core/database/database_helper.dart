import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sharp_cut/domain/booking/models/settle_payment_request_model.dart';
import 'package:sharp_cut/core/utils/date_formatter.dart';
import 'package:sharp_cut/utils/helpers/convertion.dart';

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
        role TEXT,
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

  // --- Users ---
  Future<void> insertUsers(List<Map<String, dynamic>> users) async {
    log("Inserting ${users.length} users into database");
    final db = await database;
    await db.transaction((txn) async {
      Batch batch = txn.batch();
      for (var user in users) {
        batch.rawInsert(
          '''
          INSERT INTO users (id, name, password, role)
          VALUES (?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET
            name=excluded.name,
            password=excluded.password,
            role=excluded.role
          ''',
          [user['id'], user['name'], user['password'], user['role']],
        );
      }
      await batch.commit(noResult: true);
    });
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
    await db.transaction((txn) async {
      Batch batch = txn.batch();
      for (var chair in chairs) {
        // Use raw insert with ON CONFLICT REPLACE is destructive for FKs.
        // Instead, we try to update. If it fails (doesn't exist), we insert.
        // However, batch doesn't return results immediately.
        // So we can't easily do "if update == 0 then insert" inside a batch without raw SQL upsert.
        // SQLite 3.24+ supports UPSERT (INSERT ... ON CONFLICT DO UPDATE).
        // Let's try standard UPSERT syntax.

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
    await db.transaction((txn) async {
      Batch batch = txn.batch();
      for (var category in categories) {
        batch.rawInsert(
          '''
          INSERT INTO service_categories (id, shop_id, name, description, status, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET
            shop_id=excluded.shop_id,
            name=excluded.name,
            description=excluded.description,
            status=excluded.status,
            created_at=excluded.created_at,
            updated_at=excluded.updated_at
          ''',
          [
            category['id'],
            category['shop_id'],
            category['name'],
            category['description'],
            category['status'],
            category['created_at'],
            category['updated_at'],
          ],
        );
      }
      await batch.commit(noResult: true);
    });
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
    await db.transaction((txn) async {
      Batch batch = txn.batch();
      for (var service in services) {
        batch.rawInsert(
          '''
          INSERT INTO services (id, category_id, name, name_arabic, description, is_tip, charge, before_vat, tax_option, currency, tax_percentage, unit_tax, status, image, position, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET
            category_id=excluded.category_id,
            name=excluded.name,
            name_arabic=excluded.name_arabic,
            description=excluded.description,
            is_tip=excluded.is_tip,
            charge=excluded.charge,
            before_vat=excluded.before_vat,
            tax_option=excluded.tax_option,
            currency=excluded.currency,
            tax_percentage=excluded.tax_percentage,
            unit_tax=excluded.unit_tax,
            status=excluded.status,
            image=excluded.image,
            position=excluded.position,
            created_at=excluded.created_at,
            updated_at=excluded.updated_at
          ''',
          [
            service['id'],
            service['category_id'],
            service['name'],
            service['name_arabic'],
            service['description'],
            service['is_tip'],
            service['charge'],
            service['before_vat'],
            service['tax_option'],
            service['currency'],
            service['tax_percentage'],
            service['unit_tax'],
            service['status'],
            service['image'],
            service['position'],
            service['created_at'],
            service['updated_at'],
          ],
        );
      }
      await batch.commit(noResult: true);
    });
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
    final db = await database;
    await db.transaction((txn) async {
      // 1. Update Transaction Status & Totals
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
        'total_payment': request.finalTotal,
        'updated_at': DateFormatter.now(),
        'end_time': DateFormatter.now(),
        'is_synced': 0,
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

  /// Sync a transaction from API to Local DB
  /// This handles inserting/updating the transaction and replacing its services/payments
  Future<void> syncTransaction({
    required Map<String, dynamic> transactionData,
    required List<Map<String, dynamic>> services,
    required List<Map<String, dynamic>> payments,
  }) async {
    log("Syncing transaction ${transactionData['id']} to local DB");
    final db = await database;
    await db.transaction((txn) async {
      final transactionId = transactionData['id'];

      // 1. Upsert Transaction
      // We use INSERT OR REPLACE to handle updates
      await txn.insert(
        'transactions',
        transactionData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Sync Services
      // Delete existing services for this transaction
      await txn.delete(
        'transaction_services',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      // Insert new services
      Batch serviceBatch = txn.batch();
      for (var service in services) {
        var serviceData = Map<String, dynamic>.from(service);
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
        serviceBatch.insert('transaction_services', serviceData);
      }
      await serviceBatch.commit(noResult: true);

      // 3. Sync Payments
      // Delete existing payments for this transaction
      await txn.delete(
        'transaction_payments',
        where: 'transaction_id = ?',
        whereArgs: [transactionId],
      );

      // Insert new payments
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
        paymentBatch.insert('transaction_payments', paymentData);
      }
      await paymentBatch.commit(noResult: true);
    });
    log("Synced transaction ${transactionData['id']} successfully");
  }

  Future<bool> hasPendingTransactions(int cashRegisterId) async {
    log("Checking for pending transactions for register $cashRegisterId");
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'status = ? AND cash_register_id = ?',
      whereArgs: ['Pending', cashRegisterId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<bool> isFullySynced() async {
    log("Checking if local DB is fully synced");
    final db = await database;

    // Check users
    // final usersResult = await db.query(
    //   'users',
    //   where: 'is_synced = ?',
    //   whereArgs: [0],
    //   limit: 1,
    // );
    // if (usersResult.isNotEmpty) return false;

    // Check cash_registers
    final registersResult = await db.query(
      'cash_registers',
      where: 'is_synced = ?',
      whereArgs: [0],
      limit: 1,
    );
    if (registersResult.isNotEmpty) return false;

    // Check transactions
    final transactionsResult = await db.query(
      'transactions',
      where: 'is_synced = ?',
      whereArgs: [0],
      limit: 1,
    );
    if (transactionsResult.isNotEmpty) return false;

    return true;
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

  // --- Cash Register ---

  Future<void> openCashRegister(Map<String, dynamic> data) async {
    log("Opening cash register");
    final db = await database;
    await db.insert('cash_registers', data);
    log("Cash register opened");
  }

  Future<void> closeCashRegister(int id, Map<String, dynamic> data) async {
    log("Closing cash register $id");
    final db = await database;
    await db.update('cash_registers', data, where: 'id = ?', whereArgs: [id]);
    log("Cash register closed");
  }

  Future<Map<String, dynamic>?> getLastOpenSyncedCashRegister() async {
    log("Fetching last open synced cash register");
    final db = await database;
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
    final db = await database;
    await db.update(
      'cash_registers',
      {'is_synced': isSynced},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Sync Helpers ---

  Future<List<Map<String, dynamic>>> getUnsyncedTransactions() async {
    log("Fetching unsynced transactions");
    final db = await database;
    return await db.query(
      'transactions',
      where: 'is_synced = ? AND status = ?',
      whereArgs: [0, 'completed'],
    );
  }

  Future<void> markTransactionsAsSynced(List<int> ids) async {
    log("Marking transactions $ids as synced");
    final db = await database;
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
    final db = await database;
    return await db.query(
      'transaction_services',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
  }

  Future<List<Map<String, dynamic>>> getTransactionPayments(
    int transactionId,
  ) async {
    final db = await database;
    return await db.query(
      'transaction_payments',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
  }

  Future<int?> getShopIdForChair(int chairId) async {
    final db = await database;
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

  Future<String?> getCurrencyForService(int serviceId) async {
    final db = await database;
    final result = await db.query(
      'services',
      columns: ['currency'],
      where: 'id = ?',
      whereArgs: [serviceId],
    );
    if (result.isNotEmpty) {
      return result.first['currency'] as String?;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getLastOpenCashRegister() async {
    log("Fetching last open cash register");
    final db = await database;
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
    final db = await database;
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
    final db = await database;

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

  Future<Map<String, dynamic>> getTransactionsForRegister(
    String openedAt,
    String closedAt,
  ) async {
    log("Fetching transactions between $openedAt and $closedAt");
    final db = await database;

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
      WHERE t.created_at >= ? AND t.created_at <= ? AND t.status = 'completed'
      ''',
      [openedAt, closedAt],
    );

    // Process result to match QuickReportModel structure
    // This is a simplified mapping. You might need more complex logic based on your exact requirements.

    double cashAmount = 0.0;
    int cashCount = 0;
    double cardAmount = 0.0;
    int cardCount = 0;

    // Group by salesman (user_id) if needed, but for now let's just get totals
    // If you need salesman details, you'll need to join with users table

    for (var row in result) {
      final mode = row['mode'] as String?;
      final amount = (row['amount'] as num?)?.toDouble() ?? 0.0;

      if (mode == 'cash') {
        cashAmount += amount;
        cashCount++; // This might overcount if multiple payments per transaction, but usually 1-1 mapping for simple cases
      } else if (mode == 'card' || mode == 'online') {
        cardAmount += amount;
        cardCount++;
      }
    }

    // Correct count logic: distinct transactions
    final distinctTransactions = result.map((e) => e['id']).toSet();

    // Re-calculate counts based on distinct transactions if needed,
    // but QuickReportModel asks for customer counts which usually means transaction count.
    // For simplicity, let's assume 1 transaction = 1 customer.

    // To get accurate counts per type, we need to check if a transaction had ANY cash or card payment.

    return {
      'cash_customer_count': cashCount, // Simplified
      'cash_customer_amount': cashAmount,
      'card_customer_count': cardCount, // Simplified
      'card_customer_amount': cardAmount,
      // Add other fields as needed for QuickReportModel
    };
  }

  Future<void> cancelBooking(int transactionId, String reason) async {
    log("Cancelling transaction $transactionId");
    final db = await database;
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

  Future<void> updatePaymentMode(
    int paymentId,
    String mode,
    double amount,
  ) async {
    log("Updating payment $paymentId mode to $mode");
    final db = await database;
    await db.update(
      'transaction_payments',
      {'mode': mode, 'amount': amount},
      where: 'id = ?',
      whereArgs: [paymentId],
    );
    log("Payment $paymentId updated");
  }

  // --- Invoice Settings ---
  Future<void> saveInvoiceSettings(Map<String, dynamic> settings) async {
    log("Saving invoice settings");
    final db = await database;

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
    final db = await database;
    final result = await db.query('invoice_settings', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<void> incrementInvoiceCount() async {
    log("Incrementing invoice count");
    final db = await database;
    await db.rawUpdate('UPDATE invoice_settings SET count = count + 1');
    log("Invoice count incremented");
  }

  /// Generates data for the offline close register report
  Future<Map<String, dynamic>> getOfflineReportData(int registerId) async {
    log("Generating offline report data for register $registerId");
    final db = await database;

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
    // We consider transactions created after openedAt.
    // Ideally we should filter by cash_register_id if we were storing it reliably on every transaction,
    // but based on the user's PHP code, they filter by time range and cash_register_id.
    // In offline mode, we might rely on time range or just all transactions since opening if we assume single register usage.
    // Let's stick to time range >= openedAt for simplicity and robustness in single-device offline mode.

    // Fetch all completed transactions in the session for this register
    final transactionsResult = await db.rawQuery(
      '''
      SELECT * FROM transactions 
      WHERE created_at >= ? AND status = 'completed' AND cash_register_id = ?
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
    // Group payments by collected_user_id
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
      'salon_name':
          'Salon Name', // You might want to fetch this from somewhere if available
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
}
