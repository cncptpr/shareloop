import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TerraColors {
  TerraColors._();

  static const primary = Color(0xFF4a7c59);
  static const background = Color(0xFFfaf6f0);
  static const tertiary = Color(0xFF705c30);
  static const onSurface = Color(0xFF2E322E);
  static const error = Color(0xFFB33A3A);
}

ThemeData terraTheme() {
  final colorScheme = ColorScheme.light(
    primary: TerraColors.primary,
    onPrimary: Colors.white,
    primaryContainer: TerraColors.primary.withValues(alpha: 0.15),
    onPrimaryContainer: TerraColors.primary,
    secondary: TerraColors.tertiary,
    onSecondary: Colors.white,
    tertiary: TerraColors.tertiary,
    surface: TerraColors.background,
    onSurface: TerraColors.onSurface,
    error: TerraColors.error,
    onError: Colors.white,
    outline: TerraColors.onSurface.withValues(alpha: 0.12),
    outlineVariant: TerraColors.onSurface.withValues(alpha: 0.06),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: TerraColors.background,
    textTheme: _buildTextTheme(),
    cardTheme: const CardThemeData(
      color: TerraColors.background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TerraColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: TerraColors.primary,
        side: const BorderSide(color: TerraColors.primary),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TerraColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: TerraColors.onSurface.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: TerraColors.onSurface.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TerraColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TerraColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TerraColors.error, width: 2),
      ),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: TerraColors.onSurface.withValues(alpha: 0.06),
      thickness: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: TerraColors.background,
      elevation: 0,
      indicatorColor: TerraColors.primary.withValues(alpha: 0.15),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    ),
  );
}

TextTheme _buildTextTheme() {
  final nunito = GoogleFonts.nunitoSansTextTheme();
  return nunito.copyWith(
    displayLarge: GoogleFonts.literata(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: TerraColors.onSurface,
    ),
    displayMedium: GoogleFonts.literata(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: TerraColors.onSurface,
    ),
    displaySmall: GoogleFonts.literata(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: TerraColors.onSurface,
    ),
    headlineLarge: GoogleFonts.literata(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: TerraColors.onSurface,
    ),
    headlineMedium: GoogleFonts.literata(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: TerraColors.onSurface,
    ),
    headlineSmall: GoogleFonts.literata(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TerraColors.onSurface,
    ),
    titleLarge: GoogleFonts.nunitoSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: TerraColors.onSurface,
    ),
    titleMedium: GoogleFonts.nunitoSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: TerraColors.onSurface,
    ),
    titleSmall: GoogleFonts.nunitoSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: TerraColors.onSurface,
    ),
    bodyLarge: GoogleFonts.nunitoSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: TerraColors.onSurface,
    ),
    bodyMedium: GoogleFonts.nunitoSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: TerraColors.onSurface,
    ),
    bodySmall: GoogleFonts.nunitoSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: TerraColors.onSurface,
    ),
    labelLarge: GoogleFonts.nunitoSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: TerraColors.onSurface,
    ),
    labelMedium: GoogleFonts.nunitoSans(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: TerraColors.onSurface,
    ),
    labelSmall: GoogleFonts.nunitoSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: TerraColors.onSurface,
    ),
  );
}
