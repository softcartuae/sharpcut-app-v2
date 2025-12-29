import 'package:sharp_cut/domain/auth/models/user_model.dart';

abstract class AuthRepo {
  Future<String> login(String licenseNo);
  Future<ShopModel> getUser();
}
