import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Apertix design token palette.
abstract final class ApertixColors {
  // Primary — Electric Violet
  static const primary = Color(0xFF6C5CE7);
  static const primaryLight = Color(0xFFA29BFE);

  // Secondary — Mint
  static const secondary = Color(0xFF00B894);
  static const secondaryLight = Color(0xFF55EFC4);

  // Accent — Rose
  static const accent = Color(0xFFFD79A8);

  // Dark surface palette
  static const darkBackground = Color(0xFF0D0D0D);
  static const darkSurface = Color(0xFF1A1A2E);
  static const darkBorder = Color(0xFF2D2D44);
  static const darkTextPrimary = Color(0xFFF5F6FA);
  static const darkTextSecondary = Color(0xFFB2BEC3);

  // Light surface palette
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFDFE6E9);
  static const lightTextPrimary = Color(0xFF2D3436);
  static const lightTextSecondary = Color(0xFF636E72);

  // Status
  static const success = Color(0xFF00B894);
  static const error = Color(0xFFFF7675);
  static const warning = Color(0xFFFDCB6E);
  static const info = Color(0xFF74B9FF);
}

/// Apertix Material 3 theme factory.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: ApertixColors.primary,
      onPrimary: Colors.white,
      primaryContainer:
          isDark ? const Color(0xFF3D2F9E) : const Color(0xFFEDE9FF),
      onPrimaryContainer:
          isDark ? ApertixColors.primaryLight : ApertixColors.primary,
      secondary: ApertixColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer:
          isDark ? const Color(0xFF006652) : const Color(0xFFD9F8EF),
      onSecondaryContainer:
          isDark ? ApertixColors.secondaryLight : ApertixColors.secondary,
      error: ApertixColors.error,
      onError: Colors.white,
      errorContainer:
          isDark ? const Color(0xFF7A2020) : const Color(0xFFFFE0E0),
      onErrorContainer: isDark ? const Color(0xFFFFB3B3) : ApertixColors.error,
      surface:
          isDark ? ApertixColors.darkSurface : ApertixColors.lightSurface,
      onSurface:
          isDark ? ApertixColors.darkTextPrimary : ApertixColors.lightTextPrimary,
      onSurfaceVariant: isDark
          ? ApertixColors.darkTextSecondary
          : ApertixColors.lightTextSecondary,
      surfaceContainerHighest:
          isDark ? const Color(0xFF252545) : const Color(0xFFF0EEF8),
      outline: isDark ? ApertixColors.darkBorder : ApertixColors.lightBorder,
      shadow: Colors.black,
      inverseSurface:
          isDark ? ApertixColors.lightSurface : ApertixColors.darkSurface,
      onInverseSurface: isDark
          ? ApertixColors.lightTextPrimary
          : ApertixColors.darkTextPrimary,
    );

    final textTheme = GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colorScheme.primary,
          letterSpacing: 0.1,
        ),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor:
          isDark ? ApertixColors.darkBackground : ApertixColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? ApertixColors.darkSurface : ApertixColors.lightSurface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 20,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3A3A5C) : const Color(0xFF2D3436),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        waitDuration: const Duration(milliseconds: 600),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        trackHeight: 3,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? const Color(0xFF3A3A5C) : ApertixColors.darkSurface,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
