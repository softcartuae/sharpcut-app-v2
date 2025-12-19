import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:sharp_cut/presentation/home/screens/screen_home.dart';

import 'package:sharp_cut/utils/theme.dart';

void main() => runApp(
  DevicePreview(
    enabled: false,
    builder: (context) => MyApp(), // Wrap your app
  ),
);

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
