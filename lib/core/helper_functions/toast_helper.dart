import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:guess_game/core/theming/colors.dart';

/// Helper function for showing toast messages
/// Uses app colors (darker than alert dialog)
/// Alert dialog uses: Color(0xFF79899f).withOpacity(0.3)
/// Toast uses darker colors: Color(0xFF79899f) and Color(0xFF8b929b) without opacity
void toast(
  String? value, {
  ToastGravity? gravity,
  Toast length = Toast.LENGTH_LONG, // تغيير الافتراضي إلى LONG (5 ثواني تقريباً)
  Color? bgColor,
  Color? textColor,
  bool print = false,
}) {
  if (value == null || value.isEmpty) return;

  // استخدام ألوان أغمق من الـ alert dialog
  // Alert dialog: Color(0xFF79899f).withOpacity(0.3) - شفاف
  // Toast: Color(0xFF79899f) - أغمق بدون opacity
  final backgroundColor = bgColor ?? const Color(0xFF79899f);
  final textColorValue = textColor ?? Colors.white;

  // استخدام addPostFrameCallback لضمان ظهور التوست بعد اكتمال بناء الشجرة
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Fluttertoast.showToast(
      msg: value,
      gravity: gravity ?? ToastGravity.BOTTOM,
      toastLength: length,
      backgroundColor: backgroundColor,
      textColor: textColorValue,
      fontSize: 14.0,
    );
  });

  if (print) {
    debugPrint('Toast: $value');
  }
}

/// Helper class for showing toast messages with predefined types
class ToastHelper {
  /// Show a success toast message
  static void showSuccess(
    BuildContext context,
    String message, {
    ToastGravity? gravity,
    Duration? duration,
  }) {
    toast(
      message,
      gravity: gravity ?? ToastGravity.BOTTOM,
      length: Toast.LENGTH_LONG, // دائماً استخدم LONG (5 ثواني تقريباً)
      bgColor: Color(0xFF668899),
      textColor: Colors.white,
    );
  }

  /// Show an error toast message
  static void showError(
    BuildContext context,
    String message, {
    ToastGravity? gravity,
    Duration? duration,
  }) {
    toast(
      message,
      gravity: gravity ?? ToastGravity.BOTTOM,
      length: Toast.LENGTH_LONG, // دائماً استخدم LONG (5 ثواني تقريباً)
      bgColor: Colors.red,
      textColor: Colors.white,
    );
  }

  /// Show an info toast message
  static void showInfo(
    BuildContext context,
    String message, {
    ToastGravity? gravity,
    Duration? duration,
  }) {
    toast(
      message,
      gravity: gravity ?? ToastGravity.BOTTOM,
      length: Toast.LENGTH_LONG, // دائماً استخدم LONG (5 ثواني تقريباً)
      bgColor: AppColors.blue,
      textColor: Colors.white,
    );
  }

  /// Show a warning toast message
  static void showWarning(
    BuildContext context,
    String message, {
    ToastGravity? gravity,
    Duration? duration,
  }) {
    toast(
      message,
      gravity: gravity ?? ToastGravity.BOTTOM,
      length: Toast.LENGTH_LONG, // دائماً استخدم LONG (5 ثواني تقريباً)
      bgColor: AppColors.secondaryColor,
      textColor: Colors.white,
    );
  }

  /// Show a custom toast message with app colors (darker than alert dialog)
  static void showToast(
    BuildContext context,
    String message, {
    ToastGravity? gravity,
    Duration? duration,
    Color? bgColor,
    Color? textColor,
  }) {
    toast(
      message,
      gravity: gravity ?? ToastGravity.BOTTOM,
      length: Toast.LENGTH_LONG, // دائماً استخدم LONG (5 ثواني تقريباً)
      bgColor: bgColor,
      textColor: textColor,
    );
  }
}
