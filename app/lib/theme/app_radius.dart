import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const pill = 999.0;

  static final card = BorderRadius.circular(md);
  static final button = BorderRadius.circular(md);
  static final input = BorderRadius.circular(md);
  static final dialog = BorderRadius.circular(xl);
}
