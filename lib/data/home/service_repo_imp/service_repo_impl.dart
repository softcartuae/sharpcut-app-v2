import 'package:sharp_cut/domain/home/models/service_item_model.dart';
import 'package:sharp_cut/domain/home/service/service_repo.dart';

class ServiceRepoImpl implements ServiceRepo {
  
  @override
  Future<List<ServiceItemModel>> getServices() async {
     await Future.delayed(const Duration(seconds: 2), () {});
    return [];
  }


}
