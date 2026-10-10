import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Labeled input matching the mock: icon, filled surface, rounded.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.requiredMark = false,
    this.keyboardType,
    this.obscure = false,
    this.onToggleObscure,
    this.trailingNote,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool requiredMark;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? trailingNote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: label,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  children: requiredMark
                      ? const <TextSpan>[
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
            if (trailingNote != null)
              Text(
                trailingNote!,
                style: AppTypography.bodySm.copyWith(color: AppColors.outline),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.outline,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
