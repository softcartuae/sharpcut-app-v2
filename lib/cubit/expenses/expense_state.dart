import 'package:sharp_cut/domain/expenses/models/expense_model.dart';

abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;

  ExpenseLoaded({required this.expenses});
}

class ExpenseError extends ExpenseState {
  final String message;

  ExpenseError({required this.message});
}

class ExpenseSubmitting extends ExpenseState {}

class ExpenseSubmitted extends ExpenseState {
  final String message;

  ExpenseSubmitted({required this.message});
}
