class ShopModel {
  final int? id;
  final String? name;
  final String? description;
  final String? address;
  final String? vatNo;
  final String? mode;
  final bool? isChair;
  final bool isChargeOrServiceCanEdit;
  final bool isVatIncluded;

  ShopModel({
    this.id,
    this.name,
    this.description,
    this.address,
    this.mode,
    required this.isVatIncluded,
    this.vatNo,
    required this.isChargeOrServiceCanEdit,
    this.isChair,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {

    
    return ShopModel(
      isVatIncluded: json['is_vat'] ?? false,
      id: json['id'],
      isChargeOrServiceCanEdit: json['is_service_price_editable'] ?? false,
      name: json['name'],
      description: json['description'],
      address: json['address'],
      vatNo: json['vat_no'],
      mode: json['mode'],
      isChair: json['is_chair'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'vat_no': vatNo,
      'is_chair': isChair,
    };
  }
}
