import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:sharp_cut/data/quick_report/service/quick_report_service.dart';
import 'package:sharp_cut/domain/quick_report/models/quick_report_model.dart';
import 'package:sharp_cut/domain/quick_report/service/quick_report_repo.dart';

class QuickReportRepoImp implements QuickReportRepo {
  final QuickReportService _quickReportService;

  QuickReportRepoImp(this._quickReportService);

  @override
  Future<Either<String, QuickReportModel>> getQuickReport({
    String? dateRange,
    int? userId,
  }) async {
    try {
      final response = await _quickReportService.getQuickReport(
        dateRange: dateRange,
        userId: userId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data["data"];
        return Right(QuickReportModel.fromJson(data));
      } else {
        return Left(response.data['message']);
      }
    } catch (e) {
      log(e.toString());
      if (e is DioException) {
        if (e.response != null && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map && data.containsKey('message')) {
            return Left(data['message']);
          }
        }
        return Left(e.message ?? e.toString());
      }
      return Left(e.toString());
    }
  }
}
