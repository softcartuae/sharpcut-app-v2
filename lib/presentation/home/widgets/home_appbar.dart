import 'package:flutter/material.dart';
import 'package:sharp_cut/data/local_storage/token_storage.dart';
import 'package:sharp_cut/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

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
                final d = await TokenStorage().getToken();
                print(d);
              },
              child: Image.asset(
                "lib/utils/images/sharp_cut.png",
                height: 150,
                width: 150,
              ),
            ),
            const SizedBox(width: 25),
            Image.asset(
              "lib/utils/images/Shop Location.png",
              height: 40,
              width: 40,
              color: AppColors.violetLight,
            ),
            const SizedBox(width: 12),
            Text(
              "TAJ SALON",
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
              "28-04-2024",
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 21),
            ),
            Container(
              height: 15,
              width: 1,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            const Icon(Icons.access_time, color: Colors.white, size: 21),
            const SizedBox(width: 8),
            Text(
              "10:00 AM",
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 21),
            ),
            const SizedBox(width: 40),
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("lib/utils/images/profile_pic.png"),
            ),
            const SizedBox(width: 12),
            Text(
              "Hi Benjamin",
              style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 21),
            ),
          ],
        ),
      ],
    );
  }
}
