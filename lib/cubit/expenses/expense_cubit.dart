import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/expenses/expense_state.dart';
import 'package:sharp_cut/domain/expenses/expense_repo.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepo expenseRepo;

  ExpenseCubit({required this.expenseRepo}) : super(ExpenseInitial());

  Future<void> getExpensesBySpecificUser({required int userId}) async {
    emit(ExpenseLoading());
    final result = await expenseRepo.getExpensesBySpecificUser(userId: userId);
    result.fold(
      (error) => emit(ExpenseError(message: error)),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> submitExpense({
    required int userId,
    required List<Map<String, dynamic>> items,
  }) async {
    emit(ExpenseSubmitting());
    final result = await expenseRepo.submitExpense(
      userId: userId,
      items: items,
    );
    result.fold(
      (error) => emit(ExpenseError(message: error)),
      (message) => emit(ExpenseSubmitted(message: message)),
    );
  }

  Future<void> deleteExpense({required int id, required int userId}) async {
    emit(ExpenseDeleting());
    final result = await expenseRepo.deleteExpense(id: id);
    result.fold((error) => emit(ExpenseError(message: error)), (message) {
      emit(ExpenseDeleted(message: message));
      getExpensesBySpecificUser(userId: userId);
    });
  }

  Future<void> updateExpense({
    required int id,
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    emit(ExpenseUpdating());
    final result = await expenseRepo.updateExpense(id: id, data: data);
    result.fold((error) => emit(ExpenseError(message: error)), (message) {
      emit(ExpenseUpdated(message: message));
      getExpensesBySpecificUser(userId: userId);
    });
  }
}
