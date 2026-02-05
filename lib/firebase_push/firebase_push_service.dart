import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/utils/helpers/toast_helper.dart';
import 'package:sharp_cut/injection_container.dart' as di;
import 'package:sharp_cut/domain/home/service/service_repo.dart';

class FirebasePushService {
  static Future<void> callingApiAndChangeStateByPushNotification(
    RemoteMessage message,
    BuildContext? context,
  ) async {
    final messageData = message.data;
    final type = messageData['type'];
    log("type: $type");

    ServiceCubit serviceCubit;
    ChairCubit chairCubit;

    if (context != null) {
      serviceCubit = context.read<ServiceCubit>();
      chairCubit = context.read<ChairCubit>();
    } else {
      // Background case: Initialize DI if not already done
      if (!di.sl.isRegistered<ServiceRepo>()) {
        await di.init();
      }
      serviceCubit = di.sl<ServiceCubit>();
      chairCubit = di.sl<ChairCubit>();
    }

    switch (type) {
      case 'booking_created':
        ToastHelper.showSuccess("New booking added");
        chairCubit.getChairsAndStaffs(forceRefresh: true);
        break;
      case 'service_created':
        serviceCubit.getServices();
        ToastHelper.showSuccess("New service added");
        break;
      case 'service_updated':
        serviceCubit.getServices();
        ToastHelper.showSuccess("Service updated");
        break;
      case 'service_deleted':
        serviceCubit.getServices();
        ToastHelper.showSuccess("Service deleted");
        break;
      case 'user_created':
        chairCubit.getChairsAndStaffs(forceRefresh: true);
        ToastHelper.showSuccess("New user added");
        break;
      case 'user_updated':
        chairCubit.getChairsAndStaffs(forceRefresh: true);
        ToastHelper.showSuccess("User updated");
        break;
      case 'user_deleted':
        chairCubit.getChairsAndStaffs(forceRefresh: true);
        ToastHelper.showSuccess("User deleted");
        break;
      case 'chair_created':
        chairCubit.getChairsAndStaffs(forceRefresh: true);
        ToastHelper.showSuccess("New chair added");
        break;
      case 'chair_updated':
        chairCubit.getChairsAndStaffs(forceRefresh: true);
        ToastHelper.showSuccess("Chair updated");
        break;
      case 'chair_deleted':
        chairCubit.getChairsAndStaffs(forceRefresh: true);
        ToastHelper.showSuccess("Chair deleted");
        break;
      case 'service_category_created':
        serviceCubit.getCategories();
        ToastHelper.showSuccess("Service category created");
        break;
      case 'service_category_deleted':
        serviceCubit.getCategories();
        ToastHelper.showSuccess("Service category deleted");
        break;
      case 'service_category_updated':
        serviceCubit.getCategories();
        ToastHelper.showSuccess("Service category updated");
        break;
      case 'admin_added':
        chairCubit.getChairsAndStaffs(forceRefresh: true);
        ToastHelper.showSuccess("Admin updated");
        break;
      default:
    }
  }
}
