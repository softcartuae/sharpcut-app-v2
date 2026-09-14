import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/presentation/sync/cubit/master_sync_cubit.dart';
import 'package:sharp_cut/presentation/sync/cubit/master_sync_state.dart';
import 'package:sharp_cut/presentation/sync/cubit/sync_cubit.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class SyncProgressDialog extends StatelessWidget {
  const SyncProgressDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SyncProgressDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: isDark ? const Color(0xFF1E1C24) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 440),
        child: BlocConsumer<MasterSyncCubit, MasterSyncState>(
          listener: (context, state) {
            if (state is MasterSyncSuccess) {
              Future.delayed(const Duration(milliseconds: 900), () {
                if (context.mounted && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              });
            }
          },
          builder: (context, state) {
            if (state is MasterSyncSuccess) {
              return _buildSuccessState(context, state.message);
            }

            if (state is MasterSyncError) {
              return _buildErrorState(context, state.message);
            }

            final loadingState = state is MasterSyncLoading
                ? state
                : MasterSyncLoading(
                    message: 'Initializing Synchronization...',
                    progress: 0.0,
                  );

            return _buildLoadingState(context, loadingState);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, MasterSyncLoading state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Dialog Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.violetNormal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cloud_sync_rounded,
                    color: AppColors.violetNormal,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Data Syncing',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.violetNormal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.violetNormal.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${state.percentage}%',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.violetNormal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(
          height: 1,
          thickness: 1,
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        const SizedBox(height: 24),

        // Animated Central Sync Ring
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 86,
              height: 86,
              child: CircularProgressIndicator(
                value: state.progress > 0 ? state.progress : null,
                strokeWidth: 7,
                backgroundColor: AppColors.violetNormal.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.violetNormal,
                ),
              ),
            ),
            const Icon(
              Icons.sync_rounded,
              size: 38,
              color: AppColors.violetNormal,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Linear Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: state.progress > 0 ? state.progress : null,
            minHeight: 8,
            backgroundColor: AppColors.violetNormal.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.violetNormal,
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Status Message
        Text(
          state.message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade200 : Colors.grey.shade900,
          ),
        ),

        // Live Subtext / Chunk Counter Badge
        if (state.stepDetail != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              state.stepDetail!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.greenNormal.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.greenNormal,
            size: 56,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Sync Completed!',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greenNormal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.redNormal.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: AppColors.redNormal,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sync Encountered an Error',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.redNormal,
          ),
        ),
        const SizedBox(height: 12),

        // Error message container
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.redNormal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.redNormal.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.redDark,
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.shade400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Close', style: GoogleFonts.inter()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<MasterSyncCubit>().syncAll(
                        chairCubit: context.read<ChairCubit>(),
                        serviceCubit: context.read<ServiceCubit>(),
                        syncCubit: context.read<SyncCubit>(),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violetNormal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Retry Sync',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
