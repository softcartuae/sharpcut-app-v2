class CategoryModel {
  final int? id;
  final int? shopId;
  final String? name;
  final String? description;
  final int? status;
  final String? createdAt;
  final String? updatedAt;

  CategoryModel({
    this.id,
    this.shopId,
    this.name,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      shopId: json['shop_id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: json['status'] as int?,
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
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
