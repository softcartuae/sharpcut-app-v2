import 'package:dio/dio.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  AuthInterceptor(this.tokenStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers['Accept'] = 'application/json';

    final token = tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final mode = tokenStorage.getMode();
    if (mode != null) {
      options.headers['mode'] = mode;
    }

    final isChair = tokenStorage.getIsChair();
    if (isChair != null) {
      options.headers['is-chair'] = isChair;
    }

    final isCashier = tokenStorage.getIsCashier();
    if (isCashier != null) {
      options.headers['is-cashier'] = isCashier;
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
