import 'package:sharp_cut/domain/expenses/models/expense_model.dart';

abstract class ShopExpenseState {}

class ShopExpenseInitial extends ShopExpenseState {}

class ShopExpenseLoading extends ShopExpenseState {}

class ShopExpenseLoaded extends ShopExpenseState {
  final List<ExpenseModel> expenses;
  ShopExpenseLoaded({required this.expenses});
}

class ShopExpenseSubmitting extends ShopExpenseState {}

class ShopExpenseSubmitted extends ShopExpenseState {
  final String message;
  ShopExpenseSubmitted({required this.message});
}

class ShopExpenseError extends ShopExpenseState {
  final String message;
  ShopExpenseError({required this.message});
}

class ShopExpenseDeleting extends ShopExpenseState {}

class ShopExpenseDeleted extends ShopExpenseState {
  final String message;
  ShopExpenseDeleted({required this.message});
}

class ShopExpenseUpdating extends ShopExpenseState {}

class ShopExpenseUpdated extends ShopExpenseState {
  final String message;
  ShopExpenseUpdated({required this.message});
}
