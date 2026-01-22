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
      final localChairs = await dbHelper.getChairs();
      final localUsers = await dbHelper.getUsers();

      if (localChairs.isNotEmpty || localUsers.isNotEmpty) {
        final chairs = <ChairModel>[];
        for (var chairData in localChairs) {
          final chairId = chairData['id'] as int;
          final chairWithTxn = await dbHelper.getChairWithActiveTransaction(
            chairId,
          );
          if (chairWithTxn?["transaction"] != null) {
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
          final isAdmin = user['is_admin'] == 1 || user['is_admin'] == true;
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
