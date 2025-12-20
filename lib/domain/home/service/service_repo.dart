import 'package:sharp_cut/domain/home/models/service_item_model.dart';

abstract class ServiceRepo {
  Future<List<ServiceItemModel>> getServices();
}