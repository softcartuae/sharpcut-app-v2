import 'package:dartz/dartz.dart';
import 'package:sharp_cut/domain/expenses/models/expense_model.dart';

abstract class ShopExpenseRepo {
  Future<Either<String, List<ExpenseModel>>> getShopExpensesByStaff({
    required int staffId,
  });
  Future<Either<String, String>> submitShopExpense({
    required int staffId,
    required List<Map<String, dynamic>> items,
  });
  Future<Either<String, String>> deleteShopExpense({required int id});
  Future<Either<String, String>> updateShopExpense({
    required int id,
    required Map<String, dynamic> data,
  });
}
