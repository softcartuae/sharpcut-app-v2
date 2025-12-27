import 'package:flutter/material.dart';
import 'package:sharp_cut/cubit/home/service_cubit.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<ChairCubit>().getChairsAndStaffs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingCancelled || state is BookingInitial) {
            context.read<ChairCubit>().getChairsAndStaffs(forceRefresh: true);
            if (state is BookingCancelled) {
              context.read<ServiceCubit>().clearCart();
            }
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 39.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeAppBar(),
                HomeInputSection(),
                SizedBox(height: 20),
                HomeServicesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
