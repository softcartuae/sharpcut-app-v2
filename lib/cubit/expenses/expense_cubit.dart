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
}
