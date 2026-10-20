class BranchModel {
  final int? id;
  final String? name;
  final String? description;
  final String? address;
  final String? vatNo;
  final String? mode;
  final bool? isChair;
  final bool isChargeOrServiceCanEdit;
  final bool isVatIncluded;
  final bool isShopExpenses;
  final bool isUserExpenses;

  BranchModel({
    this.id,
    this.name,
    this.description,
    this.address,
    this.mode,
    required this.isVatIncluded,
    this.vatNo,
    required this.isChargeOrServiceCanEdit,
    this.isChair,
    this.isShopExpenses = false,
    this.isUserExpenses = false,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      isVatIncluded: json['is_vat'] ?? false,
      id: json['id'],
      isChargeOrServiceCanEdit: json['is_service_price_editable'] ?? false,
      name: json['name'],
      description: json['description'],
      address: json['address'],
      vatNo: json['vat_no'],
      mode: json['mode'],
      isChair: json['is_chair'],
      isShopExpenses: json['is_branch_expenses'] ?? false,
      isUserExpenses: json['is_user_expenses'] ?? false,
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
      'is_branch_expenses': isShopExpenses,
      'is_user_expenses': isUserExpenses,
    };
  }
}
