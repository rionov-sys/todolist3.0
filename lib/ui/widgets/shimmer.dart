import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Soft skeleton placeholder with a sweeping highlight (loading state).
///
/// Built with plain Flutter primitives — no external shimmer package needed.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat',
      excludeSemantics: true,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double width =
                      widget.width ?? constraints.maxWidth;
                  final bool canSweep = width.isFinite;
                  return Container(
                    width: widget.width,
                    height: widget.height,
                    color: AppColors.surfaceContainerHigh,
                    child: canSweep
                        ? Stack(
                            clipBehavior: Clip.hardEdge,
                            children: <Widget>[
                              Positioned(
                                left: -80 +
                                    _controller.value *
                                        (width + 160),
                                top: 0,
                                bottom: 0,
                                width: 80,
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(-1, 0),
                                      end: Alignment(1, 0),
                                      colors: <Color>[
                                        Colors.transparent,
                                        AppColors.surfaceContainerLowest,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : null,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Convenience row of skeleton lines matching the task-row layout.
class ShimmerTaskRow extends StatelessWidget {
  const ShimmerTaskRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ShimmerBox(width: 26, height: 26, radius: 13),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ShimmerBox(width: 180, height: 14),
                SizedBox(height: 8),
                ShimmerBox(height: 12),
                SizedBox(height: 10),
                ShimmerBox(width: 110, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}