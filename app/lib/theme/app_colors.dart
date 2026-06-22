import 'package:flutter/material.dart';

abstract final class AppColors {

  // verwendung 
  // color: Theme.of(context).colorScheme.primary 
  static const primary = Color(0xFF4A7C59);
  static const tertiary = Color(0xFF705C30);
  static const error = Color(0xFFB83230);

  static const lightBackground = Color(0xFFFAF6F0);
  static const lightSurface = Color(0xFFFAF6F0);
  static const lightSurfaceLow = Color(0xFFF5F1EA);
  static const lightSurfaceContainer = Color(0xFFF0ECE4);
  static const lightSurfaceHigh = Color(0xFFEAE6DE);
  static const lightText = Color(0xFF2E3230);
  static const lightTextMuted = Color(0xFF4A4E4A);
  static const lightOutline = Color(0xFF74796E);
  static const lightOutlineVariant = Color(0xFFC4C8BC);

  static const darkPrimary = Color(0xFF8ECF9E);
  static const darkBackground = Color(0xFF1C1F1D);
  static const darkSurface = Color(0xFF1C1F1D);
  static const darkSurfaceLow = Color(0xFF202320);
  static const darkSurfaceContainer = Color(0xFF252925);
  static const darkSurfaceHigh = Color(0xFF303530);
  static const darkText = Color(0xFFF5F1EA);
  static const darkTextMuted = Color(0xFFC4C8BC);
  static const darkOutline = Color(0xFF8E9388);
  static const darkOutlineVariant = Color(0xFF3F443F);

  static const success = Color(0xFF4A7C59);
  static const warning = Color(0xFF705C30);
}
