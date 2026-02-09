class ShopModel {
  final int? id;
  final String? name;
  final String? description;
  final String? address;
  final String? vatNo;
  final String? mode;
  final bool? isChair;

  ShopModel({
    this.id,
    this.name,
    this.description,
    this.address,
    this.mode,
    this.vatNo,
    this.isChair,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'],
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
