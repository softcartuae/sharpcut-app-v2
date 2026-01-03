import 'package:dartz/dartz.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

abstract class CashRegistoryRepo {
  Future<Either<String, bool>> checkCashRegisterStatus();
  Future<Either<String, String>> openCashRegister({
    required int userId,
    required Role role,
    required double amount,
    required String password,
  });

  Future<Either<String, String>> closeCashRegister({
    required double amount,
    required int userId,
    required Role role,
    required String password,
  });
  Future<Either<String, double>> getSalesTotal();
}
