import 'package:dartz/dartz.dart';
import 'package:sharp_cut/domain/expenses/models/expense_model.dart';

abstract class ExpenseRepo {
  Future<Either<String, List<ExpenseModel>>> getExpensesBySpecificUser({
    required int userId,
  });
  Future<Either<String, List<ExpenseModel>>> getExpenses();
  Future<Either<String, String>> submitExpense({
    required int userId,
    required List<Map<String, dynamic>> items,
  });
  Future<Either<String, String>> deleteExpense({required int id});
  Future<Either<String, String>> updateExpense({
    required int id,
    required Map<String, dynamic> data,
  });
}
