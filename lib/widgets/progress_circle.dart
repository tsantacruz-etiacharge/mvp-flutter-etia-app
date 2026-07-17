import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/colors.dart';

class ProgressCircle extends StatelessWidget {
  final double progress;

  const ProgressCircle({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ProgressCirclePainter(progress.clamp(0.0, 1.0)),
      child: const SizedBox.expand(),
    );
  }
}

class _ProgressCirclePainter extends CustomPainter {
  final double progress;

  _ProgressCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final fill = Paint()
      ..color = AppColors.card
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fill);

    final track = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawCircle(center, radius, track);

    if (progress > 0) {
      final arc = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressCirclePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
