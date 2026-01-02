import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/auth/models/shop_model.dart';
import 'package:sharp_cut/domain/auth/service/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  @override
  Future<String> login(String licenseNo) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.loginApi,
        data: {"license_no": licenseNo},
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
}
