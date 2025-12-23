import 'package:equatable/equatable.dart';
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

  ServiceStateSuccess({
    required this.categories,
    required this.services,
    this.isLoadingServices = false,
    this.selectedCategoryId,
  });

  ServiceStateSuccess copyWith({
    List<CategoryModel>? categories,
    List<ServiceModel>? services,
    bool? isLoadingServices,
    int? selectedCategoryId,
    bool setCategoryIdToNull = false,
  }) {
    return ServiceStateSuccess(
      categories: categories ?? this.categories,
      services: services ?? this.services,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      selectedCategoryId: setCategoryIdToNull
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }

  @override
  List<Object?> get props => [
    categories,
    services,
    isLoadingServices,
    selectedCategoryId,
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
