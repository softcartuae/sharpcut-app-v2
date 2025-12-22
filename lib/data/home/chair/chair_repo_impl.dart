import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/home/models/chair_model.dart';
import 'package:sharp_cut/domain/home/models/staff_model.dart';
import 'package:sharp_cut/domain/home/chair/chair_repo.dart';

class ChairRepoImpl implements ChairRepo {
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
    try {
      final response = await ApiClient.dio.get(
        '${ApiClient.chairsApi}?users=true',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> chairsJson = data['chairs'];
        final List<dynamic> usersJson = data['users'];

        final chairs = chairsJson
            .map((json) => ChairModel.fromJson(json))
            .toList();
        final staffs = usersJson
            .map((json) => StaffModel.fromJson(json))
            .toList();

        return (chairs: chairs, staffs: staffs);
      } else {
        throw Exception('Failed to load chairs and staffs');
      }
    } catch (e) {
      throw Exception('Failed to load chairs and staffs: $e');
    }
  }
}
