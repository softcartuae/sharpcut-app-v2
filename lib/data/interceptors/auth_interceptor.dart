import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';
import 'package:sharp_cut/main.dart';

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
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<AuthCubit>().logout();
      }
    }
    super.onError(err, handler);
  }
}
