import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Shared auth chrome so Login & Register stay visually consistent.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.appBar});

  final Widget child;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppSpacing.contentMaxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand mark: rounded check badge with a sparkle dot.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppShadows.colored(AppColors.primaryContainer),
          ),
          child: Icon(
            Icons.check_rounded,
            color: AppColors.onPrimary,
            size: size * 0.55,
          ),
        ),
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.accentAmber,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.bolt_rounded, size: 10, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
