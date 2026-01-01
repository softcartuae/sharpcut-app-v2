import 'package:equatable/equatable.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/home/models/categorie_model.dart';
import 'package:sharp_cut/domain/home/models/service_model.dart';

abstract class ServiceState implements Equatable {}

class ServiceStateInitial extends ServiceState {
  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => throw UnimplementedError();
}

class ServiceStateLoading extends ServiceState {
  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => throw UnimplementedError();
}

class ServiceStateSuccess extends ServiceState {
  final List<CategoryModel> categories;
  final List<ServiceModel> services;
  final bool isLoadingServices;
  final int? selectedCategoryId;
  final List<CartItemModel> cartItems;

  ServiceStateSuccess({
    required this.categories,
    required this.services,
    this.isLoadingServices = false,
    this.selectedCategoryId,
    this.cartItems = const [],
  });

  ServiceStateSuccess copyWith({
    List<CategoryModel>? categories,
    List<ServiceModel>? services,
    bool? isLoadingServices,
    int? selectedCategoryId,
    bool setCategoryIdToNull = false,
    List<CartItemModel>? cartItems,
  }) {
    return ServiceStateSuccess(
      categories: categories ?? this.categories,
      services: services ?? this.services,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      selectedCategoryId: setCategoryIdToNull
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      cartItems: cartItems ?? this.cartItems,
    );
  }

  double get subTotal {
    return cartItems.fold(0, (total, item) {
      final price = item.service.charge  ?? 0;
      return total + (price * item.quantity);
    });
  }

  double get vat {
    return cartItems.fold(0, (total, item) {
      final unitTax = item.service.unitTax ?? 0;
      return total + (unitTax * item.quantity);
    });
  }

  double get total {
    // Assuming charge includes VAT based on "inclusive" tax option in JSON
    // If charge is inclusive, total is just subTotal.
    // If exclusive, we might need to add VAT.
    // Based on JSON "before_vat" and "charge", it seems "charge" is the final price.
    // Let's assume charge is the price to pay for now.
    return subTotal;
  }

  @override
  List<Object?> get props => [
    categories,
    services,
    isLoadingServices,
    selectedCategoryId,
    cartItems,
  ];

  @override
  bool? get stringify => throw UnimplementedError();
}

class ServiceStateError extends ServiceState {
  final String message;

  ServiceStateError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  bool? get stringify => throw UnimplementedError();
}
