import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF1F5E46);
  static const deep = Color(0xFF0E4A37);
  static const ink = Color(0xFF0F1F18);
  static const muted = Color(0xFF627169);
  static const mint = Color(0xFFD6EFE2);
  static const mintSoft = Color(0xFFE9F6EF);
  static const bg = Color(0xFFF4FAF6);
  static const line = Color(0xFFE1EBE5);
  static const accent = Color(0xFF2EBF84);
  static const danger = Color(0xFFC93C3C);
  static const dangerSoft = Color(0xFFFDECEC);
  static const blue = Color(0xFF2F6FD0);
  static const blueSoft = Color(0xFFE4EFFC);
  static const amberSoft = Color(0xFFFFF1DB);
  static const amber = Color(0xFF8A5A00);
}

const kFontFamily = 'PlusJakartaSans';

double clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

TextStyle appText(
  double size, {
  FontWeight weight = FontWeight.w500,
  Color color = AppColors.ink,
  double? height,
  double? letterSpacing,
  TextDecoration? decoration,
}) {
  return TextStyle(
    fontFamily: kFontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
    decoration: decoration,
    decorationColor: color,
  );
}

const kCardShadow = [
  BoxShadow(color: Color(0x120E4A37), blurRadius: 20, offset: Offset(0, 6)),
];

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(primary: AppColors.primary, surface: Colors.white);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: kFontFamily,
    scaffoldBackgroundColor: AppColors.bg,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.deep,
      contentTextStyle: appText(14, weight: FontWeight.w600, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
