class ServiceModel {
  final int? id;
  final int? categoryId;
  final String? name;
  final String? nameArabic;
  final String? description;
  final int? isTip;
  final String? charge;
  final String? beforeVat;
  final String? taxOption;
  final String? currency;
  final String? taxPercentage;
  final String? unitTax;
  final int? status;
  final String? image;
  final int? position;
  final String? createdAt;
  final String? updatedAt;

  ServiceModel({
    this.id,
    this.categoryId,
    this.name,
    this.nameArabic,
    this.description,
    this.isTip,
    this.charge,
    this.beforeVat,
    this.taxOption,
    this.currency,
    this.taxPercentage,
    this.unitTax,
    this.status,
    this.image,
    this.position,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int?,
      categoryId: json['category_id'] as int?,
      name: json['name'] as String?,
      nameArabic: json['name_arabic'] as String?,
      description: json['description'] as String?,
      isTip: json['is_tip'] as int?,
      charge: json['charge'] as String?,
      beforeVat: json['before_vat'] as String?,
      taxOption: json['tax_option'] as String?,
      currency: json['currency'] as String?,
      taxPercentage: json['tax_percentage'] as String?,
      unitTax: json['unit_tax'] as String?,
      status: json['status'] as int?,
      image: json['image'] as String?,
      position: json['position'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'name_arabic': nameArabic,
      'description': description,
      'is_tip': isTip,
      'charge': charge,
      'before_vat': beforeVat,
      'tax_option': taxOption,
      'currency': currency,
      'tax_percentage': taxPercentage,
      'unit_tax': unitTax,
      'status': status,
      'image': image,
      'position': position,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
