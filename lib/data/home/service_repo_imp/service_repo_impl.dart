import 'package:sharp_cut/domain/home/models/service_item_model.dart';
import 'package:sharp_cut/domain/home/service/service_repo.dart';

class ServiceRepoImpl implements ServiceRepo {
  final dummyServices = [
    ServiceItemModel(
      id: 1,
      name: "Hair Cutting",
      price: 100,
      image: "lib/utils/images/hair_cut.png",
    ),
    ServiceItemModel(
      id: 2,
      name: "Shaving",
      price: 50,
      image: "lib/utils/images/shaving.png",
    ),
    ServiceItemModel(
      id: 3,
      name: "Facial",
      price: 75,
      image: "lib/utils/images/facial.png",
    ),
    ServiceItemModel(
      id: 4,
      name: "Hair Cutting",
      price: 100,
      image: "lib/utils/images/hair_cut.png",
    ),
    ServiceItemModel(
      id: 5,
      name: "Shaving",
      price: 50,
      image: "lib/utils/images/shaving.png",
    ),
    ServiceItemModel(
      id: 6,
      name: "Facial",
      price: 75,
      image: "lib/utils/images/facial.png",
    ),
    ServiceItemModel(
      id: 7,
      name: "Hair Cutting",
      price: 100,
      image: "lib/utils/images/hair_cut.png",
    ),
    ServiceItemModel(
      id: 8,
      name: "Shaving",
      price: 50,
      image: "lib/utils/images/shaving.png",
    ),
    ServiceItemModel(
      id: 9,
      name: "Facial",
      price: 75,
      image: "lib/utils/images/facial.png",
    ),
    ServiceItemModel(
      id: 10,
      name: "Hair Cutting",
      price: 100,
      image: "lib/utils/images/hair_cut.png",
    ),
    ServiceItemModel(
      id: 11,
      name: "Shaving",
      price: 50,
      image: "lib/utils/images/shaving.png",
    ),
    ServiceItemModel(
      id: 12,
      name: "Facial",
      price: 75,
      image: "lib/utils/images/facial.png",
    ),
  ];
  
  @override
  Future<List<ServiceItemModel>> getServices() async {
     await Future.delayed(const Duration(seconds: 2), () {});
    return dummyServices;
  }


}
