import 'dart:developer';
import 'package:sqflite/sqflite.dart';

class UserDao {
  final Future<Database> _dbFuture;

  UserDao(this._dbFuture);

  Future<void> insertUsers(List<Map<String, dynamic>> users) async {
    log("Inserting ${users.length} users into database");
    final db = await _dbFuture;
    await db.transaction((txn) async {
      Batch batch = txn.batch();
      for (var user in users) {
        batch.rawInsert(
          '''
          INSERT INTO users (id, name, short_name, password, role, photo) 
          VALUES (?, ?, ?, ?, ?, ?)
          ON CONFLICT(id) DO UPDATE SET 
            name=excluded.name, 
            short_name=excluded.short_name,
            password=excluded.password,
            role=excluded.role,
            photo=excluded.photo
          ''',
          [
            user['id'],
            user['name'],
            user['short_name'],
            user['password'],
            user['role'],
            user['photo'],
          ],
        );
      }
      await batch.commit(noResult: true);
    });
    log("Users insertion completed");
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    log("Fetching users from database");
    final db = await _dbFuture;
    final result = await db.query('users');
    log("Fetched ${result.length} users");
    return result;
  }

  Future<void> updateUserPassword(int id, String newPassword) async {
    log("Updating password for user $id");
    final db = await _dbFuture;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
    log("Password updated for user $id");
  }
}
