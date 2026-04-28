import 'package:flutter/material.dart';

class AppTheme {

  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: Color (0x00f2c069),
    useMaterial3: true,
  );
}