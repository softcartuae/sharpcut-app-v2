import 'package:flutter/material.dart';
import 'package:sharp_cut/utils/app_colors.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.violetNormal,
    surface: Colors.black,
    background: Colors.black,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
);
