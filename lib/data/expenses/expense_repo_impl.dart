import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/expenses/expense_repo.dart';
import 'package:sharp_cut/domain/expenses/models/expense_model.dart';

class ExpenseRepoImpl implements ExpenseRepo {
  @override
  Future<Either<String, List<ExpenseModel>>> getExpensesBySpecificUser({
    required int userId,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        "${ApiClient.userExpenseGETapi}?user_id=$userId",
      );

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

  @override
  Future<Either<String, String>> submitExpense({
    required int userId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.userExpensePostApi,
        data: {"user_id": userId, "items": items},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Right(data['message'] ?? 'User Expense Saved Successfully');
        } else {
          return Left(data['message'] ?? 'Failed to save expense');
        }
      } else {
        return Left('Failed to save expense: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error saving expense: ${e.message}');
    } catch (e) {
      return Left('Error saving expense: $e');
    }
  }

  @override
  Future<Either<String, String>> deleteExpense({required int id}) async {
    try {
      final response = await ApiClient.dio.delete(
        "${ApiClient.userExpenseGETapi}/$id",
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = response.data;
        return Right(data['message'] ?? 'Expense Deleted Successfully');
      } else {
        return Left('Failed to delete expense: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error deleting expense: ${e.message}');
    } catch (e) {
      return Left('Error deleting expense: $e');
    }
  }

  @override
  Future<Either<String, String>> updateExpense({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await ApiClient.dio.put(
        "${ApiClient.userExpenseGETapi}/$id",
        data: data,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return Right(data['message'] ?? 'Expense Updated Successfully');
      } else {
        return Left('Failed to update expense: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error updating expense: ${e.message}');
    } catch (e) {
      return Left('Error updating expense: $e');
    }
  }
}
