import 'package:sharp_cut/domain/home/models/service_model.dart';
import 'package:sharp_cut/utils/helpers/convertion.dart';

class BookingDetail {
  final int? id;
  final ServiceModel? service;
  final int? quantity;
  final double? rate;
  final double? amountTotal;

  BookingDetail({
    this.id,
    this.service,
    this.quantity,
    this.rate,
    this.amountTotal,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      id: json['id'],
      quantity: json['quantity'],
      rate: toDouble(json['rate']),
      amountTotal: toDouble(json['amount_total']),
      service: json['service'] != null
          ? ServiceModel.fromJson(json['service'])
          : null,
    );
  }
}
