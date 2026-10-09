import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Slim banner shown under the header while the app is offline or has queued
/// changes waiting to synchronise.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final String text = message ??
        'Anda sedang offline. Perubahan tetap tersimpan dan disinkronkan otomatis.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inverseSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: AppColors.secondaryFixedDim,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.inverseOnSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}