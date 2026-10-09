import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Pill search field with focus glow and animated clear button
/// (mocked "Cari tugas, topik, atau proyek…" input).
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    this.controller,
    this.hint = 'Cari tugas, topik, atau proyek...',
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String hint;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  late final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChange(String value) {
    if (_hasText != value.isNotEmpty) {
      setState(() => _hasText = value.isNotEmpty);
    }
    widget.onChanged(value);
  }

  void _clear() {
    _controller.clear();
    _handleChange('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _focused
            ? AppColors.surfaceBright
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: _focused
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                const BoxShadow(
                  color: Color(0x0D1E293B),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                  spreadRadius: -5,
                ),
              ]
            : AppShadows.card,
      ),
      child: Row(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 10),
            child: Icon(
              Icons.search_rounded,
              size: 22,
              color: AppColors.outline,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _handleChange,
              textInputAction: TextInputAction.search,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurface,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: widget.hint,
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          AnimatedScale(
            scale: _hasText ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: _hasText ? _clear : null,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}