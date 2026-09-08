import 'package:sharp_cut/utils/helpers/convertion.dart';

class PaymentModel {
  final int? id;
  final String? mode;
  final double? amount;
  final String? date;

  PaymentModel({this.id, this.mode, this.amount, this.date});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      mode: json['mode'],
      amount: toDouble(json['amount']),
      date: json['date'],
    );
  }
}
