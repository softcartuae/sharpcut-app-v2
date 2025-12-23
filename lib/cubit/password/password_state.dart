part of 'password_cubit.dart';

abstract class PasswordState extends Equatable {
  const PasswordState();

  @override
  List<Object> get props => [];
}

class PasswordInitial extends PasswordState {}

class PasswordLoading extends PasswordState {}

class PasswordSuccess extends PasswordState {
  final String message;

  const PasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordFailure extends PasswordState {
  final String error;

  const PasswordFailure(this.error);

  @override
  List<Object> get props => [error];
}

class PasswordValidationLoading extends PasswordState {}

class PasswordValidationSuccess extends PasswordState {
  final String message;

  const PasswordValidationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordValidationFailure extends PasswordState {
  final String error;

  const PasswordValidationFailure(this.error);

  @override
  List<Object> get props => [error];
}
