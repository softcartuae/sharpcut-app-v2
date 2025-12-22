import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/password/models/password_model.dart';
import 'package:sharp_cut/domain/password/service/password_repo.dart';

class PasswordRepoImp extends PasswordRepo {
  @override
  Future<Either<String, String>> resetAdminPassword({
    required PasswordModel passwordData,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.resetAdminPasswordapi,
        data: passwordData.toMap(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(response.data['message'] ?? "Password reset successful");
      } else {
        return Left(response.data['message'] ?? "Failed to reset password");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> resetUserPassword({
    required PasswordModel passwordData,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.resetUserPasswordapi,
        data: passwordData.toMap(),
      );

      return Right(response.data['message'] ?? "Password reset successful");
    } on DioException catch (e) {
      if (e.response != null) {
        // API responded with 400 / 401 / 500 etc
        return Left(e.response?.data['message'] ?? "Something went wrong");
      } else {
        // No response (timeout, no internet)
        return Left("Network error. Please try again.");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
