import 'package:sharp_cut/utils/helpers/convertion.dart';

class ServiceModel {
  final int? id;
  final int? categoryId;
  final String? name;
  final String? nameArabic;
  final String? description;
  final int? isTip;
  final double? charge;
  final double? beforeVat;
  final String? taxOption;
  final String? currency;
  final double? taxPercentage;
  final double? unitTax;
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
      charge: toDouble(json['charge']),
      beforeVat: toDouble(json['before_vat']),
      taxOption: json['tax_option'] as String?,
      currency: json['currency'] as String?,
      taxPercentage: toDouble(json['tax_percentage']),
      unitTax: toDouble(json['unit_tax']),
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

  double? get price => charge;

  ServiceModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? nameArabic,
    String? description,
    int? isTip,
    double? charge,
    double? beforeVat,
    String? taxOption,
    String? currency,
    double? taxPercentage,
    double? unitTax,
    int? status,
    String? image,
    int? position,
    String? createdAt,
    String? updatedAt,
    bool? tipAmount,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      description: description ?? this.description,
      isTip: isTip ?? this.isTip,
      charge: charge ?? this.charge,
      beforeVat: beforeVat ?? this.beforeVat,
      taxOption: taxOption ?? this.taxOption,
      currency: currency ?? this.currency,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      unitTax: unitTax ?? this.unitTax,
      status: status ?? this.status,
      image: image ?? this.image,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
