part of 'sync_cubit.dart';

abstract class SyncState {}

class SyncInitial extends SyncState {}

class SyncLoading extends SyncState {}

class SyncSuccess extends SyncState {
  final String message;
  SyncSuccess(this.message);
}

class SyncError extends SyncState {
  final String message;
  SyncError(this.message);
}
