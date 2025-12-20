import 'package:get_it/get_it.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/home/home_cubit.dart';
import 'package:sharp_cut/data/auth/services/auth_repo_impl.dart';
import 'package:sharp_cut/data/home/service_repo_imp/service_repo_impl.dart';
import 'package:sharp_cut/domain/auth/service/auth_repo.dart';
import 'package:sharp_cut/domain/home/service/service_repo.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubits
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerFactory(() => ServiceCubit(serviceRepo: sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl());
  sl.registerLazySingleton<ServiceRepo>(() => ServiceRepoImpl());
}
