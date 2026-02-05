import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sharp_cut/main.dart'; // To access navigatorKey

class ToastHelper {
  static void showToast({
    required String msg,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    if (Platform.isAndroid) {
      Fluttertoast.showToast(
        msg: msg,
        toastLength: toastLength,
        gravity: gravity,
        backgroundColor: backgroundColor,
        textColor: textColor,
      );
    } else {
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg, style: TextStyle(color: textColor)),
            backgroundColor: backgroundColor,
            duration: toastLength == Toast.LENGTH_LONG
                ? const Duration(seconds: 4)
                : const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static void showSuccess(String msg) {
    showToast(msg: msg, backgroundColor: Colors.green);
  }

  static void showError(String msg) {
    showToast(msg: msg, backgroundColor: Colors.red);
  }
}
