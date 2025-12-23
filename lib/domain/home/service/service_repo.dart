import 'package:sharp_cut/domain/home/models/categorie_model.dart';
import 'package:sharp_cut/domain/home/models/service_model.dart';

abstract class ServiceRepo {
  Future<List<CategoryModel>> getCategories();
  Future<List<ServiceModel>> getServices({int? categoryId});
}
