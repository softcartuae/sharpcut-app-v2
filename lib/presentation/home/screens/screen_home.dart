import 'package:flutter/material.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
import 'package:sharp_cut/data/sync/sync_to_server.dart';
import 'package:sharp_cut/presentation/home/widgets/home_appbar.dart';
import 'package:sharp_cut/presentation/home/widgets/home_input_section.dart';
import 'package:sharp_cut/presentation/home/widgets/home_services_section.dart';

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
  final ValueNotifier<bool> _isSyncing = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    context.read<ChairCubit>().getChairsAndStaffs();
    _performInitialSync();
  }

  Future<void> _performInitialSync() async {
    _isSyncing.value = true;
    try {
      await SyncToServer().syncTransactionsFromServer();
      await SyncToServer().syncCashRegistersFromServer();
    } finally {
      if (mounted) {
        _isSyncing.value = false;
      }
    }
  }

  @override
  void dispose() {
    _isSyncing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocListener<BookingCubit, BookingState>(
            listener: (context, state) {
              if (state is BookingCancelled || state is BookingInitial) {
                context.read<ChairCubit>().getChairsAndStaffs(
                  forceRefresh: true,
                );

                context.read<ServiceCubit>().clearCart();
              }
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 39.0,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeAppBar(),
                    HomeInputSection(),
                    SizedBox(height: 15),
                    HomeServicesSection(),
                  ],
                ),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isSyncing,
            builder: (context, isSyncing, child) {
              if (!isSyncing) return const SizedBox.shrink();

              return Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Syncing data...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
