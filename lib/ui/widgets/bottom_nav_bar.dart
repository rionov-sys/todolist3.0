import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Pill-item bottom navigation matching the mocked fixed nav bar
/// (backdrop blur, upward shadow, primary active state).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(Icons.check_circle_outline_rounded, Icons.check_circle_rounded,
        'Tasks'),
    _NavItem(Icons.calendar_today_outlined, Icons.calendar_today_rounded,
        'Timeline'),
    _NavItem(Icons.insights_outlined, Icons.insights_rounded, 'Analytics'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(boxShadow: AppShadows.nav),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: AppColors.surface.withValues(alpha: 0.92),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: List<Widget>.generate(_items.length, (int i) {
                    final _NavItem item = _items[i];
                    final bool active = i == currentIndex;
                    return Expanded(
                      child: InkWell(
                        onTap: () => onChanged(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> a) =>
                                  ScaleTransition(scale: a, child: child),
                              child: Icon(
                                active ? item.activeIcon : item.icon,
                                key: ValueKey<bool>(active),
                                size: 24,
                                color: active
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: AppTypography.labelSm.copyWith(
                                color: active
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                                fontWeight:
                                    active ? FontWeight.w800 : FontWeight.w500,
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}