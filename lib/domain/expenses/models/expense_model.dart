class ExpenseModel {
  final int? id;
  final String? appId;
  final int? userId;
  final String? itemName;
  final String? price;
  final String? purchaseDate;
  final String? createdAt;
  final String? updatedAt;

  ExpenseModel({
    this.id,
    this.appId,
    this.userId,
    this.itemName,
    this.price,
    this.purchaseDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      appId: json['app_id'],
      userId: json['user_id'],
      itemName: json['item_name'],
      price: json['price'],
      purchaseDate: json['purchase_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'user_id': userId,
      'item_name': itemName,
      'price': price,
      'purchase_date': purchaseDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Map<String, dynamic> toAddExpenseJson() {
    return {
      'item_name': itemName,
      'price': double.tryParse(price ?? '0') ?? 0.0,
      'purchase_date': purchaseDate,
    };
  }
}
