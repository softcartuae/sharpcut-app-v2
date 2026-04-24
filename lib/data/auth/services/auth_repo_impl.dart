import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sharp_cut/core/database/database_helper.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/auth/service/auth_repo.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

class AuthRepoImpl implements AuthRepo {
  final TokenStorage tokenStorage;

  AuthRepoImpl({required this.tokenStorage});
  @override
  Future<Either<String, String>> login(String pin) async {
    try {
      String? token;

      try {
        if (Platform.isAndroid || Platform.isIOS) {
          token = await FirebaseMessaging.instance.getToken();
        }
      } catch (e) {
        log(e.toString());
      }

      String deviceId = await tokenStorage.getDeviceId();
      String deviceOs = 'unknown';
      if (Platform.isAndroid) {
        deviceOs = 'android';
      } else if (Platform.isIOS) {
        deviceOs = 'ios';
      } else if (Platform.isWindows) {
        deviceOs = 'windows';
      } else if (Platform.isLinux) {
        deviceOs = "windows";
      }

      final response = await ApiClient.dio.post(
        ApiClient.loginApi,
        data: {
          "mode": "offline",
          "pin": pin,
          "device_token": token,
          "device_id": deviceId,
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
      if (e is DioException) {
        if (e.response != null && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map && data.containsKey('message')) {
            return Left(data['message']);
          }
        }

        //  SSL Handshake error (date/time issue)
        if (e.error is HandshakeException) {
          return Left(
            "Secure connection failed. Please check your phone date and time settings.",
          );
        }

        switch (e.type) {
          case DioExceptionType.badCertificate:
            return Left(
              "Secure connection failed. Please check your phone date and time.",
            );

          case DioExceptionType.connectionError:
            if (e.error is HandshakeException) {
              return Left(
                "Secure connection failed. Please check your phone date and time.",
              );
            }
            return Left("Connection Error");

          case DioExceptionType.connectionTimeout:
            return Left("Unable to connect to server.");

          default:
            return Left("Something went wrong.");
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
        final shopModel = ShopModel.fromJson(response.data);
        // Cache the user for offline access
        await tokenStorage.saveShopModel(jsonEncode(shopModel.toJson()));
        return shopModel;
      } else {
        throw Exception("Failed to get user: ${response.statusMessage}");
      }
    } catch (e) {
      log("Get user error (attempting offline fallback): $e");
      // Fallback to cached user
      final cachedUserStr = await tokenStorage.getShopModel();
      if (cachedUserStr != null) {
        final Map<String, dynamic> cachedUserJson = jsonDecode(cachedUserStr);
        return ShopModel.fromJson(cachedUserJson);
      }
      throw Exception("Get user error and no cached user found: $e");
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
  Future<void> getInvoiceSettings() async {
    try {
      final response = await ApiClient.dio.get(ApiClient.invoiceSettingsApi);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final settings = response.data['data'];
        if (settings != null) {
          await DatabaseHelper().saveInvoiceSettings(settings);
        } else {
          ToastHelper.showError(
            "Invoice settings not found, You Have to add it in Dashboard then restart the App",
          );
        }
      }
    } catch (e) {
      log("Failed to fetch invoice settings: $e");
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
