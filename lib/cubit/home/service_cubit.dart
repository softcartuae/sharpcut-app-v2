import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/service_cubit_state.dart';
import 'package:sharp_cut/domain/home/models/cart_item_model.dart';
import 'package:sharp_cut/domain/home/models/service_model.dart';
import 'package:sharp_cut/domain/home/service/service_repo.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServiceRepo serviceRepo;
  ServiceCubit({required this.serviceRepo}) : super(ServiceStateInitial());

  void getCategories() async {
    emit(ServiceStateLoading());
    try {
      final categories = await serviceRepo.getCategories();
      final List<ServiceModel> services = await serviceRepo
          .getServices(); // Fetch all services initially
      emit(ServiceStateSuccess(categories: categories, services: services));
    } catch (e) {
      emit(ServiceStateError(message: e.toString()));
    }
  }

  void getServices({int? categoryId}) async {
    final currentState = state;
    if (currentState is ServiceStateSuccess) {
      emit(
        currentState.copyWith(
          isLoadingServices: true,
          selectedCategoryId: categoryId,
          setCategoryIdToNull: categoryId == null,
        ),
      );
      try {
        final List<ServiceModel> services = await serviceRepo.getServices(
          categoryId: categoryId,
        );
        emit(
          currentState.copyWith(
            services: services,
            isLoadingServices: false,
            selectedCategoryId: categoryId,
            setCategoryIdToNull: categoryId == null,
          ),
        );
      } catch (e) {
        emit(ServiceStateError(message: e.toString()));
      }
    }
  }

  void addToCart(ServiceModel service) {
    final currentState = state;
    if (currentState is ServiceStateSuccess) {
      final existingItemIndex = currentState.cartItems.indexWhere(
        (item) => item.service.id == service.id,
      );

      List<CartItemModel> updatedCart;
      if (existingItemIndex != -1) {
        // Item already exists, increment quantity
        updatedCart = List.from(currentState.cartItems);
        final existingItem = updatedCart[existingItemIndex];
        updatedCart[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
      } else {
        // Add new item
        updatedCart = List.from(currentState.cartItems)
          ..add(CartItemModel(service: service));
      }

      emit(currentState.copyWith(cartItems: updatedCart));
    }
  }

  void clearCart() {
    final currentState = state;
    if (currentState is ServiceStateSuccess) {
      emit(currentState.copyWith(cartItems: []));
    }
  }

  void removeFromCart(CartItemModel item) {
    final currentState = state;
    if (currentState is ServiceStateSuccess) {
      final updatedCart = List<CartItemModel>.from(currentState.cartItems)
        ..removeWhere((cartItem) => cartItem.service.id == item.service.id);
      emit(currentState.copyWith(cartItems: updatedCart));
    }
  }

  void updateQuantity(CartItemModel item, int change) {
    final currentState = state;
    if (currentState is ServiceStateSuccess) {
      final index = currentState.cartItems.indexWhere(
        (cartItem) => cartItem.service.id == item.service.id,
      );

      if (index != -1) {
        final updatedCart = List<CartItemModel>.from(currentState.cartItems);
        final currentItem = updatedCart[index];
        final newQuantity = currentItem.quantity + change;

        if (newQuantity > 0) {
          updatedCart[index] = currentItem.copyWith(quantity: newQuantity);
          emit(currentState.copyWith(cartItems: updatedCart));
        } else {
          // Optionally remove if quantity becomes 0, or just do nothing
          // For now, let's remove it if it goes to 0
          removeFromCart(item);
        }
      }
    }
  }

  void setCart(List<CartItemModel> items) {
    final currentState = state;
    if (currentState is ServiceStateSuccess) {
      emit(currentState.copyWith(cartItems: items));
    }
  }
}
