import 'package:get_it/get_it.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/password/password_cubit.dart';
import 'package:sharp_cut/data/auth/services/auth_repo_impl.dart';
import 'package:sharp_cut/data/home/service_repo_imp/service_repo_impl.dart';
import 'package:sharp_cut/data/home/chair/chair_repo_impl.dart';
import 'package:sharp_cut/domain/auth/service/auth_repo.dart';
import 'package:sharp_cut/domain/expenses/expense_repo.dart';
import 'package:sharp_cut/domain/home/service/service_repo.dart';
import 'package:sharp_cut/domain/home/chair/chair_repo.dart';
import 'package:sharp_cut/domain/password/service/password_repo.dart';
import 'package:sharp_cut/data/password/service/password_repo_imp.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';
import 'package:sharp_cut/domain/booking/booking_repo.dart';
import 'package:sharp_cut/data/booking/booking_repo_imp.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_form_cubit.dart';
import 'package:sharp_cut/cubit/expenses/expense_cubit.dart';

import 'package:sharp_cut/data/expenses/expense_repo_impl.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/domain/printing/printing_repo.dart';
import 'package:sharp_cut/data/printing/printing_repo_imp.dart';
import 'package:sharp_cut/presentation/report/cubit/report_cubit.dart';
import 'package:sharp_cut/domain/report/report_repo.dart';
import 'package:sharp_cut/data/report/report_repo_imp.dart';
import 'package:sharp_cut/data/report/service/report_service.dart';

import 'package:sharp_cut/cubit/quick_report/quick_report_cubit.dart';
import 'package:sharp_cut/domain/quick_report/service/quick_report_repo.dart';
import 'package:sharp_cut/data/quick_report/service/quick_report_repo_imp.dart';
import 'package:sharp_cut/data/quick_report/service/quick_report_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubits
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(authRepo: sl<AuthRepo>(), tokenStorage: sl<TokenStorage>()),
  );

  sl.registerFactory<ServiceCubit>(
    () => ServiceCubit(serviceRepo: sl<ServiceRepo>()),
  );

  sl.registerFactory<ChairCubit>(() => ChairCubit(chairRepo: sl<ChairRepo>()));

  sl.registerFactory<PasswordCubit>(
    () => PasswordCubit(passwordRepo: sl<PasswordRepo>()),
  );

  sl.registerFactory<BookingCubit>(
    () => BookingCubit(bookingRepo: sl<BookingRepo>()),
  );

  sl.registerFactory<ExpenseCubit>(
    () => ExpenseCubit(expenseRepo: sl<ExpenseRepo>()),
  );

  sl.registerFactory<BookingFormCubit>(() => BookingFormCubit());

  sl.registerFactory<PrintingCubit>(() => PrintingCubit(sl<PrintingRepo>()));

  sl.registerFactory<ReportCubit>(() => ReportCubit(sl<ReportRepo>()));

  sl.registerFactory<QuickReportCubit>(
    () => QuickReportCubit(sl<QuickReportRepo>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl());
  sl.registerLazySingleton<ServiceRepo>(() => ServiceRepoImpl());
  sl.registerLazySingleton<ChairRepo>(() => ChairRepoImpl());
  sl.registerLazySingleton<PasswordRepo>(() => PasswordRepoImp());
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<BookingRepo>(() => BookingRepoImp());
  sl.registerLazySingleton<ExpenseRepo>(() => ExpenseRepoImpl());
  sl.registerLazySingleton<PrintingRepo>(() => PrintingRepoImp());
  sl.registerLazySingleton<ReportRepo>(() => ReportRepoImp(ReportService()));
  sl.registerLazySingleton<QuickReportRepo>(
    () => QuickReportRepoImp(QuickReportService()),
  );
}
