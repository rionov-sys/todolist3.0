import 'package:flutter/material.dart';

/// Animated donut chart for the analytics hero card: track + completed
/// (green) + in-progress (amber) sweeps with rounded caps.
class DonutChart extends StatefulWidget {
  const DonutChart({
    super.key,
    this.doneFraction = 0,
    this.progressFraction = 0,
    this.size = 96,
    this.strokeWidth = 10,
  });

  final double doneFraction;
  final double progressFraction;
  final double size;
  final double strokeWidth;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  double _fromDone = 0;
  double _fromProgress = 0;
  double _toDone = 0;
  double _toProgress = 0;

  @override
  void initState() {
    super.initState();
    _toDone = widget.doneFraction;
    _toProgress = widget.progressFraction;
    _controller.forward();
  }

  @override
  void didUpdateWidget(DonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.doneFraction != widget.doneFraction ||
        oldWidget.progressFraction != widget.progressFraction) {
      final double t = _controller.value;
      _fromDone = _lerp(_fromDone, _toDone, t);
      _fromProgress = _lerp(_fromProgress, _toProgress, t);
      _toDone = widget.doneFraction;
      _toProgress = widget.progressFraction;
      _controller.forward(from: 0);
    }
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        final double t = Curves.easeOutCubic.transform(_controller.value);
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _DonutPainter(
            done: _lerp(_fromDone, _toDone, t),
            inProgress: _lerp(_fromProgress, _toProgress, t),
            strokeWidth: widget.strokeWidth,
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.done,
    required this.inProgress,
    required this.strokeWidth,
  });

  final double done;
  final double inProgress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE7EEFF);
    canvas.drawCircle(center, radius, track);

    final double sweep = 2 * 3.141592653589793;

    if (inProgress > 0) {
      final Paint progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFE9C22);
      canvas.drawArc(
        rect,
        -1.5707963267948966,
        sweep * inProgress.clamp(0.0, 1.0),
        false,
        progressPaint,
      );
    }

    if (done > 0) {
      final Paint donePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF5B7E3C);
      canvas.drawArc(
        rect,
        -1.5707963267948966,
        sweep * done.clamp(0.0, 1.0),
        false,
        donePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.done != done ||
      oldDelegate.inProgress != inProgress ||
      oldDelegate.strokeWidth != strokeWidth;
}