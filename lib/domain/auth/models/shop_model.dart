class ShopModel {
  final int? id;
  final String? name;
  final String? description;
  final String? address;
  final String? vatNo;
  final String? mode;
  final bool? isChair;
  final num? syncTime;

  ShopModel({
    this.id,
    this.name,
    this.description,
    this.address,
    this.mode,
    this.vatNo,
    this.isChair,
    this.syncTime,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    num syncTime = (json['sync_time'] ?? 15);

    if (syncTime < 15) {
      syncTime = 15;
    }

    return ShopModel(
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
      'is_chair': isChair,
    };
  }
}
