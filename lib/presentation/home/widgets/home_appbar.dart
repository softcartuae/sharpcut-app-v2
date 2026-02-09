import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/presentation/test/database_viewer_screen.dart';

import 'package:sharp_cut/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String storeName = "";

  @override
  void initState() {
    storeName = context.read<AuthCubit>().currentUser?.name ?? "";
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Section: Logo & Shop Name
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DatabaseViewerScreen(),
                  ),
                );
              },
              child: Image.asset(
                "lib/utils/images/logo2.png",
                height: 70,
                width: 120,
              ),
            ),
            const SizedBox(width: 25),
            Image.asset(
              "lib/utils/images/Shop Location.png",
              height: 25,
              width: 25,
              color: AppColors.violetLight,
            ),
            const SizedBox(width: 8),
            Text(
              storeName,
              style: GoogleFonts.rajdhani(
                color: AppColors.violetLight,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ],
        ),

        Row(
          children: [
            BlocBuilder<AuthCubit, AuthCubitState>(
              builder: (context, state) {
                var version = context.read<AuthCubit>().appVersion;
                if (version.isEmpty) {
                  version = "";
                }

                String modeType = "";
                final mode = context.read<AuthCubit>().currentUser?.mode;

                if (mode == "online") {
                  modeType = "ON";
                } else if (mode == "offline") {
                  modeType = "OFF";
                }

                return Text(
                  "Ver. $modeType-$version",
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                );
              },
            ),
          ],
        ),

        // Right Section: User Profile
        Row(
          children: [
            BlocBuilder<PrintingCubit, PrintingState>(
              builder: (context, state) {
                return Row(
                  children: [
                    Icon(
                      Icons.print,
                      color: state.connectedPrinter != null
                          ? Colors.green
                          : Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 15),
                  ],
                );
              },
            ),

            Image.asset("lib/utils/images/Calendar.png", width: 20, height: 20),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd MMM yyyy').format(DateTime.now()),
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}
