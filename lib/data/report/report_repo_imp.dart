import 'package:dio/dio.dart';
import 'package:sharp_cut/data/report/service/report_service.dart';
import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';
import 'package:sharp_cut/domain/report/report_repo.dart';

class ReportRepoImp implements ReportRepo {
  final ReportService _reportService;

  ReportRepoImp(this._reportService);

  @override
  Future<List<BookingResponseModel>> getTransactions({
    int? userId,
    String? searchQuery,
    String? dateRange,
    String? transactionStatus,
    String? paidStatus,
  }) async {
    try {
      final response = await _reportService.getTransactions(
        userId: userId,
        searchQuery: searchQuery,
        dateRange: dateRange,
        transactionStatus: transactionStatus,
        paidStatus: paidStatus,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => BookingResponseModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to fetch transactions");
      }
    } on DioException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
