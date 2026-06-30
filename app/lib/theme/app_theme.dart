import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF14422D),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF2D5A43),
    onPrimaryContainer: Color(0xFFFFFFFF),
    secondary: Color(0xFF075FAB),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF70AEFF),
    onSecondaryContainer: Color(0xFF001C3A),
    tertiary: Color(0xFF313D35),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF48544B),
    onTertiaryContainer: Color(0xFFFFFFFF),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFBF9F8),
    onSurface: Color(0xFF1B1B1B),
    onSurfaceVariant: Color(0xFF44493E),
    outline: Color(0xFF717973),
    outlineVariant: Color(0xFFC0C9C1),
    inverseSurface: Color(0xFF2B2B2B),
    inversePrimary: Color(0xFFA1D1B4),
    surfaceTint: Color(0xFF3A674F),
  );

  final textTheme = _buildTextTheme();

  return _buildThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: colorScheme.onPrimary,
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF6BB88A),
    onPrimary: Color(0xFF003921),
    primaryContainer: Color(0xFF003921),
    onPrimaryContainer: Color(0xFFCEEED8),
    secondary: Color(0xFF8EB9FF),
    onSecondary: Color(0xFF003258),
    secondaryContainer: Color(0xFF004880),
    onSecondaryContainer: Color(0xFFD3E4FF),
    tertiary: Color(0xFF8D9A91),
    onTertiary: Color(0xFF1B2C20),
    tertiaryContainer: Color(0xFF314236),
    onTertiaryContainer: Color(0xFFDAE9D8),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE4E2E0),
    onSurfaceVariant: Color(0xFFC0C9C1),
    outline: Color(0xFF8A938B),
    outlineVariant: Color(0xFF41483E),
    inverseSurface: Color(0xFFE4E2E0),
    inversePrimary: Color(0xFF14422D),
    surfaceTint: Color(0xFF6BB88A),
  );

  final textTheme = _buildTextTheme();

  return _buildThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
      ),
    ),
  );
}

ThemeData _buildThemeData({
  required ColorScheme colorScheme,
  required TextTheme textTheme,
  required AppBarTheme appBarTheme,
}) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: textTheme,
    appBarTheme: appBarTheme,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primary;
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colorScheme.primaryContainer;
        return colorScheme.surfaceContainerHighest;
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

TextTheme _buildTextTheme() {
  return TextTheme(
    headlineLarge: GoogleFonts.manrope(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02,
      height: 1.2,
    ),
    headlineMedium: GoogleFonts.manrope(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    headlineSmall: GoogleFonts.manrope(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    bodyLarge: GoogleFonts.beVietnamPro(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.beVietnamPro(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.beVietnamPro(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    labelMedium: GoogleFonts.beVietnamPro(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.01,
      height: 1.2,
    ),
    labelSmall: GoogleFonts.beVietnamPro(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.2,
    ),
  );
}
