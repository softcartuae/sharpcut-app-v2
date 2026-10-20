import 'package:sharp_cut/domain/auth/models/branch_model.dart';

class CheckNoChair {
  static bool checkIsThisAppNoChairOrNot(BranchModel? shop) {
    if (shop == null) return false;
    return shop.isChair == false;
  }

  static bool checkShopCanEditServiceOrCharge(BranchModel? shop) {
    if (shop == null) return false;
    return shop.isChargeOrServiceCanEdit == true;
  }

  static bool checkShowShopExpenses(BranchModel? shop) {
    if (shop == null) return false;
    return shop.isShopExpenses == true;
  }

  static bool checkShowUserExpenses(BranchModel? shop) {
    if (shop == null) return false;
    return shop.isUserExpenses == true;
  }
}
