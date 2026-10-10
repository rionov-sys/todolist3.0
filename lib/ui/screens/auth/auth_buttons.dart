import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Big pill CTA with loading state.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(loadingLabel ?? 'Menghubungkan...'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(label),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}

/// Google / Apple style social buttons (demo actions).
class AuthSocialRow extends StatelessWidget {
  const AuthSocialRow({super.key, required this.onSocial});

  final void Function(String provider) onSocial;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: Icons.g_mobiledata_rounded,
            onTap: () => onSocial('Google'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            icon: Icons.apple,
            onTap: () => onSocial('Apple'),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppShadows.soft,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 22, color: AppColors.onSurface),
              const SizedBox(width: 8),
              Text(label, style: AppTypography.labelMd),
            ],
          ),
        ),
      ),
    );
  }
}

/// "atau masuk dengan" divider.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: <Widget>[
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              text.toUpperCase(),
              style: AppTypography.labelSm.copyWith(
                color: AppColors.outline,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
