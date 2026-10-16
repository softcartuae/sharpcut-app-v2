part of 'app_update_cubit.dart';

abstract class AppUpdateState {}

/// Initial state — check has not been triggered yet.
class AppUpdateInitial extends AppUpdateState {}

/// Update check is in progress.
class AppUpdateChecking extends AppUpdateState {}

/// No update available — app is up to date or not supported on this platform.
class AppUpdateNotAvailable extends AppUpdateState {}

/// An optional update is available — Google Play's flexible dialog is shown.
class AppUpdateAvailableFlexible extends AppUpdateState {}

/// A required update is available — Google Play's full-screen flow is shown.
class AppUpdateAvailableImmediate extends AppUpdateState {}

/// A flexible update finished downloading and is ready to be installed.
/// The UI should inform the user and call [AppUpdateCubit.completeFlexibleUpdate].
class AppUpdateDownloaded extends AppUpdateState {}

/// The update check or trigger failed — handled silently.
class AppUpdateError extends AppUpdateState {}
