import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/category_visuals.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/task.dart';
import 'animated_check.dart';

/// One entry of the schedule timeline: status-tinted card attached to the
/// vertical connector rail, with pop-in entrance animation.
class TimelineTile extends StatelessWidget {
  const TimelineTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onMore,
    this.index = 0,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onMore;
  final int index;

  IconData? _metaIcon(String meta) {
    final String m = meta.toLowerCase();
    if (m.contains('meet') || m.contains('zoom') || m.contains('room')) {
      return Icons.videocam_rounded;
    }
    if (m.contains('prototype') || m.contains('figma') || m.contains('link')) {
      return Icons.link_rounded;
    }
    if (m.contains('notion') || m.contains('dicatat') || m.contains('qa')) {
      return Icons.done_all_rounded;
    }
    return Icons.label_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final CategoryVisuals visuals =
        CategoryVisualsRegistry.of(task.category.visualsKey);
    final bool done = task.isDone;
    final TimelinePalette palette = timelinePalette(
      status: task.status.name,
      highPriority: task.highPriority,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index.clamp(0, 8) * 55)),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double t, Widget? child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- Status node on the rail -----------------------------
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: palette.nodeBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: palette.nodeRing,
                  width: palette.nodeRingWidth,
                ),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: palette.nodeDot,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // --- Card ------------------------------------------------
          Expanded(
            child: Opacity(
              opacity: done ? 0.78 : 1,
              child: Material(
                color: palette.cardBg,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                child: InkWell(
                  onTap: onMore,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.headlineSm.copyWith(
                                  fontSize: 16.5,
                                  color: palette.cardText,
                                  decoration: done
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: palette.cardText,
                                  decorationThickness: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              visuals.icon,
                              size: 16,
                              color: palette.cardFooter,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: palette.badgeBg,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                Formatters.time(task.time),
                                style: AppTypography.labelMd.copyWith(
                                  color: palette.badgeFg,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMd.copyWith(
                            color: palette.cardFooter,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            AnimatedCheck(
                              isChecked: done,
                              size: 24,
                              iconSize: 15,
                              uncheckedBg:
                                  palette.cardBg == AppColors.surfaceContainerLowest
                                      ? AppColors.surfaceContainerHigh
                                      : palette.cardText
                                          .withValues(alpha: 0.15),
                              uncheckedFg: palette.cardText,
                              checkedBg: AppColors.primary,
                              checkedFg: AppColors.onPrimary,
                              onTap: onToggle,
                            ),
                            const SizedBox(width: 8),
                            if (task.meta != null) ...<Widget>[
                              Icon(
                                _metaIcon(task.meta!),
                                size: 13,
                                color: palette.cardFooter,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  task.meta!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.labelSm.copyWith(
                                    color: palette.cardFooter,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ] else
                              Expanded(
                                child: Text(
                                  Formatters.estimate(task.estimateMinutes),
                                  style: AppTypography.labelSm.copyWith(
                                    color: palette.cardFooter,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: onMore,
                              child: Icon(
                                Icons.more_horiz_rounded,
                                size: 18,
                                color: palette.cardFooter,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}