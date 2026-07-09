import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceVariant: AppColors.surfaceContainerHighest,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLg,
        headlineLarge: AppTypography.headlineLg,
        headlineMedium: AppTypography.headlineMd,
        titleLarge: AppTypography.titleLg,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        labelLarge: AppTypography.labelMd,
        labelSmall: AppTypography.labelSm,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF93C5FD),
        onPrimary: Color(0xFF002045),
        primaryContainer: Color(0xFF1E3A8A),
        onPrimaryContainer: Color(0xFFBFDBFE),
        secondary: Color(0xFF2DD4BF),
        onSecondary: Color(0xFF115E59),
        secondaryContainer: Color(0xFF13696A),
        onSecondaryContainer: Color(0xFFCCFBF1),
        tertiary: Color(0xFFFDE047),
        onTertiary: Color(0xFF713F12),
        tertiaryContainer: Color(0xFF854D0E),
        onTertiaryContainer: Color(0xFFFEF9C3),
        error: Color(0xFFFCA5A5),
        onError: Color(0xFF7F1D1D),
        errorContainer: Color(0xFF991B1B),
        onErrorContainer: Color(0xFFFEE2E2),
        surface: Color(0xFF1E293B),
        onSurface: Color(0xFFF8FAFC),
        surfaceVariant: Color(0xFF334155),
        onSurfaceVariant: Color(0xFF94A3B8),
        outline: Color(0xFF64748B),
        outlineVariant: Color(0xFF334155),
      ),
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLg,
        headlineLarge: AppTypography.headlineLg,
        headlineMedium: AppTypography.headlineMd,
        titleLarge: AppTypography.titleLg,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        labelLarge: AppTypography.labelMd,
        labelSmall: AppTypography.labelSm,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
