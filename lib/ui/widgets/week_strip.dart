import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';

/// Weekly horizontal calendar strip (Mon → Sun) with swipe support and the
/// active-day pill + dot from the mocks.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.selected,
    required this.onSelected,
    this.onWeekShift,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  /// Called with ±7 when the user swipes to another week.
  final ValueChanged<int>? onWeekShift;

  @override
  Widget build(BuildContext context) {
    final DateTime weekStart =
        selected.subtract(Duration(days: Formatters.mondayIndex(selected)));
    final DateTime today = DateTime.now();

    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        final double v = details.primaryVelocity ?? 0;
        if (v.abs() < 200) return;
        onWeekShift?.call(v < 0 ? 7 : -7);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: List<Widget>.generate(7, (int i) {
            final DateTime day = weekStart.add(Duration(days: i));
            final bool isSelected = day.year == selected.year &&
                day.month == selected.month &&
                day.day == selected.day;
            final bool isToday = day.year == today.year &&
                day.month == today.month &&
                day.day == today.day;

            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(day),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryFixed
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: isSelected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: AppColors.primary
                                  .withValues(alpha: 0.22),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        Formatters.weekdayShort(day),
                        style: AppTypography.labelSm.copyWith(
                          color: isSelected
                              ? AppColors.onPrimaryFixed
                              : AppColors.outline,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${day.day}',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          color: isSelected
                              ? AppColors.onPrimaryFixed
                              : AppColors.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                        child: isSelected || isToday
                            ? Container(
                                margin: const EdgeInsets.only(top: 3),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.outline,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}