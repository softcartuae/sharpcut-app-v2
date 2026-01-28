import 'package:sharp_cut/domain/auth/models/shop_model.dart';

abstract class AuthRepo {
  Future<String> login(String licenseNo);
  Future<ShopModel> getUser();
  Future<void> logout();
  Future<void> getInvoiceSettings();
}
