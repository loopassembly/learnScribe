// lib/themes/text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Definition of AccessibleTextStyles for dynamic text styling.
class AccessibleTextStyles {
  /// Returns a title large TextStyle considering accessibility settings.
  static TextStyle titleLarge(BuildContext context, bool largeText, bool dyslexicFont) {
    double fontSize = largeText ? 24 : 20;
    String fontFamily = dyslexicFont ? 'OpenDyslexic' : GoogleFonts.inter().fontFamily ?? 'Inter';

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
      color: Theme.of(context).colorScheme.onBackground,
    );
  }

  /// Returns a body TextStyle considering accessibility settings.
  static TextStyle bodyText(BuildContext context, bool largeText, bool dyslexicFont) {
    double fontSize = largeText ? 18 : 14;
    String fontFamily = dyslexicFont ? 'OpenDyslexic' : GoogleFonts.inter().fontFamily ?? 'Inter';

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamily,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  // Add more text styles as needed
}
