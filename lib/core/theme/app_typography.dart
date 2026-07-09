import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 56 / 48,
    letterSpacing: -0.02 * 48,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.01 * 32,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.01 * 14,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
  );

  static const TextStyle headlineMedium = headlineMd;
  static const TextStyle titleLarge = titleLg;
  static const TextStyle bodyMedium = bodyMd;
}
