import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/home/models/service_model.dart';
import 'package:sharp_cut/domain/home/service/service_repo.dart';

class ServiceRepoImpl implements ServiceRepo {
  @override
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await ApiClient.dio.get(ApiClient.serviceCategoriesApi);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      throw Exception('Failed to load services: $e');
    }
  }


  



}
