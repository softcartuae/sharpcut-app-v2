import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/domain/cash_registory/service/cash_registory_repo.dart';

class CashRegistoryRepoImp implements CashRegistoryRepo {
  @override
  Future<Either<String, bool>> checkCashRegisterStatus() async {
    try {
      final response = await ApiClient.dio.get(ApiClient.cashRegisterCheckApi);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['status'] == 'open') {
          return const Right(true);
        } else if (data['success'] == true && data['status'] == 'closed') {
          return const Right(false);
        } else {
          return Left('Failed to check register status');
        }
      } else {
        return Left('Failed to check register status');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error checking register status: ${e.message}');
    } catch (e) {
      return Left('Error checking register status: $e');
    }
  }

  @override
  Future<Either<String, String>> openCashRegister({
    required int userId,
    required double amount,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.openCashRegisterApi,
        data: {"user_id": userId, "opening_amount": amount},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Right(data['message'] ?? 'Cash register opened successfully.');
        } else {
          return Left(data['message'] ?? 'Failed to open cash register.');
        }
      } else {
        return Left('Failed to open cash register: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(data['message']);
        }
      }
      return Left('Error opening cash register: ${e.message}');
    } catch (e) {
      return Left('Error opening cash register: $e');
    }
  }

  @override
  Future<Either<String, String>> closeCashRegister({
    required double amount,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiClient.closeCashRegisterApi,
        data: {"closing_amount": amount},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return Right(data['message'] ?? 'Cash register closed successfully.');
        } else {
          return Left(data['message'] ?? 'Failed to close cash register.');
        }
      } else {
        return Left('Failed to close cash register: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(
          e.response?.data['message'] ??
              'Failed to close cash register: ${e.message}',
        );
      } else {
        return Left('Failed to close cash register: ${e.message}');
      }
    } catch (e) {
      return Left('An unexpected error occurred: $e');
    }
  }
}
