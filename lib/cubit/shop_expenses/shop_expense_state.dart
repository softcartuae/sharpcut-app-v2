import 'package:sharp_cut/domain/expenses/models/expense_model.dart';

abstract class BranchExpenseState {}

class BranchExpenseInitial extends BranchExpenseState {}

class BranchExpenseLoading extends BranchExpenseState {}

class ShopExpenseLoaded extends BranchExpenseState {
  final List<ExpenseModel> expenses;
  ShopExpenseLoaded({required this.expenses});
}

class BranchExpenseSubmitting extends BranchExpenseState {}

class BranchExpenseSubmitted extends BranchExpenseState {
  final String message;
  BranchExpenseSubmitted({required this.message});
}

class BranchExpenseError extends BranchExpenseState {
  final String message;
  BranchExpenseError({required this.message});
}

class BranchExpenseDeleting extends BranchExpenseState {}

class BranchExpenseDeleted extends BranchExpenseState {
  final String message;
  BranchExpenseDeleted({required this.message});
}

class BranchExpenseUpdating extends BranchExpenseState {}

class BranchExpenseUpdated extends BranchExpenseState {
  final String message;
  BranchExpenseUpdated({required this.message});
}
