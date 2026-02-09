import 'package:dartz/dartz.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';

abstract class AuthRepo {
  Future<Either<String, String>> login(String licenseNo);
  Future<ShopModel> getUser();
  Future<String> getAppVersion();
  Future<void> logout();
}
