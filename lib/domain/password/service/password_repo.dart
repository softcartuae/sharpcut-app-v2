import 'package:dartz/dartz.dart';
import 'package:sharp_cut/domain/password/models/password_model.dart';

abstract class PasswordRepo {
  Future<Either<String, String>> resetUserPassword({
    required PasswordModel passwordData,
  });
  Future<Either<String, String>> resetAdminPassword({
    required PasswordModel passwordData,
  });
}
