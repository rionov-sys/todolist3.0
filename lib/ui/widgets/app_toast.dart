import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Bottom toast matching the mocked feedback pill
/// ("Jadwal tugas siap diselaraskan!").
class AppToast {
  AppToast._();

  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.task_alt_rounded,
  }) {
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);

    _current?.remove();
    _current = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastPopup(
        message: message,
        icon: icon,
        onDismiss: () {
          entry.remove();
          if (identical(_current, entry)) _current = null;
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }
}

class _ToastPopup extends StatefulWidget {
  const _ToastPopup({
    required this.message,
    required this.icon,
    required this.onDismiss,
  });

  final String message;
  final IconData icon;
  final VoidCallback onDismiss;

  @override
  State<_ToastPopup> createState() => _ToastPopupState();
}

class _ToastPopupState extends State<_ToastPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 2400), _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().whenComplete(() {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: _controller,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 96),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inverseSurface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(widget.icon, size: 18, color: AppColors.primaryFixed),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: AppTypography.labelLg.copyWith(
                              color: AppColors.inverseOnSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin wrapper around [ScaffoldMessenger] for consistent snackbars.
class AppSnack {
  AppSnack._();

  static void show(
    BuildContext context,
    String message, {
    bool error = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              size: 18,
              color: error
                  ? AppColors.errorContainer
                  : AppColors.primaryFixed,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: AppColors.primaryFixed,
                onPressed: onAction ?? () {},
              ),
      ),
    );
  }
}