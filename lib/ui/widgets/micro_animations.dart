import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Small pulsing dot used by the "Aktif" badge in the home greeting.
class PulsingDot extends StatefulWidget {
  const PulsingDot({
    super.key,
    this.size = 6,
    this.color = const Color(0xFF436526),
  });

  final double size;
  final Color color;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.35).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

/// Counter that bumps (scale 1 → 1.3 → 1) whenever its value changes —
/// the mocked `badge-bump` animation for status counts.
class AnimatedCount extends StatefulWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    required this.style,
    this.suffix = '',
  });

  final int value;
  final TextStyle style;
  final String suffix;

  @override
  State<AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<AnimatedCount>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void didUpdateWidget(AnimatedCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeOut.transform(_controller.value);
        final double scale = 1 + 0.3 * math.sin(math.pi * t);
        return Transform.scale(scale: scale, child: child);
      },
      child: Text('${widget.value}${widget.suffix}', style: widget.style),
    );
  }
}