import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';

abstract class ReportRepo {
  Future<List<BookingResponseModel>> getTransactions({
    int? userId,
    String? searchQuery,
    String? dateRange,
    String? transactionStatus,
    String? paidStatus,
  });
}
