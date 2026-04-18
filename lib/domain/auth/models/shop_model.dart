class ShopModel {
  final int? id;
  final String? name;
  final String? description;
  final String? address;
  final String? vatNo;
  final String? mode;
  final bool? isChair;
  final num? syncTime;
  final bool isChargeOrServiceCanEdit;
  final bool isVatIncluded;
   final bool isShopExpenses;
  final bool isUserExpenses;



  ShopModel({
    this.id,
    this.name,
    this.description,
    this.address,
    this.mode,
    this.vatNo,
    this.isChair,
    this.syncTime,
    required this.isVatIncluded,
       this.isShopExpenses = false,
    this.isUserExpenses = false,

    required this.isChargeOrServiceCanEdit,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    num syncTime = (json['sync_time'] ?? 15);

    if (syncTime < 15) {
      syncTime = 15;
    }

    return ShopModel(
      isVatIncluded: json['is_vat'] ?? false,
       isShopExpenses: json['is_shop_expenses'] ?? false,
      isUserExpenses: json['is_user_expenses'] ?? false,

      isChargeOrServiceCanEdit: json['is_service_price_editable'] ?? false,
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      vatNo: json['vat_no'],
      mode: json['mode'],
      isChair: json['is_chair'],
      syncTime: syncTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'vat_no': vatNo,
      'mode': mode,
      'is_chair': isChair,
      'sync_time': syncTime,
          'is_shop_expenses': isShopExpenses,
      'is_user_expenses': isUserExpenses,
    };
  }
}
