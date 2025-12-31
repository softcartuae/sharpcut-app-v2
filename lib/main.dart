import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/presentation/report/cubit/report_cubit.dart';
import 'package:sharp_cut/presentation/splash/screens/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/password/password_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_form_cubit.dart';
import 'package:sharp_cut/cubit/expenses/expense_cubit.dart';
import 'package:sharp_cut/utils/simple_bloc_observer.dart';

import 'package:sharp_cut/utils/theme.dart';

import 'package:sharp_cut/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  await di.init();
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<ServiceCubit>()),
          BlocProvider(create: (_) => di.sl<AuthCubit>()),
          BlocProvider(create: (_) => di.sl<ChairCubit>()),
          BlocProvider(create: (_) => di.sl<PasswordCubit>()),
          BlocProvider(create: (_) => di.sl<BookingCubit>()),
          BlocProvider(create: (_) => di.sl<ExpenseCubit>()),
          BlocProvider(create: (_) => di.sl<BookingFormCubit>()),
          BlocProvider(create: (_) => di.sl<PrintingCubit>()),
          BlocProvider(create: (_) => di.sl<ReportCubit>()),
        ],
        child: MyApp(),
      ), // Wrap your app
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spark Cut',
      theme: appTheme,
      home: SplashScreen(),
    );
  }
}
