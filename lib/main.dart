import 'dart:async';
import 'dart:developer';
// import 'package:sharp_cut/core/database/database_helper.dart';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sharp_cut/cubit/booking/customer_search_cubit.dart';
import 'package:sharp_cut/cubit/shop_expenses/shop_expense_cubit.dart';

import 'package:sharp_cut/data/api_client.dart';
import 'package:sharp_cut/data/firebase_api.dart';
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
import 'package:sharp_cut/presentation/sync/cubit/sync_cubit.dart';
import 'package:sharp_cut/presentation/sync/cubit/master_sync_cubit.dart';
import 'package:sharp_cut/presentation/splash/screens/splash_screen.dart';
import 'package:sharp_cut/utils/simple_bloc_observer.dart';

import 'package:sharp_cut/utils/theme.dart';
import 'package:sharp_cut/presentation/login/screens/screen_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sharp_cut/firebase_push/firebase_push_service.dart';
import 'package:sharp_cut/injection_container.dart' as di;

import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sharp_cut/data/sync/sync_to_server.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';
import 'package:sharp_cut/domain/home/chair/chair_repo.dart';
import 'package:sharp_cut/domain/home/service/service_repo.dart';
import 'package:sharp_cut/domain/pusher/pusher_repo.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<bool> executeBackgroundSync() async {
  try {
    // 1. Initialize Necessary Components for the background isolate
    WidgetsFlutterBinding.ensureInitialized();

    // Register dependencies if they aren't already registered
    if (!di.sl.isRegistered<TokenStorage>()) {
      await di.init();
    }
    await ApiClient.init();

    // 2. Fetch Repositories
    final chairRepo = di.sl<ChairRepo>();
    final syncToServer = di.sl<SyncToServer>();
    final serviceRepo = di.sl<ServiceRepo>();

    // 3. Execute the sync flow
    log('Background: Performing Get Chair & Staffs Sync...');
    await chairRepo.getChairsAndStaffs();

    log('Background: Performing Server Transactions Sync...');
    await syncToServer.syncTransactionsFromServer();

    log('Background: Performing Server Cash Registers Sync...');
    await syncToServer.syncCashRegistersFromServer();

    log('Background: Performing Get Categories & Services Sync...');
    await serviceRepo.getCategories();
    await serviceRepo.getServices();

    log('Background: Syncing Transactions to Server...');
    await syncToServer.syncTransactionsToServer();

    log('Background sync completed successfully');
    unawaited(di.sl<PusherRepo>().notifyChairUpdate());
    return true;
  } catch (e) {
    log('Background sync failed: $e');
    return false;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return await executeBackgroundSync();
  });
}

void scheduleBackgroundSync(int minutes) {
  Workmanager().registerPeriodicTask(
    "1",
    "simplePeriodicTask",
    frequency: Duration(minutes: minutes),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    constraints: Constraints(networkType: NetworkType.connected),
  );
  log("Workmanager periodically registered with $minutes minutes frequency");
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    Workmanager().initialize(callbackDispatcher);

    final prefs = await SharedPreferences.getInstance();
    final syncTime = prefs.getInt('auth_sync_time') ?? 15;
    log("syncTIme $syncTime");
    scheduleBackgroundSync(syncTime);

    // await SystemChrome.setPrefefrrredOrientations([
    //   DeviceOrientation.landscapeLeft,sy
    //   DeviceOrientation
    //       .landscapeRight, // optional, remove if you want only upright
    // ]);

    await di.init();
    await ApiClient.init();

    // Listen for internet restoration to trigger instant Pusher updates
    Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        log(
          "Connectivity: Internet restored. Triggering Pusher notification...",
        );
        unawaited(di.sl<PusherRepo>().notifyChairUpdate());
      }
    });

    Bloc.observer = SimpleBlocObserver();
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
            BlocProvider(
              create: (context) =>
                  di.sl<PrintingCubit>()..loadPrinterSettings(),
            ),
            BlocProvider(create: (_) => di.sl<ReportCubit>()),
            BlocProvider(create: (_) => di.sl<QuickReportCubit>()),
            BlocProvider(create: (_) => di.sl<CashRegistoryCubit>()),
            BlocProvider(create: (_) => di.sl<SyncCubit>()),
            BlocProvider(create: (_) => di.sl<MasterSyncCubit>()),
            BlocProvider(create: (_) => di.sl<CustomerSearchCubit>()),
            BlocProvider(create: (_) => di.sl<ShopExpenseCubit>()),
          ],
          child: MyApp(),
        ), // Wrap your app
      ),
    );

    Future.microtask(() async {
      try {
        await Firebase.initializeApp();
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
