import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: 'Inter',
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      secondary: AppColors.primaryContainer,
      secondaryContainer: AppColors.secondaryContainer,
      tertiary: AppColors.tertiaryFixedDim,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
      outline: AppColors.outlineLight,
      outlineVariant: AppColors.outlineVariantLight,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.onSurfaceLight,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceContainerLight),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    fontFamily: 'Inter',

    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 243, 250, 248),
      onPrimary: Color.fromARGB(255, 243, 250, 248),
      primaryContainer: Color.fromARGB(255, 167, 192, 186),
      onPrimaryContainer: Color.fromARGB(255, 243, 250, 248),

      secondary: AppColors.onSurfaceVariantDark,

      secondaryContainer: AppColors.surfaceContainerHighDark,

      tertiary: AppColors.tertiaryFixedDim,

      surface: AppColors.surfaceDark,

      onSurface: AppColors.onSurfaceDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,

      outline: AppColors.outlineDark,
      outlineVariant: AppColors.outlineVariantDark,

      error: AppColors.error,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.onSurfaceDark,
    ),

    cardTheme: CardThemeData(
      color: AppColors.surfaceContainerDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outlineVariantDark),
      ),
    ),
  );
}
