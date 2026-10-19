import 'package:dartz/dartz.dart';
import 'package:sharp_cut/domain/auth/models/branchModel.dart';

abstract class AuthRepo {
  Future<Either<String, String>> login(String licenseNo);
  Future<BranchModel> getUser();
  Future<String> getAppVersion();
  Future<void> logout();
  Future<Either<String, void>> refreshDeviceToken(String deviceToken);
}
