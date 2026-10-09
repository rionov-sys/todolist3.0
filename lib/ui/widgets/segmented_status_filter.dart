import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../state/task_provider.dart';

/// Segmented "Semua / Belum Selesai / Selesai" filter with live count badges.
class SegmentedStatusFilter extends StatelessWidget {
  const SegmentedStatusFilter({
    super.key,
    required this.counts,
    required this.value,
    required this.onChanged,
  });

  final Map<TimelineStatusFilter, int> counts;
  final TimelineStatusFilter value;
  final ValueChanged<TimelineStatusFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: TimelineStatusFilter.values.map((
          TimelineStatusFilter filter,
        ) {
          final bool active = filter == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(filter),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: active
                      ? <BoxShadow>[
                          BoxShadow(
                            color: AppColors.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        switch (filter) {
                          TimelineStatusFilter.all => 'Semua',
                          TimelineStatusFilter.uncompleted => 'Belum Selesai',
                          TimelineStatusFilter.completed => 'Selesai',
                        },
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMd.copyWith(
                          color: active
                              ? AppColors.onPrimary
                              : AppColors.onSurfaceVariant,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      constraints: const BoxConstraints(minWidth: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.onPrimary.withValues(alpha: 0.22)
                            : AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${counts[filter] ?? 0}',
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
            ),
          );
        }).toList(),
      ),
    );
  }
}