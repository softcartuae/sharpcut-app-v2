import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/screens/screen_home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ScreenHome()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          width: MediaQuery.of(context).size.width * 0.3,
          'lib/utils/images/sharp_cut.png',
          // You might want to add width/height or fit properties if needed,
          // but for now I'll stick to the basic request.
        ),
      ),
    );
  }
}
