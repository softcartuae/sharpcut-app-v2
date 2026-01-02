import 'package:sharp_cut/domain/home/models/service_model.dart';

class CartItemModel {
  final ServiceModel service;
  final int quantity;

  CartItemModel({required this.service, this.quantity = 1});

  CartItemModel copyWith({ServiceModel? service, int? quantity}) {
    return CartItemModel(
      service: service ?? this.service,
      quantity: quantity ?? this.quantity,
    );
  }
}
