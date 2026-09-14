abstract class MasterSyncState {}

class MasterSyncInitial extends MasterSyncState {}

class MasterSyncLoading extends MasterSyncState {
  final String message;
  final double progress;
  final String? stepDetail;

  MasterSyncLoading({
    required this.message,
    this.progress = 0.0,
    this.stepDetail,
  });

  int get percentage => (progress.clamp(0.0, 1.0) * 100).toInt();
}

class MasterSyncSuccess extends MasterSyncState {
  final String message;
  MasterSyncSuccess(this.message);
}

class MasterSyncError extends MasterSyncState {
  final String message;
  MasterSyncError(this.message);
}
