import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/home_cubit_state.dart';
import 'package:sharp_cut/domain/home/service/service_repo.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServiceRepo serviceRepo;
  ServiceCubit({required this.serviceRepo}) : super(ServiceStateInitial());

  void getServices() async {
    emit(ServiceStateLoading());
    try {
      final services = await serviceRepo.getServices();
      emit(ServiceStateSuccess(services: services));
    } catch (e) {
      emit(ServiceStateError(message: e.toString()));
    }
  }
  
}
