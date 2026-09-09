import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';

class ReportPaginatedResponse {
  final List<BookingResponseModel> transactions;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  ReportPaginatedResponse({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ReportPaginatedResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<BookingResponseModel> list = [];
    if (rawData is List) {
      list = rawData.map((e) => BookingResponseModel.fromJson(e)).toList();
    }

    return ReportPaginatedResponse(
      transactions: list,
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.tryParse(json['current_page']?.toString() ?? '1') ?? 1,
      lastPage: json['last_page'] is int
          ? json['last_page']
          : int.tryParse(json['last_page']?.toString() ?? '1') ?? 1,
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page']?.toString() ?? '15') ?? 15,
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? '0') ?? list.length,
    );
  }
}
