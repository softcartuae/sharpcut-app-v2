import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sharp_cut/data/local_storage/token_storage.dart';
import 'package:sharp_cut/domain/auth/models/user_model.dart';
import 'package:sharp_cut/domain/auth/service/auth_repo.dart';

part 'auth_cubit_state.dart';

class AuthCubit extends Cubit<AuthCubitState> {
  final AuthRepo authRepo;
  final TokenStorage tokenStorage;

  UserModel? currentUser;

  AuthCubit({required this.authRepo, required this.tokenStorage})
    : super(AuthInitial());

  Future<void> login(String licenseNo) async {
    emit(AuthLoading());
    try {
      final token = await authRepo.login(licenseNo);
      await tokenStorage.saveToken(token);
      emit(AuthLoginSuccess(token));
      // Fetch user immediately after login
      await getUser();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> getUser() async {
    // If we are already loading (from login), don't emit loading again if you want to keep the flow smooth,
    // but typically it's fine. However, if called separately, we need loading.
    if (state is! AuthLoading) {
      emit(AuthLoading());
    }

    try {
      final user = await authRepo.getUser();
      currentUser = user;
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await tokenStorage.getToken();
      if (token != null) {
        await getUser();
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await tokenStorage.deleteToken();
    currentUser = null;
    emit(AuthUnauthenticated());
  }
}
