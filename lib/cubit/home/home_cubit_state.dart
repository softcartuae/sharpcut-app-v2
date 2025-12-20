import 'package:equatable/equatable.dart';
import 'package:sharp_cut/domain/home/models/service_item_model.dart';

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
  final List<ServiceItemModel> services;

  ServiceStateSuccess({required this.services});

  @override
  List<Object?> get props => [services];

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
