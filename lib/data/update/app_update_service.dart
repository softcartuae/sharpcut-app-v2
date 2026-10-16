import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Threshold for versionCode difference to decide update type.
/// If the available version is this many versions ahead → Immediate (forced).
/// Otherwise → Flexible (optional).
const int _kImmediateUpdateThreshold = 10;

/// Result of the update check — carries the update type decision.
enum AppUpdateType { flexible, immediate }

class AppUpdateCheckResult {
  final AppUpdateType type;
  final AppUpdateInfo info;

  const AppUpdateCheckResult({required this.type, required this.info});
}

class AppUpdateService {
  /// Checks whether an update is available on the Google Play Store.
  ///
  /// Safely handles non-Android platforms (e.g. Windows) and devices
  /// without Google Play Services (e.g. customized Android POS terminals).
  Future<AppUpdateCheckResult?> checkForUpdate() async {
    // Only Android devices with Google Play Store support in-app updates.
    if (kIsWeb || !Platform.isAndroid) {
      return null;
    }

    try {
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return null;
      }

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int installedCode = int.tryParse(packageInfo.buildNumber) ?? 0;
      final int availableCode = info.availableVersionCode ?? 0;
      final int difference = availableCode - installedCode;

      final AppUpdateType type = difference >= _kImmediateUpdateThreshold
          ? AppUpdateType.immediate
          : AppUpdateType.flexible;

      return AppUpdateCheckResult(info: info, type: type);
    } catch (_) {
      // Silently fail — update check should never crash the app
      // (e.g., POS terminals without Google Play Store or offline environments).
      return null;
    }
  }

  /// Starts a flexible update flow (Google Play shows its own consent dialog).
  /// The user can continue using the app while the update downloads.
  ///
  /// Returns `true` once the update has been downloaded successfully,
  /// `false` if the user declined or the flow failed.
  Future<bool> startFlexibleUpdate() async {
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }

    try {
      final AppUpdateResult result = await InAppUpdate.startFlexibleUpdate();
      return result == AppUpdateResult.success;
    } catch (_) {
      // Ignore — user may have dismissed the dialog or flow interrupted.
      return false;
    }
  }

  /// Starts an immediate (full-screen blocking) update flow.
  /// The user must update before they can continue using the app.
  Future<void> startImmediateUpdate() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (_) {
      // Ignore — flow was interrupted or dismissed.
    }
  }

  /// Completes a flexible update that has already been downloaded.
  /// Call this to prompt the user to restart and apply the downloaded update.
  Future<void> completeFlexibleUpdate() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (_) {
      // Ignore.
    }
  }
}
