import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sharp_cut/main.dart';

class ToastHelper {
  static OverlayEntry? _overlayEntry;

  static void showToast({
    required String msg,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    // 📱 Mobile → native toast
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(
        msg: msg,
        toastLength: toastLength,
        gravity: gravity,
        backgroundColor: backgroundColor,
        textColor: textColor,
      );
      return;
    }

    // 🖥 Desktop / Web → Overlay toast
    _showOverlayToast(
      msg: msg,
      backgroundColor: backgroundColor,
      textColor: textColor,
      duration: const Duration(seconds: 4),
    );
  }

  static void _showOverlayToast({
    required String msg,
    required Color backgroundColor,
    required Color textColor,
    required Duration duration,
  }) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    // Remove existing toast
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(navigator.context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(blurRadius: 10, color: Colors.black26),
              ],
            ),
            child: Text(msg, style: TextStyle(color: textColor)),
          ),
        ),
      ),
    );

    // 🔥 THIS is the magic line
    navigator.overlay!.insert(_overlayEntry!);

    Future.delayed(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  static void showSuccess(String msg) {
    showToast(msg: msg, backgroundColor: Colors.green);
  }

  static void showError(String msg) {
    showToast(msg: msg, backgroundColor: Colors.red);
  }
}
