import 'dart:ui';
import 'package:flutter/material.dart';

/// Custom ScrollBehavior that allows horizontal dragging with mouse, touch, trackpad, and stylus.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
