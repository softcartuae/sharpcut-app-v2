import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/service_cubit_state.dart';
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
}
