import 'dart:math';
import 'package:flutter/material.dart';
import '../models/star_item.dart';

class GameBackground {
  final List<StarItem> stars = [];
  double gridOffset = 0;
  double screenWidth;
  double screenHeight;
  Color activeSkinColor;
  final Random random = Random();

  GameBackground({
    required this.screenWidth,
    required this.screenHeight,
    this.activeSkinColor = const Color(0xFF1C1B1F),
  }) {
    for (int i = 0; i < 100; i++) {
      stars.add(StarItem(screenWidth: screenWidth, screenHeight: screenHeight, random: random));
    }
  }

  void update(double gameSpeed) {
    final double speedMultiplier = gameSpeed / 10.0;

    for (final star in stars) {
      star.update(
        speedMultiplier: speedMultiplier,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        random: random,
      );
    }

    gridOffset += speedMultiplier * 8.0;
    if (gridOffset > 150) {
      gridOffset = 0;
    }
  }

  void draw(Canvas canvas, Size size) {
    // Fill background skin base
    final bgPaint = Paint()..color = activeSkinColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Draw stars
    final starPaint = Paint();
    for (final star in stars) {
      starPaint.color = star.baseColor.withValues(alpha: star.alpha);
      canvas.drawCircle(Offset(star.x, star.y), star.size, starPaint);
    }

    // Grid lines color based on skin
    final isMatrix = activeSkinColor.toARGB32() == 0xFF001000 || activeSkinColor.toARGB32() == 0xFF000000;
    final gridColor = isMatrix ? const Color(0xFF39FF14) : const Color(0xFF313033);

    final linePaint = Paint()
      ..color = gridColor.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Vertical lane divider lines
    final lane1 = size.width / 4;
    final lane2 = 3 * size.width / 4;
    final centerLane = size.width / 2;

    canvas.drawLine(Offset(lane1, 0), Offset(lane1, size.height), linePaint);
    canvas.drawLine(Offset(lane2, 0), Offset(lane2, size.height), linePaint);
    canvas.drawLine(Offset(centerLane, 0), Offset(centerLane, size.height), linePaint);

    // Horizontal moving perspective lines
    for (double y = gridOffset; y < size.height; y += 150) {
      final alphaFactor = (y / size.height).clamp(0.0, 1.0);
      linePaint.color = gridColor.withValues(alpha: 0.15 * alphaFactor);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }
}
