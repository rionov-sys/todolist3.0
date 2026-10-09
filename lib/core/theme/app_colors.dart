import 'package:flutter/material.dart';

/// Design tokens extracted from `design/keepgrinding_modern_task_system/DESIGN.md`.
///
/// Keeping every palette value in one place guarantees the Flutter UI stays
/// pixel-faithful to the HTML mocks.
abstract final class AppColors {
  AppColors._();

  // --- Surfaces -------------------------------------------------------
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceDim = Color(0xFFCFDAF2);
  static const Color surfaceBright = Color(0xFFF9F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F3FF);
  static const Color surfaceContainer = Color(0xFFE7EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDEE8FF);
  static const Color surfaceContainerHighest = Color(0xFFD8E3FB);

  // --- On-surface content --------------------------------------------
  static const Color onSurface = Color(0xFF111C2D);
  static const Color onSurfaceVariant = Color(0xFF43493D);
  static const Color outline = Color(0xFF74796B);
  static const Color outlineVariant = Color(0xFFC3C8B9);

  // --- Inverse --------------------------------------------------------
  static const Color inverseSurface = Color(0xFF263143);
  static const Color inverseOnSurface = Color(0xFFECF1FF);
  static const Color inversePrimary = Color(0xFFABD286);

  // --- Primary (forest green) ----------------------------------------
  static const Color primary = Color(0xFF436526);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF5B7E3C);
  static const Color onPrimaryContainer = Color(0xFFF7FFE8);
  static const Color primaryFixed = Color(0xFFC6EFA0);
  static const Color primaryFixedDim = Color(0xFFABD286);
  static const Color onPrimaryFixed = Color(0xFF0D2000);
  static const Color onPrimaryFixedVariant = Color(0xFF2F4F12);
  static const Color surfaceTint = Color(0xFF466728);

  // --- Secondary (amber) ---------------------------------------------
  static const Color secondary = Color(0xFF8B5000);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFE9C22);
  static const Color onSecondaryContainer = Color(0xFF673B00);
  static const Color secondaryFixed = Color(0xFFFFDCBE);
  static const Color secondaryFixedDim = Color(0xFFFFB870);
  static const Color onSecondaryFixed = Color(0xFF2C1600);
  static const Color onSecondaryFixedVariant = Color(0xFF693C00);

  // --- Tertiary (coral) ----------------------------------------------
  static const Color tertiary = Color(0xFFAE262C);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFD03F41);
  static const Color onTertiaryContainer = Color(0xFFFFFAF9);
  static const Color tertiaryFixed = Color(0xFFFFDAD7);
  static const Color tertiaryFixedDim = Color(0xFFFFB3AF);
  static const Color onTertiaryFixed = Color(0xFF410005);
  static const Color onTertiaryFixedVariant = Color(0xFF900B1A);

  // --- Error ----------------------------------------------------------
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // --- Component accents (from the component specs) -------------------
  static const Color accentCoral = Color(0xFFEA5252);
  static const Color accentAmber = Color(0xFFFF9D23);
}

/// Elevation tokens: soft, diffused ambient light — never muddy drop shadows.
abstract final class AppShadows {
  AppShadows._();

  /// `0 10px 25px -5px rgba(30,41,59,0.05), 0 4px 6px -2px rgba(30,41,59,0.02)`
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D1E293B),
      blurRadius: 25,
      offset: Offset(0, 10),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x051E293B),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  /// Ambient shadow for pills, chips and small elevated surfaces.
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(color: Color(0x0A1E293B), blurRadius: 16, offset: Offset(0, 4)),
  ];

  /// Upward shadow of the fixed bottom navigation bar.
  static const List<BoxShadow> nav = <BoxShadow>[
    BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, -4)),
  ];

  /// Tinted glow used behind active/highlighted cards.
  static List<BoxShadow> colored(Color color, {double alpha = 0.28}) =>
      <BoxShadow>[
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: 24,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
      ];
}

/// Radius scale — pill-centric geometry (Level 3).
abstract final class AppRadii {
  AppRadii._();

  static const double xs = 8;
  static const double sm = 8;
  static const double md = 16;
  static const double task = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 999;
}

/// Spacing scale from the design system.
abstract final class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double gutter = 16;
  static const double margin = 20;

  /// Design targets 360–430 px phones; wider viewports get a centered column.
  static const double contentMaxWidth = 640;
}