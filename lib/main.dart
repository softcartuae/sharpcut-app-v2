import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/splash/screens/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/home_cubit_event.dart';
import 'package:sharp_cut/data/home/service_repo_imp/service_repo_impl.dart';

import 'package:sharp_cut/utils/theme.dart';

void main() => runApp(
  DevicePreview(
    enabled: false,
    builder: (context) => BlocProvider(
      create: (_) => ServiceCubit(serviceRepo: ServiceRepoImpl()),
      child: MyApp(),
    ), // Wrap your app
  ),
);

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
