import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/shop_expenses/shop_expense_state.dart';
import 'package:sharp_cut/domain/shop_expenses/shop_expense_repo.dart';

class BranchExpenseCubit extends Cubit<BranchExpenseState> {
  final BranchExpenseRepo shopExpenseRepo;

  BranchExpenseCubit({required this.shopExpenseRepo})
    : super(BranchExpenseInitial());

  Future<void> getShopExpensesByStaff({required int staffId}) async {
    emit(BranchExpenseLoading());
    final result = await shopExpenseRepo.getShopExpensesByStaff(
      staffId: staffId,
    );
    result.fold(
      (error) => emit(BranchExpenseError(message: error)),
      (expenses) => emit(ShopExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> submitShopExpense({
    required int staffId,
    required List<Map<String, dynamic>> items,
  }) async {
    emit(BranchExpenseSubmitting());
    final result = await shopExpenseRepo.submitShopExpense(
      staffId: staffId,
      items: items,
    );
    result.fold(
      (error) => emit(BranchExpenseError(message: error)),
      (message) => emit(BranchExpenseSubmitted(message: message)),
    );
  }

  Future<void> deleteShopExpense({
    required int id,
    required int staffId,
  }) async {
    emit(BranchExpenseDeleting());
    final result = await shopExpenseRepo.deleteShopExpense(id: id);
    result.fold((error) => emit(BranchExpenseError(message: error)), (message) {
      emit(BranchExpenseDeleted(message: message));
      getShopExpensesByStaff(staffId: staffId);
    });
  }

  Future<void> updateShopExpense({
    required int id,
    required int staffId,
    required Map<String, dynamic> data,
  }) async {
    emit(BranchExpenseUpdating());
    final result = await shopExpenseRepo.updateShopExpense(id: id, data: data);
    result.fold((error) => emit(BranchExpenseError(message: error)), (message) {
      emit(BranchExpenseUpdated(message: message));
      getShopExpensesByStaff(staffId: staffId);
    });
  }
}
