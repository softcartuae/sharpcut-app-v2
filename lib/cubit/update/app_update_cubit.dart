import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/data/update/app_update_service.dart';

part 'app_update_state.dart';

class AppUpdateCubit extends Cubit<AppUpdateState> {
  final AppUpdateService _updateService;

  AppUpdateCubit({required AppUpdateService updateService})
    : _updateService = updateService,
      super(AppUpdateInitial());

  /// Checks the Play Store for an update and directly launches
  /// Google Play's native update UI (no custom prompt needed).
  Future<void> checkForUpdate() async {
    emit(AppUpdateChecking());

    final platform = Platform.isAndroid;
    if (!platform) {
      emit(AppUpdateNotAvailable());
      return;
    }

    final result = await _updateService.checkForUpdate();

    if (result == null) {
      emit(AppUpdateNotAvailable());
      return;
    }

    if (result.type == AppUpdateType.immediate) {
      emit(AppUpdateAvailableImmediate());
      await _triggerImmediateUpdate();
    } else {
      emit(AppUpdateAvailableFlexible());
      await _triggerFlexibleUpdate();
    }
  }

  /// Google Play shows its full-screen blocking update UI.
  Future<void> _triggerImmediateUpdate() async {
    try {
      await _updateService.startImmediateUpdate();
    } catch (_) {
      emit(AppUpdateError());
    }
  }

  /// Google Play shows its consent dialog and downloads in background.
  /// Emits [AppUpdateDownloaded] once the download completes.
  Future<void> _triggerFlexibleUpdate() async {
    try {
      final bool downloaded = await _updateService.startFlexibleUpdate();
      if (downloaded) {
        emit(AppUpdateDownloaded());
      }
    } catch (_) {
      emit(AppUpdateError());
    }
  }

  /// Installs a downloaded flexible update and restarts the app.
  Future<void> completeFlexibleUpdate() async {
    try {
      await _updateService.completeFlexibleUpdate();
    } catch (_) {
      emit(AppUpdateError());
    }
  }
}
