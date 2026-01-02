import 'package:sharp_cut/domain/booking/models/booking_response_model.dart';

class ChairModel {
  final int? id;
  final int? shopId;
  final String? name;
  final String? description;
  final int? position;
  final int? status;
  final String? createdAt;
  final String? updatedAt;
  final String? liveState;
  final BookingResponseModel? transaction;

  ChairModel({
    this.id,
    this.shopId,
    this.name,
    this.description,
    this.position,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.liveState,
    this.transaction,
  });

  factory ChairModel.fromJson(Map<String, dynamic> json) {
    return ChairModel(
      id: json['id'],
      liveState: json["live_status"],
      shopId: json['shop_id'],
      name: json['name'],
      description: json['description'],
      position: json['position'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      transaction: json['transaction'] != null
          ? BookingResponseModel.fromJson(json['transaction'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'description': description,
      'position': position,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'transaction':
          transaction, // Note: BookingResponseModel needs toJson if we want full serialization, but for now this is enough for the requirement.
    };
  }
}
