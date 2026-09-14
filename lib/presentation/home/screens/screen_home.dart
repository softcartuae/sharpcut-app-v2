import 'package:flutter/material.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/presentation/home/widgets/home_appbar.dart';
import 'package:sharp_cut/presentation/home/widgets/home_input_section.dart';
import 'package:sharp_cut/presentation/home/widgets/home_services_section.dart';
import 'package:sharp_cut/presentation/sync/cubit/master_sync_cubit.dart';
import 'package:sharp_cut/presentation/sync/cubit/sync_cubit.dart';
import 'package:sharp_cut/presentation/sync/widgets/sync_progress_dialog.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_state.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  @override
  void initState() {
    super.initState();
    _performInitialSync();
  }

  Future<void> _performInitialSync() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SyncProgressDialog.show(context);
        context.read<MasterSyncCubit>().syncAll(
              chairCubit: context.read<ChairCubit>(),
              serviceCubit: context.read<ServiceCubit>(),
              syncCubit: context.read<SyncCubit>(),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWindows = Theme.of(context).platform == TargetPlatform.windows;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 39.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeAppBar(),
          const HomeInputSection(),
          const SizedBox(height: 15),
          isWindows
              ? const Expanded(child: HomeServicesSection())
              : const HomeServicesSection(),
        ],
      ),
    );

    return Scaffold(
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingCancelled || state is BookingInitial) {
            context.read<ChairCubit>().getChairsAndStaffs(
                  forceRefresh: true,
                );

            context.read<ServiceCubit>().clearCart();
          }
        },
        child: isWindows ? content : SingleChildScrollView(child: content),
      ),
    );
  }
}
