import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/password/models/password_model.dart';
import 'package:sharp_cut/domain/password/service/password_repo.dart';
import 'package:sharp_cut/core/database/database_helper.dart';

class PasswordRepoImp extends PasswordRepo {
  @override
  Future<Either<String, String>> resetPassword({
    required PasswordModel passwordData,
    required bool isAdmin,
  }) async {
    try {
      final endpoint = isAdmin
          ? ApiClient.resetAdminPasswordapi
          : ApiClient.resetUserPasswordapi;

      final response = await ApiClient.dio.post(
        endpoint,
        data: passwordData.toMap(),
      );

      if (response.data['message'] != null || response.statusCode == 200) {
        // Update local database
        try {
          final userId = int.tryParse(passwordData.staffId);
          if (userId != null) {
            await DatabaseHelper().updateUserPassword(
              userId,
              passwordData.newPassword,
            );
          }
        } catch (e) {
          log("Failed to update local password: $e");
        }
      }

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

  @override
  Future<Either<String, String>> validatePassword({
    required String password,
    required int userId,
    required bool isAdmin,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        isAdmin
            ? ApiClient.validatePasswordAdminUser
            : ApiClient.validatePassword,
        data: {'password': password, 'user_id': userId},
      );

      return Right(
        response.data['message'] ?? "Password validated successfully",
      );
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
