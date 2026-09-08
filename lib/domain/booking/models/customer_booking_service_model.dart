import 'package:sharp_cut/utils/helpers/convertion.dart';

class CustomerBookingService {
  final int? id;
  final int? customerBookingId;
  final int? serviceId;
  final String? name;
  final int? quantity;
  final double? rate;
  final double? beforeVat;
  final double? taxPercentage;
  final double? unitTax;
  final String? createdAt;
  final String? updatedAt;

  CustomerBookingService({
    this.id,
    this.customerBookingId,
    this.serviceId,
    this.name,
    this.taxPercentage,
    this.unitTax,
    this.beforeVat,
    this.quantity,
    this.rate,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerBookingService.fromJson(Map<String, dynamic> json) {
    return CustomerBookingService(
      id: json['id'],
      customerBookingId: json['customer_booking_id'],
      serviceId: json['service_id'],
      name: json['name'],
      quantity: json['quantity'],
      beforeVat: toDouble(json['before_vat']),
      taxPercentage: toDouble(json['tax_percentage']),
      unitTax: toDouble(json['unit_tax']),
      rate: toDouble(json['rate']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
