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
    log("getChairsAndStaffs caaled");
    try {
      final response = await ApiClient.dio.get(
        '${ApiClient.chairsApi}?users=true',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> chairsJson = data['chairs'];
        final List<dynamic> usersJson = data['users'];
        final List<dynamic> adminJson = data['admins'];

        // Cache data locally
        final chairsToInsert = chairsJson.map((chair) {
          final chairMap = Map<String, dynamic>.from(chair as Map);
          chairMap.remove('transaction');
          return chairMap;
        }).toList();

        await dbHelper.insertChairs(chairsToInsert);

        // Combine users and admins for caching
        // We might need to ensure is_admin is set correctly if the API doesn't provide it explicitly in the object
        // assuming the API returns full user objects.
        final allUsers = <Map<String, dynamic>>[];
        allUsers.addAll(usersJson.cast<Map<String, dynamic>>());
        allUsers.addAll(adminJson.cast<Map<String, dynamic>>());
        await dbHelper.insertUsers(allUsers);

        final chairs = chairsJson
            .map((json) => ChairModel.fromJson(json))
            .toList();

        // some staffs can be admin too so we need to check it
        final staffs = usersJson
            .map((json) => StaffModel.fromJson(json, role: Role.staff))
            .toList();

        final admins = adminJson
            .map((json) => StaffModel.fromJson(json, role: Role.admin))
            .toList();
        // add admins too to the staff list but we can identify them by role
        staffs.addAll(admins);

        return (chairs: chairs, staffs: staffs);
      } else {
        throw Exception('Failed to load chairs and staffs');
      }
    } catch (e) {
      log('Error fetching from API, trying local DB: $e');
      try {
        final localChairs = await dbHelper.getChairs();
        final localUsers = await dbHelper.getUsers();

        if (localChairs.isNotEmpty || localUsers.isNotEmpty) {
          final chairs = localChairs
              .map((json) => ChairModel.fromJson(json))
              .toList();

          // Filter and map users based on is_admin or logic
          // Since we saved them all in 'users' table, we need to distinguish
          // For now, we'll just return all as staff/admin based on 'is_admin' flag if available
          // or just load them.
          // The original code separated users and admins from different API keys.
          // In DB they are in one table.

          final staffs = <StaffModel>[];
          for (var user in localUsers) {
            // Check if admin
            final isAdmin = user['is_admin'] == 1 || user['is_admin'] == true;
            staffs.add(
              StaffModel.fromJson(
                user,
                role: isAdmin ? Role.admin : Role.staff,
              ),
            );
          }

          return (chairs: chairs, staffs: staffs);
        }
        throw Exception('Failed to load chairs and staffs from local DB');
      } catch (localError) {
        throw Exception(
          'Failed to load chairs and staffs: $e. Local error: $localError',
        );
      }
    }
  }
}
