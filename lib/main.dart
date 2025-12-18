import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/screens/screen_home.dart';
import 'package:sharp_cut/presentation/login/screens/screen_login.dart';
import 'package:sharp_cut/utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spark Cut',
      theme: appTheme,
      home: ScreenHome(),
    );
  }
}
