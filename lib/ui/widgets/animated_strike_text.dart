import 'package:flutter/material.dart';

/// Single-line text whose strike-through grows from 0 → 100 % when the task
/// is completed (the mocked `taskStrike` keyframes).
///
/// The laid-out glyph width is measured with [TextPainter] so the line stops
/// exactly at the end of the visible (possibly ellipsized) text.
class AnimatedStrikeText extends StatelessWidget {
  const AnimatedStrikeText({
    super.key,
    required this.text,
    required this.struck,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  final String text;
  final bool struck;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    final TextStyle resolved =
        style ?? DefaultTextStyle.of(context).style;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter probe = TextPainter(
          text: TextSpan(text: text, style: resolved),
          textDirection: direction,
          maxLines: 1,
          ellipsis: '…',
        )..layout(maxWidth: constraints.maxWidth);
        final double width = probe.width;
        final double height = probe.height;
        probe.dispose();

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: struck ? 1 : 0),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double t, Widget? _) {
            final bool complete = t >= 0.995;
            return SizedBox(
              width: width,
              height: height,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  Positioned(
                    left: 0,
                    top: 0,
                    width: width,
                    child: Text(
                      text,
                      style: resolved.copyWith(
                        decoration:
                            complete ? TextDecoration.lineThrough : null,
                        decorationColor: resolved.color,
                        decorationThickness: 1.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!complete && t > 0)
                    Positioned(
                      left: 0,
                      top: height * 0.55,
                      width: width * t,
                      height: 1.8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: (resolved.color ?? Colors.black)
                              .withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}