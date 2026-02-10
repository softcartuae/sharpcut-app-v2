import 'package:sharp_cut/domain/auth/models/shop_model.dart';

class CheckNoChair {
  static bool checkIsThisAppNoChairOrNot(ShopModel? shop) {
    if (shop == null) return false;
    return shop.isChair == true;
  }
}

