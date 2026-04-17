import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/shop_expenses/shop_expense_state.dart';
import 'package:sharp_cut/domain/shop_expenses/shop_expense_repo.dart';

class ShopExpenseCubit extends Cubit<ShopExpenseState> {
  final ShopExpenseRepo shopExpenseRepo;

  ShopExpenseCubit({required this.shopExpenseRepo})
    : super(ShopExpenseInitial());

  Future<void> getShopExpensesByStaff({required int staffId}) async {
    emit(ShopExpenseLoading());
    final result = await shopExpenseRepo.getShopExpensesByStaff(
      staffId: staffId,
    );
    result.fold(
      (error) => emit(ShopExpenseError(message: error)),
      (expenses) => emit(ShopExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> submitShopExpense({
    required int staffId,
    required List<Map<String, dynamic>> items,
  }) async {
    emit(ShopExpenseSubmitting());
    final result = await shopExpenseRepo.submitShopExpense(
      staffId: staffId,
      items: items,
    );
    result.fold(
      (error) => emit(ShopExpenseError(message: error)),
      (message) => emit(ShopExpenseSubmitted(message: message)),
    );
  }

  Future<void> deleteShopExpense({
    required int id,
    required int staffId,
  }) async {
    emit(ShopExpenseDeleting());
    final result = await shopExpenseRepo.deleteShopExpense(id: id);
    result.fold((error) => emit(ShopExpenseError(message: error)), (message) {
      emit(ShopExpenseDeleted(message: message));
      getShopExpensesByStaff(staffId: staffId);
    });
  }

  Future<void> updateShopExpense({
    required int id,
    required int staffId,
    required Map<String, dynamic> data,
  }) async {
    emit(ShopExpenseUpdating());
    final result = await shopExpenseRepo.updateShopExpense(id: id, data: data);
    result.fold((error) => emit(ShopExpenseError(message: error)), (message) {
      emit(ShopExpenseUpdated(message: message));
      getShopExpensesByStaff(staffId: staffId);
    });
  }
}
