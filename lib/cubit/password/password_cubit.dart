import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sharp_cut/domain/password/models/password_model.dart';
import 'package:sharp_cut/domain/password/service/password_repo.dart';

part 'password_state.dart';

class PasswordCubit extends Cubit<PasswordState> {
  final PasswordRepo passwordRepo;

  PasswordCubit({required this.passwordRepo}) : super(PasswordInitial());

  Future<void> resetPassword(
    PasswordModel passwordData, {
    bool isAdmin = false,
  }) async {
    emit(PasswordLoading());
    final result = await passwordRepo.resetPassword(
      passwordData: passwordData,
      isAdmin: isAdmin,
    );
    result.fold(
      (failure) => emit(PasswordFailure(failure)),
      (success) => emit(PasswordSuccess(success)),
    );
  }
}
