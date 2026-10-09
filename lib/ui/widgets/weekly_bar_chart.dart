import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Seven-day bar chart (Mon → Sun) with animated bar heights — the
/// "Target Mingguan" card from the analytics mock.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.values,
    required this.todayIndex,
  });

  /// Completed tasks per weekday, index 0 = Monday.
  final List<int> values;
  final int todayIndex;

  static const List<String> _labels = <String>[
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  @override
  Widget build(BuildContext context) {
    final int max = values.fold<int>(
      1,
      (int current, int v) => v > current ? v : current,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List<Widget>.generate(7, (int i) {
        final int value = i < values.length ? values[i] : 0;
        final bool isToday = i == todayIndex;
        final double targetHeight = value == 0
            ? 8
            : 14 + (value / max) * 58;
        final Color color = isToday
            ? AppColors.primary
            : value > 0
                ? AppColors.primaryFixed
                : AppColors.surfaceContainerHighest;

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$value',
                style: AppTypography.labelSm.copyWith(
                  color: isToday
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 76,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: targetHeight),
                    duration: Duration(milliseconds: 420 + (i * 70)),
                    curve: Curves.easeOutCubic,
                    builder: (BuildContext context, double h, Widget? _) {
                      return Container(
                        width: 16,
                        height: h,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _labels[i],
                style: AppTypography.labelSm.copyWith(
                  color: isToday ? AppColors.primary : AppColors.outline,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}