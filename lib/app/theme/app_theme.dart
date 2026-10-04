import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData withAccessibility({
    required bool highContrast,
    required bool reduceMotion,
  }) {
    final theme = light;
    return theme.copyWith(
      colorScheme: highContrast
          ? ColorScheme.highContrastLight(
              primary: AppColors.sinopia,
              secondary: AppColors.jet,
            )
          : theme.colorScheme,
      pageTransitionsTheme: reduceMotion
          ? PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: _NoMotionTransitions(),
              },
            )
          : theme.pageTransitionsTheme,
    );
  }

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.sinopia,
      brightness: Brightness.light,
      primary: AppColors.sinopia,
      secondary: AppColors.fulvous,
      tertiary: AppColors.greenPigment,
      surface: Colors.white,
      error: AppColors.sinopia,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.isabelline,
      textTheme: AppTypography.textTheme(AppColors.jet),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.jet,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5DED7)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.greenPigment,
        foregroundColor: AppColors.jet,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.jet,
        indicatorColor: AppColors.fulvous.withValues(alpha: 0.25),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.fulvous
                : const Color(0xFFB8C0CC),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? AppColors.fulvous
                : const Color(0xFFB8C0CC),
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _NoMotionTransitions extends PageTransitionsBuilder {
  const _NoMotionTransitions();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
