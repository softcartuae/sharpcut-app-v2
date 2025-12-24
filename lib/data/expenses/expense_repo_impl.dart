import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/expenses/expense_repo.dart';
import 'package:sharp_cut/domain/expenses/models/expense_model.dart';

class ExpenseRepoImpl implements ExpenseRepo {
  @override
  Future<Either<String, List<ExpenseModel>>> getExpenses() async {
    try {
      final response = await ApiClient.dio.get(ApiClient.userExpenseGETapi);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final List<dynamic> expenseList = data['data'];
          final expenses = expenseList
              .map((json) => ExpenseModel.fromJson(json))
              .toList();
          return Right(expenses);
        } else {
          return Left(data['message'] ?? 'Failed to fetch expenses');
        }
      } else {
        return Left('Failed to fetch expenses: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error fetching expenses: ${e.message}');
    } catch (e) {
      return Left('Error fetching expenses: $e');
    }
  }
}
