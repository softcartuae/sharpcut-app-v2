import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/auth/service/auth_repo.dart';

import 'package:sharp_cut/data/local_storage/token_storage.dart';
import 'package:sharp_cut/core/database/database_helper.dart';

class AuthRepoImpl implements AuthRepo {
  final TokenStorage tokenStorage;

  AuthRepoImpl({required this.tokenStorage});
  @override
  Future<String> login(String licenseNo) async {
    try {
      String? token;

      // try {
      //   token = await FirebaseMessaging.instance.getToken();
      // } catch (e) {
      //   log(e.toString());
      // }

      final response = await ApiClient.dio.post(
        ApiClient.loginApi,
        data: {"license_no": licenseNo, "device_token": token},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['token'];
      } else {
        throw Exception("Login failed: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Login error: SOMETHING WENT WRONG");
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
  Future<void> getInvoiceSettings() async {
    try {
      final response = await ApiClient.dio.get(ApiClient.invoiceSettingsApi);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final settings = response.data['data'];
        await DatabaseHelper().saveInvoiceSettings(settings);
      }
    } catch (e) {
      log("Failed to fetch invoice settings: $e");
    }
  }
}

