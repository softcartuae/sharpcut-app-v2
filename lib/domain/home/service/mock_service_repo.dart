import 'package:sharp_cut/domain/home/models/service_item_model.dart';
import 'package:sharp_cut/domain/home/service/service_repo.dart';

class MockServiceRepo implements ServiceRepo {
  @override
  Future<List<ServiceItemModel>> getServices() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return [
      ServiceItemModel(
        id: 1,
        name: 'Haircut',
        price: 25.0,
        image: 'assets/images/haircut.png', // Placeholder image path
      ),
      ServiceItemModel(
        id: 2,
        name: 'Shave',
        price: 15.0,
        image: 'assets/images/shave.png', // Placeholder image path
      ),
      ServiceItemModel(
        id: 3,
        name: 'Massage',
        price: 50.0,
        image: 'assets/images/massage.png', // Placeholder image path
      ),
       ServiceItemModel(
        id: 4,
        name: 'Facial',
        price: 35.0,
        image: 'assets/images/facial.png', // Placeholder image path
      ),
    ];
  }
}
