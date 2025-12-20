import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/auth/models/user_model.dart';
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
      throw Exception("Login error: $e");
    }
  }

  @override
  Future<UserModel> getUser() async {
    try {
      // Note: Token should be set in Dio headers before calling this,
      // or passed here if we were managing it differently.
      // For now, assuming the interceptor or global header is set elsewhere
      // or we need to set it.
      // Since the user didn't specify where the token is stored,
      // I will assume for now we might need to add it to the headers dynamically
      // if I had a way to get it.
      // However, typically the AuthCubit will hold the token and we might need
      // to pass it or configure Dio.
      // Let's assume for this step that the token is handled or we will handle it in Cubit
      // by setting ApiClient.dio.options.headers["Authorization"] = "Bearer $token";

      final response = await ApiClient.dio.get(ApiClient.authentcatedUserApi);

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception("Failed to get user: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Get user error: $e");
    }
  }
}
