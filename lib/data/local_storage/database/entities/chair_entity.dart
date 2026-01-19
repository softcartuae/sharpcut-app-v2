import 'package:sharp_cut/domain/home/models/chair_model.dart';

class ChairEntity {
  final int? id;
  final int? shopId;
  final String? name;
  final String? description;
  final int? position;
  final int? status;
  final String? liveStatus;
  final String? createdAt;
  final String? updatedAt;

  ChairEntity({
    this.id,
    this.shopId,
    this.name,
    this.description,
    this.position,
    this.status,
    this.liveStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory ChairEntity.fromJson(Map<String, dynamic> json) {
    return ChairEntity(
      id: json['id'] as int?,
      shopId: json['shop_id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      position: json['position'] as int?,
      status: json['status'] as int?,
      liveStatus: json['live_status'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
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
      'live_status': liveStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory ChairEntity.fromModel(ChairModel model) {
    return ChairEntity(
      id: model.id,
      shopId: model.shopId,
      name: model.name,
      description: model.description,
      position: model.position,
      status: model.status,
      liveStatus: model.liveState,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  ChairModel toModel() {
    return ChairModel(
      id: id,
      shopId: shopId,
      name: name,
      description: description,
      position: position,
      status: status,
      liveState: liveStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
