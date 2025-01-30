// lib/themes/app_themes.dart
import 'package:flutter/material.dart';

/// Definition of AppThemes with predefined themes.
class AppThemes {
  static final Map<String, ColorScheme> themes = {
    'light': ColorScheme.light(
      primary: Colors.blue,
      onPrimary: Colors.white,
      secondary: Colors.blueAccent,
      background: Colors.white,
      surface: Colors.grey[100]!,
      onSurface: Colors.black,
    ),
    'dark': ColorScheme.dark(
      primary: Colors.teal,
      onPrimary: Colors.black,
      secondary: Colors.tealAccent,
      background: Colors.black,
      surface: Colors.grey[800]!,
      onSurface: Colors.white,
    ),
    // Add more themes as needed
  };
}
