import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/login/screens/screen_login.dart';
import 'package:sharp_cut/presentation/splash/screens/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/home_cubit.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';

import 'package:sharp_cut/utils/theme.dart';

import 'package:sharp_cut/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<ServiceCubit>()),
          BlocProvider(create: (_) => di.sl<AuthCubit>()),
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
