import 'package:sharp_cut/domain/auth/models/shop_model.dart';

class CheckNoChair {
  static bool checkIsThisAppNoChairOrNot(ShopModel? shop) {
    if (shop == null) return false;
    return shop.isChair == false;
  }

    static bool checkShopCanEditServiceOrCharge(ShopModel? shop) {
    if (shop == null) return false;
    return shop.isChargeOrServiceCanEdit == true;
  }
  static bool checkShowShopExpenses(ShopModel? shop) {
    if (shop == null) return false;
    return shop.isShopExpenses == true;
  }

  static bool checkShowUserExpenses(ShopModel? shop) {
    if (shop == null) return false;
    return shop.isUserExpenses == true;
  }




}
