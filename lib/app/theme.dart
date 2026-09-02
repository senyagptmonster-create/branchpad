import 'package:flutter/material.dart';

import 'brand.dart';

/// Единственный вход в оформление. Цвета берутся из brand.dart, чтобы
/// палитра не расползалась по виджетам.
class AppTheme {
  static const Color textPrimary = cInk;
  static Color get textSecondary => Color.alphaBlend(
        cInk.withValues(alpha: 0.62),
        cBg,
      );
  static Color get textMuted => Color.alphaBlend(
        cInk.withValues(alpha: 0.38),
        cBg,
      );

  static ThemeData build() {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: cBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cAccent,
        brightness: Brightness.light,
        surface: cSurface,
        primary: cAccent,
        secondary: cAccent2,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: cEdge,
    );
  }

  static TextStyle display(double size, {Color? color, FontWeight weight = FontWeight.w700}) {
    return TextStyle(
      fontFamily: kFont,
      fontSize: size,
      height: 1.12,
      letterSpacing: -0.3,
      fontWeight: weight,
      color: color ?? textPrimary,
    );
  }

  static TextStyle text(double size, {Color? color, FontWeight weight = FontWeight.w500, double spacing = 0}) {
    return TextStyle(
      fontFamily: kFont,
      fontSize: size,
      height: 1.36,
      letterSpacing: spacing,
      fontWeight: weight,
      color: color ?? textSecondary,
    );
  }
}