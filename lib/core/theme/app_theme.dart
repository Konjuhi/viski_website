import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    const fontFallback = <String>[
      'Avenir Next',
      'Segoe UI',
      'Helvetica Neue',
      'sans-serif',
    ];

    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF111827),
      brightness: Brightness.light,
      surface: const Color(0xFFF6F4EF),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFE9E4DA),
    );

    TextStyle style(
      double size,
      FontWeight weight, {
      double? height,
      Color? color,
      double? letterSpacing,
    }) {
      return TextStyle(
        fontSize: size,
        fontWeight: weight,
        height: height,
        color: color,
        letterSpacing: letterSpacing,
        fontFamilyFallback: fontFallback,
      );
    }

    return base.copyWith(
      textTheme: TextTheme(
        displaySmall: style(40, FontWeight.w700, height: 1.0),
        headlineLarge: style(32, FontWeight.w700, height: 1.05),
        headlineMedium: style(24, FontWeight.w700, height: 1.1),
        titleLarge: style(18, FontWeight.w700, height: 1.2),
        titleMedium: style(14, FontWeight.w700, letterSpacing: 0.5),
        bodyLarge: style(16, FontWeight.w500, height: 1.55),
        bodyMedium: style(14, FontWeight.w500, height: 1.55),
        bodySmall: style(12, FontWeight.w500, height: 1.45),
        labelLarge: style(15, FontWeight.w700, letterSpacing: 0.2),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.black, width: 1.4),
        ),
        floatingLabelStyle: style(14, FontWeight.w500, color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: style(15, FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: style(15, FontWeight.w700),
        ),
      ),
    );
  }
}
