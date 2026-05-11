import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF4A7C59);
  static const Color background = Color(0xFFFAF6F0);
  static const Color tertiary = Color(0xFF705C30);
  static const double buttonRadius = 12;

  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      surface: background,
      tertiary: tertiary,
    );
    final textTheme = _textTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.literata(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
          letterSpacing: -0.2,
        ),
      ),

/*### BUTTON THEMES ###*/
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: background,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: _buttonTextStyle(colorScheme.onPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: _buttonTextStyle(colorScheme.onPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: BorderSide(color: colorScheme.outline),
          textStyle: _buttonTextStyle(colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: _buttonTextStyle(colorScheme.primary, size: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: _headline(57, FontWeight.w800, colorScheme.onSurface, height: 1.08),
      displayMedium: _headline(45, FontWeight.w800, colorScheme.onSurface, height: 1.12),
      displaySmall: _headline(36, FontWeight.w700, colorScheme.onSurface, height: 1.18),
      headlineLarge: _headline(32, FontWeight.w700, colorScheme.onSurface),
      headlineMedium: _headline(28, FontWeight.w700, colorScheme.onSurface),
      headlineSmall: _headline(24, FontWeight.w700, colorScheme.onSurface),
      titleLarge: _headline(22, FontWeight.w700, colorScheme.onSurface, height: 1.3),
      titleMedium: _body(16, FontWeight.w800, colorScheme.onSurface, height: 1.35),
      titleSmall: _body(14, FontWeight.w800, colorScheme.onSurface, height: 1.35),
      bodyLarge: _body(16, FontWeight.w400, colorScheme.onSurface, height: 1.65),
      bodyMedium: _body(14, FontWeight.w400, colorScheme.onSurface, height: 1.6),
      bodySmall: _body(12, FontWeight.w400, colorScheme.onSurfaceVariant, height: 1.55),
      labelLarge: _body(14, FontWeight.w800, colorScheme.onSurface, height: 1.25),
      labelMedium: _body(12, FontWeight.w700, colorScheme.onSurfaceVariant, height: 1.25),
      labelSmall: _body(11, FontWeight.w700, colorScheme.onSurfaceVariant, height: 1.25),
    );
  }

  static TextStyle _headline(
    double size,
    FontWeight weight,
    Color color, {
    double height = 1.25,
  }) {
    return GoogleFonts.literata(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: -0.3,
    );
  }

  static TextStyle _body(
    double size,
    FontWeight weight,
    Color color, {
    double height = 1.6,
  }) {
    return GoogleFonts.nunitoSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  static TextStyle _buttonTextStyle(
    Color color, {
    double size = 16,
  }) {
    return GoogleFonts.nunitoSans(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.25,
    );
  }
}
