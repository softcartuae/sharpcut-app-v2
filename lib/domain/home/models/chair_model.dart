class ChairModel {
  final int? id;
  final int? shopId;
  final String? name;
  final String? description;
  final int? position;
  final int? status;
  final String? createdAt;
  final String? updatedAt;

  ChairModel({
    this.id,
    this.shopId,
    this.name,
    this.description,
    this.position,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ChairModel.fromJson(Map<String, dynamic> json) {
    return ChairModel(
      id: json['id'],
      shopId: json['shop_id'],
      name: json['name'],
      description: json['description'],
      position: json['position'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
    };
  }
}
