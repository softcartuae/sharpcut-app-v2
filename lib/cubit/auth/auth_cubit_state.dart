part of 'auth_cubit.dart';

abstract class AuthCubitState {}

class AuthInitial extends AuthCubitState {}

class AuthLoading extends AuthCubitState {}

class AuthAuthenticated extends AuthCubitState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

class AuthLoginSuccess extends AuthCubitState {
  final String token;
  AuthLoginSuccess(this.token);
}

class AuthError extends AuthCubitState {
  final String message;
  AuthError(this.message);
}

class AuthUnauthenticated extends AuthCubitState {}
