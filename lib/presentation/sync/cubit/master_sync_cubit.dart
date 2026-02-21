import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/data/sync/sync_to_server.dart';
import 'package:sharp_cut/presentation/sync/cubit/master_sync_state.dart';
import 'package:sharp_cut/presentation/sync/cubit/sync_cubit.dart';

class MasterSyncCubit extends Cubit<MasterSyncState> {
  final SyncToServer _syncToServer;

  MasterSyncCubit({SyncToServer? syncToServer})
    : _syncToServer = syncToServer ?? SyncToServer(),
      super(MasterSyncInitial());

  Future<void> syncAll({
    required ChairCubit chairCubit,
    required ServiceCubit serviceCubit,
    required SyncCubit syncCubit,
  }) async {
    try {
      emit(MasterSyncLoading('Performing Get Chair & Staffs Sync...'));
      await chairCubit.getChairsAndStaffs(forceRefresh: true);

      emit(MasterSyncLoading('Performing Server Transactions Sync...'));
      await _syncToServer.syncTransactionsFromServer();

      emit(MasterSyncLoading('Performing Server Cash Registers Sync...'));
      await _syncToServer.syncCashRegistersFromServer();

      emit(MasterSyncLoading('Performing Get Categories Sync...'));
      await serviceCubit.getCategories();

      emit(MasterSyncLoading('Syncing Transactions to Server...'));
      await syncCubit.syncTransactions();

      emit(MasterSyncSuccess('All synced successfully!'));
    } catch (e) {
      emit(MasterSyncError('Failed to sync all: $e'));
    }
  }
}
