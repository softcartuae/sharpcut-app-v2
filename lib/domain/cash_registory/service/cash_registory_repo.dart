import 'package:dartz/dartz.dart';

abstract class CashRegistoryRepo {
  Future<Either<String, bool>> checkCashRegisterStatus();
  Future<Either<String, String>> openCashRegister({
    required int userId,
    required double amount,
  });

  Future<Either<String, String>> closeCashRegister({required double amount});
}
