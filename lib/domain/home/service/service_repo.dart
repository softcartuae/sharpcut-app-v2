import 'package:sharp_cut/domain/home/models/service_model.dart';

abstract class ServiceRepo {
  Future<List<ServiceModel>> getServices();




}
