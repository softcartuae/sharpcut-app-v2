import 'dart:developer';

import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/home/models/chair_model.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/domain/home/chair/chair_repo.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';
import 'package:sharp_cut/core/database/database_helper.dart';

class ChairRepoImpl implements ChairRepo {
  final DatabaseHelper dbHelper;

  ChairRepoImpl({required this.dbHelper});

  @override
  Future<List<ChairModel>> getChairs() async {
    try {
      final response = await ApiClient.dio.get(ApiClient.chairsApi);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ChairModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chairs');
      }
    } catch (e) {
      throw Exception('Failed to load chairs: $e');
    }
  }

  @override
  Future<({List<ChairModel> chairs, List<StaffModel> staffs})>
  getChairsAndStaffs() async {
    log("getChairsAndStaffs called");
    try {
      // 1. Try fetching from API

      final hasData = await dbHelper.hasChairData();

      Map<String, dynamic> data = {'users': true};
      if (hasData) {
        data['is_synced'] = 0;
      }

      final response = await ApiClient.dio.get(
        ApiClient.chairsApi,
        queryParameters: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> chairsJson = data['chairs'];
        final List<dynamic> usersJson = data['users'];
        final List<dynamic> adminJson = data['admins'];

        // 2. Parse Data

        final staffs = usersJson
            .map((json) => StaffModel.fromJson(json, role: Role.staff))
            .toList();

        final admins = adminJson
            .map((json) => StaffModel.fromJson(json, role: Role.admin))
            .toList();
        staffs.addAll(admins);

        // 3. Save to Local DB (Sync)
        try {
          // Prepare Chairs for DB
          final chairsForDb = chairsJson
              .map((json) => json as Map<String, dynamic>)
              .toList();
          await dbHelper.insertChairs(chairsForDb);

          // Prepare Users for DB
          final usersForDb = <Map<String, dynamic>>[];
          for (var user in usersJson) {
            var userMap = user as Map<String, dynamic>;
            userMap['role'] = 'staff';
            usersForDb.add(userMap);
          }
          for (var admin in adminJson) {
            var adminMap = admin as Map<String, dynamic>;
            adminMap['role'] = 'admin';
            usersForDb.add(adminMap);
          }
          await dbHelper.insertUsers(usersForDb);

          // Sync Acknowledgement
          try {
            final chairIds = chairsJson.map((e) => e['id']).toList();
            log("chair ids $chairIds");
            if (chairIds.isNotEmpty) {
              await ApiClient.dio.post(
                ApiClient.chairsSyncApi,
                data: {'chairs': chairIds},
              );
            }

            final staffIds = usersJson.map((e) => e['id']).toList();
            log("staff ids $staffIds");
            if (staffIds.isNotEmpty) {
              await ApiClient.dio.post(
                ApiClient.usersStaffSyncApi,
                data: {'users': staffIds},
              );
            }

            final adminIds = adminJson.map((e) => e['id']).toList();
            log("admin ids $adminIds");
            if (adminIds.isNotEmpty) {
              await ApiClient.dio.post(
                ApiClient.usersAdminSyncApi,
                data: {'users': adminIds},
              );
            }
          } catch (e) {
            log("Failed to acknowledge sync: $e");
          }

          log(
            "Synced chairs, staff, and active transactions from API to Local DB",
          );
        } catch (dbError) {
          log("Failed to sync data to local DB: $dbError");
          // Continue returning API data even if sync fails, but ideally we want sync to work.
        }

        return await _getLocalChairsAndStaffs();
      } else {
        log("API returned unsuccessful status, falling back to local DB");
        throw Exception('API failed');
      }
    } catch (e) {
      log("Failed to load from API: $e. Falling back to local DB.");
      return await _getLocalChairsAndStaffs();
    }
  }

  Future<({List<ChairModel> chairs, List<StaffModel> staffs})>
  _getLocalChairsAndStaffs() async {
    try {
      final localChairs = await dbHelper.getChairs();
      final localUsers = await dbHelper.getUsers();

      if (localChairs.isNotEmpty || localUsers.isNotEmpty) {
        final chairs = <ChairModel>[];
        for (var chairData in localChairs) {
          final chairId = chairData['id'] as int;
          final chairWithTxn = await dbHelper.getChairWithActiveTransaction(
            chairId,
          );
          if (chairWithTxn?["pending_transaction"] != null) {
            // Force status to occupied if transaction exists
            chairWithTxn!["live_status"] = 'occupied';
            chairs.add(ChairModel.fromJson(chairWithTxn));
          } else {
            chairs.add(ChairModel.fromJson(chairData));
          }
        }

        final staffs = <StaffModel>[];
        for (var user in localUsers) {
          // Check if admin
          final isAdmin = user['role'] == 'admin' || user['is_admin'] == 1;
          staffs.add(
            StaffModel.fromJson(user, role: isAdmin ? Role.admin : Role.staff),
          );
        }

        return (chairs: chairs, staffs: staffs);
      }
      throw Exception('Failed to load chairs and staffs from local DB');
    } catch (localError) {
      throw Exception(
        'Failed to load chairs and staffs: . Local error: $localError',
      );
    }
  }
}
