import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/home/models/categorie_model.dart';
import 'package:sharp_cut/domain/home/models/service_model.dart';
import 'package:sharp_cut/domain/home/service/service_repo.dart';

class ServiceRepoImpl implements ServiceRepo {
  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await ApiClient.dio.get(ApiClient.serviceCategoriesApi);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      throw Exception('Failed to load services: $e');
    }
  }

  @override
  Future<List<ServiceModel>> getServices({int? categoryId}) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (categoryId != null) {
        queryParameters['category_id'] = categoryId;
      }

      final response = await ApiClient.dio.get(
        ApiClient.servicesApi,
        queryParameters: queryParameters,
      );

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
