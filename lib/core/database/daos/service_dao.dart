import 'dart:developer';
import 'package:sqflite/sqflite.dart';

class ServiceDao {
  final Future<Database> _dbFuture;

  ServiceDao(this._dbFuture);

  Future<void> insertServiceCategories(
    List<Map<String, dynamic>> categories,
  ) async {
    log("Inserting ${categories.length} service categories into database");
    final db = await _dbFuture;
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
    final db = await _dbFuture;
    final result = await db.query('service_categories');
    log("Fetched ${result.length} service categories");
    return result;
  }

  Future<void> insertServices(List<Map<String, dynamic>> services) async {
    log("Inserting ${services.length} services into database");
    final db = await _dbFuture;
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
    final db = await _dbFuture;
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

  Future<String?> getCurrencyForService(int serviceId) async {
    final db = await _dbFuture;
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
}
