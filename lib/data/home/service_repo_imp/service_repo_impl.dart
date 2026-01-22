import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/home/models/categorie_model.dart';
import 'package:sharp_cut/domain/home/models/service_model.dart';
import 'package:sharp_cut/domain/home/service/service_repo.dart';
import 'dart:developer';
import 'package:sharp_cut/core/database/database_helper.dart';

class ServiceRepoImpl implements ServiceRepo {
  final DatabaseHelper dbHelper;

  ServiceRepoImpl({required this.dbHelper});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await ApiClient.dio.get(
        ApiClient.serviceCategoriesApi,
        queryParameters: {'is_synced': 0},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];

        // Cache
        await dbHelper.insertServiceCategories(
          data.cast<Map<String, dynamic>>(),
        );

        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      log('Error fetching categories from API, trying local DB: $e');
      try {
        final localData = await dbHelper.getServiceCategories();
        if (localData.isNotEmpty) {
          return localData.map((json) => CategoryModel.fromJson(json)).toList();
        }
        throw Exception('Failed to load categories from local DB');
      } catch (localError) {
        throw Exception(
          'Failed to load categories: $e. Local error: $localError',
        );
      }
    }
  }

  @override
  Future<List<ServiceModel>> getServices({int? categoryId}) async {
    try {
      final Map<String, dynamic> queryParameters = {'is_synced': 0};
      if (categoryId != null) {
        queryParameters['category_id'] = categoryId;
      }
      final response = await ApiClient.dio.get(
        ApiClient.servicesApi,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];

        // Cache
        await dbHelper.insertServices(data.cast<Map<String, dynamic>>());

        return data.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      log('Error fetching services from API, trying local DB: $e');
      try {
        final localData = await dbHelper.getServices(categoryId: categoryId);
        // We return local data even if empty, assuming it might be a valid empty category
        // But if we want to be strict about "sync required", we could check if any services exist at all.
        // For now, return what we have.
        return localData.map((json) => ServiceModel.fromJson(json)).toList();
      } catch (localError) {
        throw Exception(
          'Failed to load services: $e. Local error: $localError',
        );
      }
    }
  }
}
