import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';

import 'package:sharp_cut/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sharp_cut/presentation/printing/cubit/printing_cubit.dart';
import 'package:sharp_cut/build_config.dart';
import 'package:sharp_cut/utils/helpers/check_no_chair.dart';

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
              onLongPress: () {
                final isNoChair = CheckNoChair.checkIsThisAppNoChairOrNot(
                  context.read<AuthCubit>().currentUser,
                );

                print("isNoChair: $isNoChair");

                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Build Information"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Build Date: ${BuildConfig.buildDate}"),
                          const SizedBox(height: 8),
                          Text("App Version: ${BuildConfig.appVersionAtBuild}"),
                          const SizedBox(height: 8),
                          Text("API Version: ${BuildConfig.apiVersionAtBuild}"),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  },
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
            Builder(
              builder: (context) {
                String modeType = "";
                final mode = context.read<AuthCubit>().currentUser?.mode;
                final isNoChair = CheckNoChair.checkIsThisAppNoChairOrNot(
                  context.read<AuthCubit>().currentUser,
                );
                modeType = findMode(mode, isNoChair);

                return Text(
                  "Ver. $modeType-2.0",
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

  String findMode(String? mode, bool isChair) {
    String modeType;

    switch (mode) {
      case "online":
        modeType = isChair ? "NCON" : "ON";
        break;

      case "offline":
        modeType = isChair ? "NCOF" : "OF";
        break;

      default:
        modeType = "";
    }

    return modeType;
  }
}
