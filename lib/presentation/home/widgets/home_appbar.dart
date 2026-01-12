import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sharp_cut/cubit/auth/auth_cubit.dart';
import 'package:sharp_cut/cubit/booking/booking_cubit.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
              onTap: () async {
                
              
              },
              child: Image.asset(
                "lib/utils/images/sharp_cut.png",
                height: 80,
                width: 80,
              ),
            ),
            const SizedBox(width: 25),
            Image.asset(
              "lib/utils/images/Shop Location.png",
              height: 30,
              width: 30,
              color: AppColors.violetLight,
            ),
            const SizedBox(width: 12),
            Text(
              storeName,
              style: GoogleFonts.rajdhani(
                color: AppColors.violetLight,
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
          ],
        ),

        // Right Section: User Profile
        Row(
          children: [
            Image.asset("lib/utils/images/Calendar.png", width: 20, height: 20),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd MMM yyyy').format(DateTime.now()),
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 21),
            ),
            // Container(
            //   height: 15,
            //   width: 1,
            //   color: Colors.white,
            //   margin: const EdgeInsets.symmetric(horizontal: 12),
            // ),
            // const Icon(Icons.access_time, color: Colors.white, size: 21),
            // const SizedBox(width: 8),
            // Text(
            //   _timeString,
            //   style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 21),
            // ),
            const SizedBox(width: 40),
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("lib/utils/images/profile_pic.png"),
            ),
            const SizedBox(width: 12),
            // Text(
            //   "Hi Benjamin",
            //   style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 21),
            // ),
          ],
        ),
      ],
    );
  }
}
