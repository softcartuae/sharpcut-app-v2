import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/widgets/home_appbar.dart';
import 'package:sharp_cut/presentation/home/widgets/home_input_section.dart';
import 'package:sharp_cut/presentation/home/widgets/home_services_section.dart';

class ScreenHome extends StatelessWidget {
  ScreenHome({super.key});

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
