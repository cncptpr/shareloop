import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF14422D),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF2D5A43),
    onPrimaryContainer: Color(0xFFFFFFFF),
    primaryFixed: Color(0xFFBCEECF),
    primaryFixedDim: Color(0xFFA1D1B4),
    onPrimaryFixed: Color(0xFF002112),
    onPrimaryFixedVariant: Color(0xFF224F39),
    secondary: Color(0xFF075FAB),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF70AEFF),
    onSecondaryContainer: Color(0xFF001C3A),
    secondaryFixed: Color(0xFFD4E3FF),
    secondaryFixedDim: Color(0xFFA4C9FF),
    onSecondaryFixed: Color(0xFF001C39),
    onSecondaryFixedVariant: Color(0xFF004884),
    tertiary: Color(0xFF313D35),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF48544B),
    onTertiaryContainer: Color(0xFFFFFFFF),
    tertiaryFixed: Color(0xFFD9E6DA),
    tertiaryFixedDim: Color(0xFFBDCABE),
    onTertiaryFixed: Color(0xFF131E17),
    onTertiaryFixedVariant: Color(0xFF3E4A41),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFFBF9F8),
    onSurface: Color(0xFF1B1B1B),
    surfaceDim: Color(0xFFDBD9D9),
    surfaceBright: Color(0xFFFBF9F8),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF5F3F3),
    surfaceContainer: Color(0xFFEFEDED),
    surfaceContainerHigh: Color(0xFFEAE8E7),
    surfaceContainerHighest: Color(0xFFE4E2E2),
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
    primaryFixed: Color(0xFFBCEECF),
    primaryFixedDim: Color(0xFFA1D1B4),
    onPrimaryFixed: Color(0xFF002112),
    onPrimaryFixedVariant: Color(0xFF224F39),
    secondary: Color(0xFF8EB9FF),
    onSecondary: Color(0xFF003258),
    secondaryContainer: Color(0xFF004880),
    onSecondaryContainer: Color(0xFFD3E4FF),
    secondaryFixed: Color(0xFFD4E3FF),
    secondaryFixedDim: Color(0xFFA4C9FF),
    onSecondaryFixed: Color(0xFF001C39),
    onSecondaryFixedVariant: Color(0xFF004884),
    tertiary: Color(0xFF8D9A91),
    onTertiary: Color(0xFF1B2C20),
    tertiaryContainer: Color(0xFF314236),
    onTertiaryContainer: Color(0xFFDAE9D8),
    tertiaryFixed: Color(0xFFD9E6DA),
    tertiaryFixedDim: Color(0xFFBDCABE),
    onTertiaryFixed: Color(0xFF131E17),
    onTertiaryFixedVariant: Color(0xFF3E4A41),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE4E2E0),
    surfaceDim: Color(0xFF0A0A0A),
    surfaceBright: Color(0xFF383838),
    surfaceContainerLowest: Color(0xFF0D0D0D),
    surfaceContainerLow: Color(0xFF1A1A1A),
    surfaceContainer: Color(0xFF1E1E1E),
    surfaceContainerHigh: Color(0xFF282828),
    surfaceContainerHighest: Color(0xFF333333),
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
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide(color: colorScheme.outlineVariant),
      backgroundColor: colorScheme.surface,
      labelStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary),
      ),
      filled: true,
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return colorScheme.surfaceContainerHigh;
        }
        return colorScheme.surfaceContainerLow;
      }),
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
    headlineLarge: GoogleFonts.literata(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.02,
      height: 1.2,
    ),
    headlineMedium: GoogleFonts.literata(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    headlineSmall: GoogleFonts.literata(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    titleLarge: GoogleFonts.literata(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),
    titleMedium: GoogleFonts.literata(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleSmall: GoogleFonts.literata(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: GoogleFonts.nunitoSans(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.nunitoSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodySmall: GoogleFonts.nunitoSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    labelMedium: GoogleFonts.nunitoSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.01,
      height: 1.2,
    ),
    labelSmall: GoogleFonts.nunitoSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.2,
    ),
  );
}
