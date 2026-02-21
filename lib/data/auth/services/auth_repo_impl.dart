import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/auth/service/auth_repo.dart';

import 'package:sharp_cut/data/local_storage/token_storage.dart';

class AuthRepoImpl implements AuthRepo {
  final TokenStorage tokenStorage;

  AuthRepoImpl({required this.tokenStorage});
  @override
  Future<Either<String, String>> login(String licenseNo) async {
    try {
      String? token;

      try {
        if (Platform.isAndroid || Platform.isIOS) {
          token = await FirebaseMessaging.instance.getToken();
        }
      } catch (e) {
        log(e.toString());
      }

      String deviceOs = 'unknown';
      if (Platform.isAndroid) {
        deviceOs = 'android';
      } else if (Platform.isIOS) {
        deviceOs = 'ios';
      } else if (Platform.isWindows) {
        deviceOs = 'windows';
      }

      final response = await ApiClient.dio.post(
        ApiClient.loginApi,
        data: {
          "mode": "online",
          "license_no": licenseNo,
          "device_token": token,
          "device_os": deviceOs,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return Right(data['token']);
      } else {
        return Left("Login failed: ${response.statusMessage}");
      }
    } catch (e) {
      log(e.toString());
      if (e is DioException) {
        if (e.response != null && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map && data.containsKey('message')) {
            return Left(data['message']);
          }
        }
      }
      return Left("Login error: ${e.toString()}");
    }
  }

  @override
  Future<ShopModel> getUser() async {
    try {
      final response = await ApiClient.dio.get(ApiClient.authentcatedUserApi);

      if (response.statusCode == 200) {
        return ShopModel.fromJson(response.data);
      } else {
        throw Exception("Failed to get user: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Get user error: $e");
    }
  }

  @override
  Future<void> logout() async {
    try {
      await ApiClient.dio.post(ApiClient.logoutApi);
    } catch (e) {
      log("Logout API failed: $e");
    } finally {
      await tokenStorage.deleteToken();
    }
  }

  @override
  Future<String> getAppVersion() async {
    try {
      final response = await ApiClient.dio.get(ApiClient.versionApi);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('api_version')) {
          return data['api_version'].toString();
        }
      }
      return "";
    } catch (e) {
      log("Get app version error: $e");
      return "";
    }
  }
}
