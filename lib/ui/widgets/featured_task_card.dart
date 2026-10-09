import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/category_visuals.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/task.dart';
import 'animated_check.dart';
import 'animated_strike_text.dart';

const List<double> _identityMatrix = <double>[
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0,
];

List<double> _saturationMatrix(double s) {
  final double inv = 1 - s;
  return <double>[
    0.213 * inv + s, 0.715 * inv, 0.072 * inv, 0, 0, //
    0.213 * inv, 0.715 * inv + s, 0.072 * inv, 0, 0, //
    0.213 * inv, 0.715 * inv, 0.072 * inv + s, 0, 0, //
    0, 0, 0, 1, 0,
  ];
}

/// Horizontal "Tugas Hari Ini" carousel card: category color, priority badge,
/// inline progress track and the corner check trigger.
class FeaturedTaskCard extends StatelessWidget {
  const FeaturedTaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onOpen,
    this.width = 250,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onOpen;
  final double width;

  @override
  Widget build(BuildContext context) {
    final CategoryVisuals visuals =
        CategoryVisualsRegistry.of(task.category.visualsKey);
    final bool done = task.isDone;

    return SizedBox(
      width: width,
      child: Material(
        color: visuals.container,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(24),
        elevation: 0,
        child: InkWell(
          onTap: onOpen,
          child: Opacity(
            opacity: done ? 0.72 : 1,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(
                done ? _saturationMatrix(0.85) : _identityMatrix,
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: -26,
                    bottom: -26,
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: visuals.onContainer.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: visuals.onContainer
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                task.tag ?? visuals.shortLabel,
                                style: AppTypography.labelSm.copyWith(
                                  color: visuals.onContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            AnimatedCheck(
                              isChecked: done,
                              size: 28,
                              iconSize: 17,
                              indicator: CheckIndicator.ring,
                              uncheckedBg:
                                  visuals.onContainer.withValues(alpha: 0.18),
                              uncheckedFg: visuals.onContainer,
                              checkedBg:
                                  visuals.onContainer.withValues(alpha: 0.28),
                              checkedFg: visuals.onContainer,
                              confettiColors: <Color>[
                                visuals.onContainer,
                                AppColors.surfaceContainerLowest,
                                visuals.fixed,
                              ],
                              onTap: onToggle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: AnimatedStrikeText(
                                text: task.title,
                                struck: done,
                                style: AppTypography.headlineSm.copyWith(
                                  color: visuals.onContainer,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              visuals.emoji,
                              style: const TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySm.copyWith(
                            color: visuals.onContainer.withValues(alpha: 0.85),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          decoration: BoxDecoration(
                            color: visuals.onContainer.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    Formatters.time(task.time),
                                    style: AppTypography.labelMd.copyWith(
                                      color: visuals.onContainer,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${task.progress}%',
                                    style: AppTypography.labelLg.copyWith(
                                      color: visuals.onContainer,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _ProgressTrack(
                                value: task.progress / 100,
                                trackColor:
                                    visuals.onContainer.withValues(alpha: 0.20),
                                fillColor: visuals.onContainer,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({
    required this.value,
    required this.trackColor,
    required this.fillColor,
  });

  final double value;
  final Color trackColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double t, Widget? _) {
          return Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: t,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}