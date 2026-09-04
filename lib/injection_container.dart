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
import 'package:sharp_cut/cubit/booking/customer_search_cubit.dart';
import 'package:sharp_cut/cubit/online_booking/online_booking_cubit.dart';
import 'package:sharp_cut/cubit/staff_wise_booking/staff_wise_booking_cubit.dart';

import 'package:sharp_cut/data/expenses/expense_repo_impl.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/domain/printing/printing_repo.dart';
import 'package:sharp_cut/data/printing/printing_repo_imp.dart';
import 'package:sharp_cut/data/printing/service/printing_service.dart';
import 'package:sharp_cut/presentation/report/cubit/report_cubit.dart';
import 'package:sharp_cut/domain/report/report_repo.dart';
import 'package:sharp_cut/data/report/report_repo_imp.dart';
import 'package:sharp_cut/data/report/service/report_service.dart';

import 'package:sharp_cut/cubit/quick_report/quick_report_cubit.dart';
import 'package:sharp_cut/domain/quick_report/service/quick_report_repo.dart';
import 'package:sharp_cut/data/quick_report/service/quick_report_repo_imp.dart';
import 'package:sharp_cut/data/quick_report/service/quick_report_service.dart';

import 'package:sharp_cut/cubit/cash_registory/cash_registory_cubit.dart';
import 'package:sharp_cut/domain/cash_registory/service/cash_registory_repo.dart';
import 'package:sharp_cut/data/cash_registory/service/cash_registory_repo_imp.dart';

import 'package:sharp_cut/cubit/shop_expenses/shop_expense_cubit.dart';
import 'package:sharp_cut/domain/shop_expenses/shop_expense_repo.dart';
import 'package:sharp_cut/data/shop_expenses/shop_expense_repo_impl.dart';

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

  sl.registerFactory<OnlineBookingCubit>(
    () => OnlineBookingCubit(bookingRepo: sl<BookingRepo>()),
  );

  sl.registerFactory<StaffWiseBookingCubit>(
    () => StaffWiseBookingCubit(bookingRepo: sl<BookingRepo>()),
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

  sl.registerFactory<CashRegistoryCubit>(
    () => CashRegistoryCubit(cashRegistoryRepo: sl<CashRegistoryRepo>()),
  );

  sl.registerFactory<CustomerSearchCubit>(
    () => CustomerSearchCubit(sl<BookingRepo>()),
  );

  sl.registerFactory<ShopExpenseCubit>(
    () => ShopExpenseCubit(shopExpenseRepo: sl<ShopExpenseRepo>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(tokenStorage: sl<TokenStorage>()),
  );

  sl.registerLazySingleton<ServiceRepo>(() => ServiceRepoImpl());
  sl.registerLazySingleton<ChairRepo>(() => ChairRepoImpl());
  sl.registerLazySingleton<PasswordRepo>(() => PasswordRepoImp());
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<BookingRepo>(() => BookingRepoImp());
  sl.registerLazySingleton<ExpenseRepo>(() => ExpenseRepoImpl());
  sl.registerLazySingleton<PrintingRepo>(
    () => PrintingRepoImp(PrintingService()),
  );
  sl.registerLazySingleton<ReportRepo>(() => ReportRepoImp(ReportService()));
  sl.registerLazySingleton<QuickReportRepo>(
    () => QuickReportRepoImp(QuickReportService()),
  );
  sl.registerLazySingleton<CashRegistoryRepo>(() => CashRegistoryRepoImp());
  sl.registerLazySingleton<ShopExpenseRepo>(() => ShopExpenseRepoImpl());
}
