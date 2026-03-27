import 'dart:developer';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/firebase_options.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/presentation/report/cubit/report_cubit.dart';
import 'package:sharp_cut/cubit/quick_report/quick_report_cubit.dart';
import 'package:sharp_cut/cubit/cash_registory/cash_registory_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/password/password_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_form_cubit.dart';
import 'package:sharp_cut/cubit/expenses/expense_cubit.dart';
import 'package:sharp_cut/cubit/booking/customer_search_cubit.dart';
import 'package:sharp_cut/presentation/splash/screens/splash_screen.dart';
import 'package:sharp_cut/utils/simple_bloc_observer.dart';

import 'package:sharp_cut/utils/theme.dart';
import 'package:sharp_cut/presentation/login/screens/screen_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sharp_cut/firebase_push/firebase_push_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sharp_cut/data/firebase_api.dart';
import 'package:sharp_cut/injection_container.dart' as di;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // await SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation
    //       .landscapeRight, // optional, remove if you want only upright
    // ]);

    await di.init();
    await ApiClient.init();

    Bloc.observer = SimpleBlocObserver();
    runApp(
      DevicePreview(
        enabled: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => di.sl<ServiceCubit>()),
            BlocProvider(create: (_) => di.sl<AuthCubit>()),
            BlocProvider(create: (_) => di.sl<ChairCubit>()),
            BlocProvider(create: (_) => di.sl<PasswordCubit>()),
            BlocProvider(create: (_) => di.sl<BookingCubit>()),
            BlocProvider(create: (_) => di.sl<ExpenseCubit>()),
            BlocProvider(create: (_) => di.sl<BookingFormCubit>()),
            BlocProvider(
              create: (context) =>
                  di.sl<PrintingCubit>()..loadPrinterSettings(),
            ),
            BlocProvider(create: (_) => di.sl<ReportCubit>()),
            BlocProvider(create: (_) => di.sl<QuickReportCubit>()),
            BlocProvider(create: (_) => di.sl<CashRegistoryCubit>()),
            BlocProvider(create: (_) => di.sl<CustomerSearchCubit>()),
          ],
          child: MyApp(),
        ), // Wrap your app
      ),
    );

    Future.microtask(() async {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        await FirebaseApi().initNotifications();
        log("Firebase initilazation completed successfully");
      } catch (e) {
        log('Firebase skipped on this device: $e');
      }
    });
    log("main function completed successfully");
  } catch (e, stackTrace) {
    log('Initialization failed', error: e, stackTrace: stackTrace);
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Initialization Failed:\n$e\n\n$stackTrace',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBackgroundNotification();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBackgroundNotification();
    }
  }

  Future<void> _checkBackgroundNotification() async {
    log("Checking background notification");
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final notificationDataString = prefs.getString(
        'background_notification_data',
      );

      if (notificationDataString != null) {
        log('Found background notification data: $notificationDataString');
        final Map<String, dynamic> data = jsonDecode(notificationDataString);
        final message = RemoteMessage(data: data);
        if (mounted) {
          // Use the navigatorKey context or the current context if available
          final context = navigatorKey.currentContext;
          if (context != null) {
            FirebasePushService.callingApiAndChangeStateByPushNotification(
              message,
              context,
            );
            // Clear the data after processing
            await prefs.remove('background_notification_data');
          }
        }
      } else {
        log("No background notification data found");
      }
    } catch (e) {
      log('Error checking background notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Spark Cut',
      theme: appTheme,
      builder: (context, child) {
        return BlocListener<AuthCubit, AuthCubitState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              navigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const ScreenLogin()),
                (route) => false,
              );
            }
          },
          child: child!,
        );
      },
      home: SplashScreen(),
    );
  }
}
