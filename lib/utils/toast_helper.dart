import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static void showToast({
    required String msg,
    Toast toastLength = Toast.LENGTH_SHORT,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color? backgroundColor,
    Color? textColor,
    double fontSize = 16.0,
  }) {
    // Standard Fluttertoast for Android/iOS
    // On macOS/Desktop, we try Fluttertoast but fallback to print or ignore if it fails
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(
        msg: msg,
        toastLength: toastLength,
        gravity: gravity,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize,
      );
    } else {
      print("Toast: $msg");
    }
  }
}
