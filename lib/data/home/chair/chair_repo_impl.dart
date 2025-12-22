import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/home/models/chair_model.dart';
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
}
