import 'package:dio/dio.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  AuthInterceptor(this.tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Set Accept header
    options.headers['Accept'] = 'application/json';

    // Get token and set Authorization header if available
    final token = await tokenStorage.getToken();
    final deviceId = await tokenStorage.getDeviceId();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['device-id'] = deviceId;

    final mode = await tokenStorage.getMode();
    if (mode != null) {
      options.headers['mode'] = mode;
    }

    final isChair = await tokenStorage.getIsChair();
    if (isChair != null) {
      options.headers['is_chair'] = !isChair;
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 498) {
      final data = err.response?.data;
      final message = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Session expired or invalid token';
      ToastHelper.showError(message);
    }
    super.onError(err, handler);
  }
}
