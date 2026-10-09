import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Visual metadata for [TaskCategory] values: labels, emoji accents, icons and
/// the exact palette used by cards, chips and badges.
class CategoryVisuals {
  const CategoryVisuals({
    required this.label,
    required this.shortLabel,
    required this.emoji,
    required this.icon,
    required this.strong,
    required this.fixed,
    required this.container,
    required this.onContainer,
    required this.dot,
  });

  final String label;
  final String shortLabel;
  final String emoji;
  final IconData icon;

  /// Strong hue used for text/icons on light surfaces.
  final Color strong;

  /// Light circular fill (category tokens, avatars).
  final Color fixed;

  /// Solid background of featured cards.
  final Color container;

  /// Content color on top of [container].
  final Color onContainer;

  /// Dot color used by the timeline category filter chips.
  final Color dot;
}

/// Visual metadata for the three task statuses (home "category nodes").
class StatusVisuals {
  const StatusVisuals({
    required this.label,
    required this.icon,
    required this.fixed,
    required this.strong,
    this.filledIcon = false,
  });

  final String label;
  final IconData icon;
  final Color fixed;
  final Color strong;
  final bool filledIcon;
}

/// Resolves the palette of a timeline card for a given status.
class TimelinePalette {
  const TimelinePalette({
    required this.cardBg,
    required this.cardText,
    required this.cardFooter,
    required this.badgeBg,
    required this.badgeFg,
    required this.nodeBg,
    required this.nodeRing,
    required this.nodeRingWidth,
    required this.nodeDot,
    required this.glow,
  });

  final Color cardBg;
  final Color cardText;
  final Color cardFooter;
  final Color badgeBg;
  final Color badgeFg;
  final Color nodeBg;
  final Color nodeRing;
  final double nodeRingWidth;
  final Color nodeDot;
  final Color glow;
}

abstract final class CategoryVisualsRegistry {
  CategoryVisualsRegistry._();

  static CategoryVisuals of(String category) => switch (category) {
        'wireframe' => const CategoryVisuals(
            label: 'Wireframing & Flow',
            shortLabel: 'Wireframe',
            emoji: '📐',
            icon: Icons.architecture_rounded,
            strong: AppColors.tertiary,
            fixed: AppColors.tertiaryFixed,
            container: AppColors.tertiaryContainer,
            onContainer: AppColors.onTertiaryContainer,
            dot: AppColors.accentCoral,
          ),
        'ui' => const CategoryVisuals(
            label: 'Desain UI & Mockup',
            shortLabel: 'UI',
            emoji: '🎨',
            icon: Icons.design_services_rounded,
            strong: AppColors.primary,
            fixed: AppColors.primaryFixedDim,
            container: AppColors.primary,
            onContainer: AppColors.onPrimary,
            dot: AppColors.primaryContainer,
          ),
        'dev' => const CategoryVisuals(
            label: 'Dev & Testing',
            shortLabel: 'Dev',
            emoji: '💻',
            icon: Icons.code_rounded,
            strong: AppColors.secondary,
            fixed: AppColors.secondaryFixed,
            container: AppColors.secondaryContainer,
            onContainer: AppColors.onSecondary,
            dot: AppColors.secondary,
          ),
        _ => const CategoryVisuals(
            label: 'Meeting & Review',
            shortLabel: 'Meeting',
            emoji: '🙌',
            icon: Icons.groups_rounded,
            strong: AppColors.primary,
            fixed: AppColors.primaryFixed,
            container: AppColors.primaryContainer,
            onContainer: AppColors.onPrimaryContainer,
            dot: AppColors.primary,
          ),
      };
}

abstract final class StatusVisualsRegistry {
  StatusVisualsRegistry._();

  static const StatusVisuals todo = StatusVisuals(
    label: 'To-Do',
    icon: Icons.edit_note_rounded,
    fixed: AppColors.tertiaryFixed,
    strong: AppColors.tertiary,
  );

  static const StatusVisuals inProgress = StatusVisuals(
    label: 'Progress',
    icon: Icons.hourglass_top_rounded,
    fixed: AppColors.secondaryFixed,
    strong: AppColors.secondary,
  );

  static const StatusVisuals done = StatusVisuals(
    label: 'Selesai',
    icon: Icons.check_circle_rounded,
    fixed: AppColors.primaryFixed,
    strong: AppColors.primary,
    filledIcon: true,
  );

  static StatusVisuals of(String status) => switch (status) {
        'inProgress' => inProgress,
        'done' => done,
        _ => todo,
      };
}

/// Resolves the full card palette used by the schedule timeline.
///
/// * `done`        → soft green card (matches the mocked finished state)
/// * `inProgress`  → warm amber card
/// * `todo`        → white card, or coral when flagged as high priority
TimelinePalette timelinePalette({
  required String status,
  required bool highPriority,
}) {
  if (status == 'done') {
    return const TimelinePalette(
      cardBg: AppColors.primaryFixed,
      cardText: AppColors.onPrimaryFixed,
      cardFooter: AppColors.onPrimaryFixedVariant,
      badgeBg: AppColors.primaryContainer,
      badgeFg: AppColors.onPrimary,
      nodeBg: AppColors.primaryFixedDim,
      nodeRing: AppColors.primary,
      nodeRingWidth: 2,
      nodeDot: AppColors.primary,
      glow: AppColors.primaryFixed,
    );
  }
  if (status == 'inProgress') {
    return const TimelinePalette(
      cardBg: AppColors.secondaryFixed,
      cardText: AppColors.onSecondaryFixed,
      cardFooter: AppColors.onSecondaryFixedVariant,
      badgeBg: AppColors.secondaryContainer,
      badgeFg: AppColors.onSecondaryContainer,
      nodeBg: AppColors.secondaryFixedDim,
      nodeRing: AppColors.secondary,
      nodeRingWidth: 4,
      nodeDot: AppColors.secondary,
      glow: AppColors.secondaryFixed,
    );
  }
  if (highPriority) {
    return const TimelinePalette(
      cardBg: AppColors.tertiaryContainer,
      cardText: AppColors.onTertiaryContainer,
      cardFooter: AppColors.onTertiaryContainer,
      badgeBg: AppColors.tertiary,
      badgeFg: AppColors.onTertiary,
      nodeBg: AppColors.tertiary,
      nodeRing: AppColors.tertiaryFixed,
      nodeRingWidth: 4,
      nodeDot: AppColors.onTertiaryContainer,
      glow: AppColors.tertiaryContainer,
    );
  }
  return const TimelinePalette(
    cardBg: AppColors.surfaceContainerLowest,
    cardText: AppColors.onSurface,
    cardFooter: AppColors.onSurfaceVariant,
    badgeBg: AppColors.surfaceContainerHighest,
    badgeFg: AppColors.onSurfaceVariant,
    nodeBg: AppColors.surfaceContainerHigh,
    nodeRing: AppColors.outlineVariant,
    nodeRingWidth: 3,
    nodeDot: AppColors.outline,
    glow: AppColors.surfaceContainerHighest,
  );
}