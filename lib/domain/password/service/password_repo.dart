import 'package:dartz/dartz.dart';
import 'package:sharp_cut/domain/password/models/password_model.dart';

abstract class PasswordRepo {
  Future<Either<String, String>> resetPassword({
    required PasswordModel passwordData,
    required bool isAdmin,
  });

  Future<Either<String, String>> validatePassword({
    required String password,
    required int userId,
  });


}
