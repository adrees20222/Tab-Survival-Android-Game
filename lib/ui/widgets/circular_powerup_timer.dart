import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CircularPowerupTimer extends StatelessWidget {
  final String label;
  final String emoji;
  final int currentFrames;
  final int maxFrames;
  final Color accentColor;

  const CircularPowerupTimer({
    super.key,
    required this.label,
    required this.emoji,
    required this.currentFrames,
    required this.maxFrames,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (currentFrames <= 0) return const SizedBox.shrink();

    final progress = (currentFrames / maxFrames).clamp(0.0, 1.0);
    final seconds = (currentFrames / 60).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: const Size(44, 44),
            painter: _CircularTimerPainter(
              progress: progress,
              accentColor: accentColor,
            ),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${seconds}s',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color accentColor;

  _CircularTimerPainter({
    required this.progress,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    final progressPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accentColor != accentColor;
  }
}
