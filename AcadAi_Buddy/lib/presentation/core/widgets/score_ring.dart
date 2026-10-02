import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Colour for a score percentage (0-100).
Color scoreColor(int percent) => percent >= 80
    ? AppColors.success
    : percent >= 60
        ? AppColors.accent
        : percent >= 40
            ? AppColors.warning
            : AppColors.error;

/// Animated circular score with the number in the display serif.
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score,
    required this.total,
    this.size = 168,
  });

  final int score;
  final int total;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : score / total;
    final percent = (fraction * 100).round();
    final color = scoreColor(percent);
    return Semantics(
      label: 'Score $score out of $total, $percent percent',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fraction),
        duration: AppMotion.of(context, const Duration(milliseconds: 900)),
        curve: AppMotion.curve,
        builder: (context, value, _) => SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(value, color),
            child: Center(
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$score/$total', style: AppText.display),
                    Text(
                      '${(value * 100).round()}%',
                      style: AppText.label.copyWith(color: color),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color);

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final track = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, track);
    if (value > 0) {
      canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * value, false, arc);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}
