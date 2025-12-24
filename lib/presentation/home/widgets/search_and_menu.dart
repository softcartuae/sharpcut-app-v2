import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:sharp_cut/utils/app_colors.dart';

class SearchAndMenu extends StatelessWidget {
  SearchAndMenu({required this.icon, super.key, this.onTap});

  final IconData icon;
  void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.5 : 1.0,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 47, 55, 70),
                  Color.fromARGB(255, 35, 42, 54),
                  Color.fromARGB(255, 25, 31, 40),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              border: const GradientBoxBorder(
                gradient: LinearGradient(
                  colors: [AppColors.violetLight, AppColors.violetDark],
                ),
                width: .10,
              ),
            ),
            alignment: Alignment.center,
            child: Center(child: Icon(icon, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
