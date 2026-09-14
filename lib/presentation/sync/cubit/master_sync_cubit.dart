import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/data/sync/sync_to_server.dart';
import 'package:sharp_cut/presentation/sync/cubit/master_sync_state.dart';
import 'package:sharp_cut/presentation/sync/cubit/sync_cubit.dart';

import 'package:sharp_cut/injection_container.dart';

class MasterSyncCubit extends Cubit<MasterSyncState> {
  final SyncToServer _syncToServer;

  MasterSyncCubit({SyncToServer? syncToServer})
    : _syncToServer = syncToServer ?? sl<SyncToServer>(),
      super(MasterSyncInitial());

  Future<void> syncAll({
    required ChairCubit chairCubit,
    required ServiceCubit serviceCubit,
    required SyncCubit syncCubit,
  }) async {
    try {
      // Stage 1: Chairs & Staffs (0% - 15%)
      emit(
        MasterSyncLoading(
          message: 'Fetching Chairs & Staff Data...',
          progress: 0.10,
          stepDetail: 'Step 1 of 5',
        ),
      );
      await chairCubit.getChairsAndStaffs(forceRefresh: true);

      // Stage 2: Server Transactions Down-Sync (15% - 60%)
      emit(
        MasterSyncLoading(
          message: 'Downloading Server Transactions...',
          progress: 0.15,
          stepDetail: 'Step 2 of 5 • Initializing cursor...',
        ),
      );
      final result = await _syncToServer.syncTransactionsFromServer(
        onProgress: (chunkCount, totalItems) {
          // Dynamic progress from 0.15 up to 0.60 smoothly for any number of chunks
          double factor = 1.0 - math.exp(-chunkCount / 25.0);
          double chunkProgress = (0.15 + (0.44 * factor)).clamp(0.15, 0.59);
          emit(
            MasterSyncLoading(
              message: 'Downloading Server Transactions...',
              progress: chunkProgress,
              stepDetail: 'Chunk #$chunkCount • $totalItems items processed',
            ),
          );
        },
      );

      if (result.isLeft()) {
        String errorMsg = result.fold((l) => l, (r) => '');
        emit(
          MasterSyncError(
            'Failed to sync transactions: $errorMsg. Please check internet connection.',
          ),
        );
        return;
      }

      // Stage 3: Cash Registers Sync (60% - 75%)
      emit(
        MasterSyncLoading(
          message: 'Downloading Cash Registers Data...',
          progress: 0.60,
          stepDetail: 'Step 3 of 5 • Initializing cursor...',
        ),
      );
      final cashRegResult = await _syncToServer.syncCashRegistersFromServer(
        onProgress: (chunkCount, totalItems) {
          double factor = 1.0 - math.exp(-chunkCount / 10.0);
          double chunkProgress = (0.60 + (0.14 * factor)).clamp(0.60, 0.74);
          emit(
            MasterSyncLoading(
              message: 'Downloading Cash Registers Data...',
              progress: chunkProgress,
              stepDetail: 'Chunk #$chunkCount • $totalItems registers processed',
            ),
          );
        },
      );

      if (cashRegResult.isLeft()) {
        String errorMsg = cashRegResult.fold((l) => l, (r) => '');
        emit(MasterSyncError('Failed to sync cash registers: $errorMsg'));
        return;
      }

      // Stage 4: Categories Sync (75% - 85%)
      emit(
        MasterSyncLoading(
          message: 'Downloading Service Categories...',
          progress: 0.75,
          stepDetail: 'Step 4 of 5',
        ),
      );
      await serviceCubit.getCategories();

      // Stage 5: Transactions Up-Sync (85% - 100%)
      emit(
        MasterSyncLoading(
          message: 'Uploading Offline Transactions to Server...',
          progress: 0.85,
          stepDetail: 'Step 5 of 5 • Preparing batch upload...',
        ),
      );
      final uploadResult = await _syncToServer.syncTransactionsToServer(
        onProgress: (batchCount, totalItems) {
          double batchProgress = (0.85 + (batchCount * 0.03)).clamp(0.85, 0.98);
          emit(
            MasterSyncLoading(
              message: 'Uploading Offline Transactions to Server...',
              progress: batchProgress,
              stepDetail: 'Batch #$batchCount • $totalItems transactions uploaded',
            ),
          );
        },
      );

      if (uploadResult.isLeft()) {
        String errorMsg = uploadResult.fold((l) => l, (r) => '');
        emit(MasterSyncError('Upload Failed: $errorMsg'));
        return;
      }

      emit(
        MasterSyncLoading(
          message: 'Finalizing Synchronization...',
          progress: 1.0,
          stepDetail: 'Complete!',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      emit(MasterSyncSuccess('All data synced successfully!'));
    } catch (e) {
      emit(
        MasterSyncError('Sync Failed: $e. Check your internet connection.'),
      );
    }
  }
}
