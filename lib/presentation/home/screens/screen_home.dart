import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/widgets/home_appbar.dart';
import 'package:sharp_cut/presentation/home/widgets/home_input_section.dart';
import 'package:sharp_cut/presentation/home/widgets/home_services_section.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/home/chair_cubit.dart';

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(39.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeAppBar(),
              HomeInputSection(),
              SizedBox(height: 40),
              HomeServicesSection(),
            ],
          ),
        ),
      ),
    );
  }
}
