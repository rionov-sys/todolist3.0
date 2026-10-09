import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Fixed top bar: wordmark + screen subtitle, notifications and avatar.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.subtitle,
    required this.onNotifications,
    required this.onOpenProfile,
  });

  final String subtitle;
  final VoidCallback onNotifications;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.primary, AppColors.primaryContainer],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.onPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AppConfig.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 17,
                  ),
                ),
                Text(
                  subtitle.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.outline,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNotifications,
            tooltip: 'Notifikasi',
            icon: Badge(
              smallSize: 7,
              backgroundColor: AppColors.tertiary,
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 24,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onOpenProfile,
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                AppConfig.userName.characters.first.toUpperCase(),
                style: AppTypography.labelLg.copyWith(
                  color: AppColors.onPrimaryFixed,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}