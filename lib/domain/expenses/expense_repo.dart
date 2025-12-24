import 'package:dartz/dartz.dart';
import 'package:sharp_cut/domain/expenses/models/expense_model.dart';

abstract class ExpenseRepo {
  Future<Either<String, List<ExpenseModel>>> getExpenses();
}
