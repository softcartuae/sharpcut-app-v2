import 'package:dio/dio.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';

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
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    final mode = await tokenStorage.getMode();
    if (mode != null) {
      options.headers['mode'] = mode;
    }

    final isChair = await tokenStorage.getIsChair();
    if (isChair != null) {
      options.headers['is-chair'] = isChair ? 1 : 0;
    }

    super.onRequest(options, handler);
  }
}
