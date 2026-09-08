

import 'dart:developer';

import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/home/models/chair_model.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/domain/home/chair/chair_repo.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

class ChairRepoImpl implements ChairRepo {

  @override
  Future<({List<ChairModel> chairs, List<StaffModel> staffs})>
     getChairsAndStaffs() async {
  
    try {

      final response = await ApiClient.dio.get(
        '${ApiClient.chairsApi}?users=true',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

      
        final List<dynamic> chairsJson = data['chairs'];
        final List<dynamic> usersJson = data['users'];
        final List<dynamic> adminJson = data['admins'];

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
      throw Exception('Failed to load chairs and staffs: $e');
    }
  }


}
