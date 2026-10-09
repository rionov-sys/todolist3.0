import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/category_visuals.dart';
import 'micro_animations.dart';

/// The three circular "category nodes" (To-Do / Progress / Selesai) with live
/// counts and a bump animation whenever a count changes.
class StatusNode extends StatelessWidget {
  const StatusNode({
    super.key,
    required this.visuals,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final StatusVisuals visuals;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? visuals.fixed.withValues(alpha: 0.45)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? visuals.strong.withValues(alpha: 0.55)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: selected
                  ? null
                  : const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: visuals.fixed,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    visuals.icon,
                    size: 26,
                    color: visuals.strong,
                    fill: visuals.filledIcon ? 1 : 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  visuals.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                AnimatedCount(
                  value: count,
                  suffix: ' item',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w600,
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