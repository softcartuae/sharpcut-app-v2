import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_state.dart';
import 'package:sharp_cut/domain/cash_registory/service/cash_registory_repo.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

class CashRegistoryCubit extends Cubit<CashRegistoryState> {
  final CashRegistoryRepo cashRegistoryRepo;

  CashRegistoryCubit({required this.cashRegistoryRepo})
    : super(CashRegistoryInitial());

  Future<bool> checkCashRegisterStatus() async {
    emit(CashRegistoryLoading());
    final result = await cashRegistoryRepo.checkCashRegisterStatus();
    return result.fold(
      (error) {
        emit(CashRegistorClosed(error));
        return false;
      },
      (isOpen) {
        if (isOpen) {
          emit(CashRegistorOpen("Register is open"));
        } else {
          // We don't necessarily need an error state here if we just want to return false,
          // but keeping the flow consistent. The UI will handle the boolean return.
          emit(CashRegistorClosed("Register is closed"));
        }
        return isOpen;
      },
    );
  }

  Future<void> openCashRegister({
    required int userId,
    required Role role,
    required double amount,
    required String password,
  }) async {
    emit(CashRegistoryLoading());
    final result = await cashRegistoryRepo.openCashRegister(
      userId: userId,
      amount: amount,
      role: role,
      password: password,
    );
    result.fold(
      (error) => emit(CashRegistoryAddError(error)),
      (message) => emit(CashRegistoryAddSuccess(message)),
    );
  }

  Future<void> closeCashRegister({
    required double amount,
    required int userId,
    required Role role,
    required String password,
  }) async {
    emit(CashRegistoryLoading());
    final result = await cashRegistoryRepo.closeCashRegister(
      amount: amount,
      userId: userId,
      role: role,
      password: password,
    );
    result.fold(
      (error) => emit(CashRegistoryAddError(error)),
      (message) => emit(CashRegistoryAddSuccess(message)),
    );
  }

  Future<void> getSalesTotal() async {
    emit(CashRegistoryLoading());
    final result = await cashRegistoryRepo.getSalesTotal();
    result.fold((error) {
     
      emit(CashRegistoryAddError(error));
    }, (total) => emit(CashRegistorySalesTotalLoaded(total)));
  }
}
