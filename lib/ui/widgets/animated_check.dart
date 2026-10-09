import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Circular checkbox with the design's "check-pop" bounce
/// (cubic-bezier(0.34, 1.56, 0.64, 1)) plus a confetti particle burst when a
/// task is completed.
class AnimatedCheck extends StatefulWidget {
  const AnimatedCheck({
    super.key,
    required this.isChecked,
    required this.uncheckedBg,
    required this.uncheckedFg,
    this.checkedBg = AppColors.primary,
    this.checkedFg = AppColors.onPrimary,
    this.size = 26,
    this.iconSize = 16,
    this.indicator = CheckIndicator.dot,
    this.enableConfetti = true,
    this.confettiColors,
    this.onTap,
  });

  final bool isChecked;
  final Color uncheckedBg;
  final Color uncheckedFg;
  final Color checkedBg;
  final Color checkedFg;
  final double size;
  final double iconSize;
  final CheckIndicator indicator;
  final bool enableConfetti;
  final List<Color>? confettiColors;
  final VoidCallback? onTap;

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

enum CheckIndicator { dot, ring }

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  bool _burst = false;

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap?.call();
    if (!widget.isChecked) {
      _pop.forward(from: 0);
      if (widget.enableConfetti && mounted) {
        setState(() => _burst = true);
      }
    }
  }

  /// Reproduces the keyframes 0.85 → 1.22 → 0.95 → 1.
  double _scaleAt(double t) {
    if (t < 0.5) {
      return 0.85 + (1.22 - 0.85) * Curves.easeOut.transform(t / 0.5);
    }
    if (t < 0.75) {
      return 1.22 + (0.95 - 1.22) * Curves.easeInOut.transform((t - 0.5) / 0.25);
    }
    return 0.95 + (1 - 0.95) * Curves.easeOut.transform((t - 0.75) / 0.25);
  }

  @override
  Widget build(BuildContext context) {
    final Widget inner = widget.isChecked
        ? Icon(
            Icons.check_rounded,
            size: widget.iconSize,
            color: widget.checkedFg,
          )
        : switch (widget.indicator) {
            CheckIndicator.dot => Container(
                width: widget.size * 0.34,
                height: widget.size * 0.34,
                decoration: BoxDecoration(
                  color: widget.uncheckedFg,
                  shape: BoxShape.circle,
                ),
              ),
            CheckIndicator.ring => Container(
                width: widget.size * 0.52,
                height: widget.size * 0.52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.uncheckedFg.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
              ),
          };

    return Semantics(
      button: true,
      checked: widget.isChecked,
      label: widget.isChecked ? 'Tandai belum selesai' : 'Tandai selesai',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap == null ? null : _handleTap,
        child: AnimatedBuilder(
          animation: _pop,
          builder: (BuildContext context, Widget? child) {
            final double scale = widget.isChecked ? _scaleAt(_pop.value) : 1;
            return Transform.scale(scale: scale, child: child);
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color:
                      widget.isChecked ? widget.checkedBg : widget.uncheckedBg,
                  shape: BoxShape.circle,
                  boxShadow: widget.isChecked
                      ? <BoxShadow>[
                          BoxShadow(
                            color: widget.checkedBg.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(child: inner),
              ),
              if (_burst)
                Positioned.fill(
                  child: ConfettiBurst(
                    colors: widget.confettiColors ??
                        const <Color>[
                          AppColors.primary,
                          AppColors.secondary,
                          AppColors.tertiary,
                          AppColors.primaryFixed,
                        ],
                    onComplete: () {
                      if (mounted) setState(() => _burst = false);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Short-lived radial particle burst shown when a task is checked off.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    super.key,
    required this.onComplete,
    required this.colors,
    this.particles = 9,
    this.spread = 30,
  });

  final VoidCallback onComplete;
  final List<Color> colors;
  final int particles;
  final double spread;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(() {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? _) {
          return CustomPaint(
            painter: _ConfettiPainter(
              t: _controller.value,
              colors: widget.colors,
              count: widget.particles,
              spread: widget.spread,
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.t,
    required this.colors,
    required this.count,
    required this.spread,
  });

  final double t;
  final List<Color> colors;
  final int count;
  final double spread;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double eased = Curves.easeOutCubic.transform(t);
    final double opacity = (1 - t).clamp(0.0, 1.0);
    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final double angle = (i / count) * 2 * math.pi + 0.35;
      final double distance = eased * spread;
      final double radius = (2.8 * (1 - eased) + 0.8).clamp(0.5, 4.0);
      paint.color = colors[i % colors.length].withValues(alpha: opacity);
      canvas.drawCircle(
        center +
            Offset(math.cos(angle) * distance, math.sin(angle) * distance),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => oldDelegate.t != t;
}