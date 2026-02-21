abstract class MasterSyncState {}

class MasterSyncInitial extends MasterSyncState {}

class MasterSyncLoading extends MasterSyncState {
  final String message;
  MasterSyncLoading(this.message);
}

class MasterSyncSuccess extends MasterSyncState {
  final String message;
  MasterSyncSuccess(this.message);
}

class MasterSyncError extends MasterSyncState {
  final String message;
  MasterSyncError(this.message);
}
