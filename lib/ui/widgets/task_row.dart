import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/category_visuals.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/task.dart';
import 'animated_check.dart';
import 'animated_strike_text.dart';

/// Priority-list row from the home screen: animated checkbox, growing
/// strike-through, category badge and estimate.
class TaskRow extends StatelessWidget {
  const TaskRow({
    super.key,
    required this.task,
    required this.onToggle,
    this.onTap,
    this.onMore,
    this.index = 0,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onMore;
  final int index;

  @override
  Widget build(BuildContext context) {
    final CategoryVisuals visuals =
        CategoryVisualsRegistry.of(task.category.visualsKey);
    final bool done = task.isDone;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + (index.clamp(0, 6) * 45)),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double t, Widget? child) {
        return Opacity(
          opacity: t,
          child:
              Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
        );
      },
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedCheck(
                  isChecked: done,
                  size: 26,
                  uncheckedBg: visuals.fixed,
                  uncheckedFg: visuals.strong,
                  confettiColors: <Color>[
                    visuals.strong,
                    AppColors.secondary,
                    AppColors.primary,
                    visuals.fixed,
                  ],
                  onTap: onToggle,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: AnimatedStrikeText(
                              text: task.title,
                              struck: done,
                              style: AppTypography.labelLg.copyWith(
                                fontWeight: FontWeight.w700,
                                color: done
                                    ? AppColors.onSurface
                                        .withValues(alpha: 0.55)
                                    : AppColors.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Formatters.time(task.time),
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.outline,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: visuals.fixed,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              task.tag ?? visuals.shortLabel,
                              style: AppTypography.labelSm.copyWith(
                                color: visuals.strong,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Formatters.estimate(task.estimateMinutes),
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.outline,
                            ),
                          ),
                          const Spacer(),
                          if (onMore != null)
                            GestureDetector(
                              onTap: onMore,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.more_horiz_rounded,
                                  size: 20,
                                  color: AppColors.outline,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}