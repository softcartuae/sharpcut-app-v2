import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/data/sync/sync_to_server.dart';

part 'sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  final SyncToServer _syncToServer;

  SyncCubit({SyncToServer? syncToServer})
    : _syncToServer = syncToServer ?? SyncToServer(),
      super(SyncInitial());

  Future<void> syncTransactions() async {
    emit(SyncLoading());
    try {
      final result = await _syncToServer.syncTransactionsToServer();
      result.fold(
        (error) => emit(SyncError(error)),
        (success) => emit(SyncSuccess(success)),
      );
    } catch (e) {
      emit(SyncError("Failed to sync transactions: $e"));
    }
  }
}
