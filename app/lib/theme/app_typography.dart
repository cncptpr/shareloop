import 'package:flutter/material.dart';

//Beispiel
// Text(
// 'gestylter text',
//  style: Theme.of(context).textTheme.headlineLarge,
//);

abstract final class AppTypography {
  static const headlineFont = 'Literata'; // Überschriften
  static const bodyFont = 'Nunito Sans'; // normale Texte

  static TextTheme textTheme(ColorScheme colors) => TextTheme(
        displayLarge: _headline(57, FontWeight.w800, colors.onSurface, 1.08),
        displayMedium: _headline(45, FontWeight.w800, colors.onSurface, 1.12),
        displaySmall: _headline(36, FontWeight.w700, colors.onSurface, 1.18),
        headlineLarge: _headline(32, FontWeight.w700, colors.onSurface, 1.25),
        headlineMedium: _headline(28, FontWeight.w700, colors.onSurface, 1.25),
        headlineSmall: _headline(24, FontWeight.w700, colors.onSurface, 1.25),
        titleLarge: _headline(22, FontWeight.w700, colors.onSurface, 1.30),
        titleMedium: _body(16, FontWeight.w800, colors.onSurface, 1.35),
        titleSmall: _body(14, FontWeight.w800, colors.onSurface, 1.35),
        bodyLarge: _body(16, FontWeight.w400, colors.onSurface, 1.65),
        bodyMedium: _body(14, FontWeight.w400, colors.onSurface, 1.60),
        bodySmall: _body(12, FontWeight.w400, colors.onSurfaceVariant, 1.55),
        labelLarge: _body(14, FontWeight.w800, colors.onSurface, 1.25),
        labelMedium: _body(12, FontWeight.w700, colors.onSurfaceVariant, 1.25),
        labelSmall: _body(11, FontWeight.w700, colors.onSurfaceVariant, 1.25),
      );

  static TextStyle _headline(
    double size,
    FontWeight weight,
    Color color,
    double height,
  ) =>
      TextStyle(
        fontFamily: headlineFont,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: -0.3,
      );

  static TextStyle _body(
    double size,
    FontWeight weight,
    Color color,
    double height,
  ) =>
      TextStyle(
        fontFamily: bodyFont,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
}
