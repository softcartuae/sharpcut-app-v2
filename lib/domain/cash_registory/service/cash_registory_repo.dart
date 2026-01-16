import 'package:dartz/dartz.dart';
import 'package:sharp_cut/utils/helpers/enums.dart';

import 'package:sharp_cut/domain/cash_registory/models/close_register_model.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_response.dart';
import 'package:sharp_cut/domain/cash_registory/models/close_register_report_model.dart';

abstract class CashRegistoryRepo {
  Future<Either<String, bool>> checkCashRegisterStatus();
  Future<Either<String, String>> openCashRegister({
    required int userId,
    required Role role,
    required double amount,
    required String password,
  });

  Future<Either<String, CloseRegisterResponse>> closeCashRegister({
    required double amount,
    required int userId,
    required Role role,
    required String password,
    required bool isPrint,
  });
  Future<Either<String, CloseRegisterModel>> getSalesTotal();
  Future<Either<String, CloseRegisterReportModel>> getLastCloseRegisterReport();
}
