import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/shop_expenses/shop_expense_repo.dart';
import 'package:sharp_cut/domain/expenses/models/expense_model.dart';

class ShopExpenseRepoImpl implements ShopExpenseRepo {
  @override
  Future<Either<String, List<ExpenseModel>>> getShopExpensesByStaff({
    required int staffId,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        "${ApiClient.shopExpenseGETapi}?user_id=$staffId",
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
          return Left(data['message'] ?? 'Failed to fetch shop expenses');
        }
      } else {
        return Left('Failed to fetch shop expenses: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error fetching shop expenses: ${e.message}');
    } catch (e) {
      return Left('Error fetching shop expenses: $e');
    }
  }

  @override
  Future<Either<String, String>> submitShopExpense({
    required int staffId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.shopExpensePostApi,
        data: {"user_id": staffId, "items": items},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Right(data['message'] ?? 'Shop Expense Saved Successfully');
        } else {
          return Left(data['message'] ?? 'Failed to save shop expense');
        }
      } else {
        return Left('Failed to save shop expense: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error saving shop expense: ${e.message}');
    } catch (e) {
      return Left('Error saving shop expense: $e');
    }
  }

  @override
  Future<Either<String, String>> deleteShopExpense({required int id}) async {
    try {
      final response = await ApiClient.dio.delete(
        "${ApiClient.shopExpenseGETapi}/$id",
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final data = response.data;
        return Right(data['message'] ?? 'Shop Expense Deleted Successfully');
      } else {
        return Left('Failed to delete shop expense: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error deleting shop expense: ${e.message}');
    } catch (e) {
      return Left('Error deleting shop expense: $e');
    }
  }

  @override
  Future<Either<String, String>> updateShopExpense({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await ApiClient.dio.put(
        "${ApiClient.shopExpenseGETapi}/$id",
        data: data,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return Right(data['message'] ?? 'Shop Expense Updated Successfully');
      } else {
        return Left('Failed to update shop expense: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error updating shop expense: ${e.message}');
    } catch (e) {
      return Left('Error updating shop expense: $e');
    }
  }
}
