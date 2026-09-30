import 'package:flutter/material.dart';

/// WARM_EARTHY preset, hex values overridden by the MealCanvas brief.
/// preset name: 'WARM_EARTHY'
class AppColors {
  const AppColors._();

  static const Color paper = Color(0xFFFFF8F1);
  static const Color paperAlt = Color(0xFFF2EAD8);
  static const Color primary = Color(0xFFE07A5F);
  static const Color primaryDark = Color(0xFFC9603F);
  static const Color accent = Color(0xFF81B29A);
  static const Color accentDark = Color(0xFF6C9480);
  static const Color sand = Color(0xFFF2CC8F);
  static const Color sandDark = Color(0xFFB8893F);
  static const Color ink = Color(0xFF3D405B);

  static const Color loaderTop = Color(0xFF2A2C3D);
  static const Color loaderMid = Color(0xFF3D405B);
  static const Color loaderBottom = Color(0xFF4A3B36);

  static Color inkAt(double alpha) => ink.withValues(alpha: alpha);
  static Color hairline = ink.withValues(alpha: 0.12);
}

class AppTheme {
  const AppTheme._();

  static const String presetName = 'WARM_EARTHY';
  static const String styleName = 'EDITORIAL_MAGAZINE';

  static const List<FontFeature> tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static ThemeData build() {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.paper,
          secondary: AppColors.accent,
          onSecondary: AppColors.paper,
          tertiary: AppColors.sand,
          surface: AppColors.paper,
          onSurface: AppColors.ink,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
      splashFactory: InkRipple.splashFactory,
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 46,
          fontWeight: FontWeight.w300,
          letterSpacing: 3.0,
          height: 0.98,
          color: AppColors.ink,
        ),
        displayMedium: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w300,
          letterSpacing: 6.0,
          color: AppColors.paper,
        ),
        headlineMedium: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w300,
          letterSpacing: 3.0,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.4,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.ink,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.8,
          height: 24 / 16,
          color: AppColors.paper,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
          color: AppColors.ink,
        ),
      ),
    );
  }

  /// Small uppercase eyebrow label used across screens.
  static TextStyle eyebrow({
    double size = 10,
    double spacing = 2.4,
    Color color = AppColors.ink,
    FontWeight weight = FontWeight.w700,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: spacing,
      color: color,
    );
  }
}
