// lib/themes/custom_theme_extension.dart
import 'package:flutter/material.dart';

/// Custom Theme Extension to add additional theming options.
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color cardColor;
  final Color buttonColor;

  CustomThemeExtension({
    required this.cardColor,
    required this.buttonColor,
  });

  @override
  CustomThemeExtension copyWith({Color? cardColor, Color? buttonColor}) {
    return CustomThemeExtension(
      cardColor: cardColor ?? this.cardColor,
      buttonColor: buttonColor ?? this.buttonColor,
    );
  }

  @override
  CustomThemeExtension lerp(ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t)!,
    );
  }
}
