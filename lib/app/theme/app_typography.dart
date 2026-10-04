import 'package:flutter/material.dart';

abstract final class AppTypography {
  static TextTheme textTheme(Color color) => TextTheme(
    displaySmall: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -0.5,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: color,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: color,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: color),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: color),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: color,
    ),
  );
}
