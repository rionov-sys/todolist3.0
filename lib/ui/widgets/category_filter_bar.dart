import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/category_visuals.dart';
import '../../data/models/task.dart';

/// Horizontally scrollable category chips with live counts
/// ("Semua • Wireframe • UI • Dev").
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.counts,
    required this.selected,
    required this.onSelected,
  });

  final Map<TaskCategory, int> counts;
  final TaskCategory? selected;
  final ValueChanged<TaskCategory?> onSelected;

  int get _allCount =>
      counts.values.fold<int>(0, (int sum, int c) => sum + c);

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = <Widget>[
      _CategoryChip(
        label: 'Semua',
        count: _allCount,
        icon: Icons.apps_rounded,
        active: selected == null,
        onTap: () => onSelected(null),
      ),
      for (final TaskCategory category in TaskCategory.values)
        if ((counts[category] ?? 0) > 0 || selected == category)
          _CategoryChip(
            label: CategoryVisualsRegistry.of(category.visualsKey).shortLabel,
            count: counts[category] ?? 0,
            dot: CategoryVisualsRegistry.of(category.visualsKey).dot,
            active: selected == category,
            onTap: () => onSelected(
              selected == category ? null : category,
            ),
          ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(children: chips),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    this.icon,
    this.dot,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: active
              ? null
              : Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
          boxShadow: active
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null)
              Icon(
                icon,
                size: 15,
                color: active
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
              )
            else if (dot != null)
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: active
                    ? AppColors.onPrimary
                    : AppColors.onSurfaceVariant,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              constraints: const BoxConstraints(minWidth: 17),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.onPrimary.withValues(alpha: 0.22)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: AppTypography.labelSm.copyWith(
                  color: active
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}