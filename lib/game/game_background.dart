import 'dart:math';
import 'package:flutter/material.dart';
import '../models/star_item.dart';

class GameBackground {
  final List<StarItem> stars = [];
  double gridOffset = 0;
  double screenWidth;
  double screenHeight;
  Color activeSkinColor;
  Color gridColor;
  final Random random = Random();

  // Reusable Paint instances
  final Paint _bgPaint = Paint()..style = PaintingStyle.fill;
  final Paint _starPaint = Paint()..style = PaintingStyle.fill;
  final Paint _linePaint = Paint()
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  GameBackground({
    required this.screenWidth,
    required this.screenHeight,
    this.activeSkinColor = const Color(0xFF1C1B1F),
  }) : gridColor = (activeSkinColor.toARGB32() == 0xFF001000 || activeSkinColor.toARGB32() == 0xFF000000)
            ? const Color(0xFF39FF14)
            : const Color(0xFF313033) {
    // 50 stars is optimal for performance and visual density
    for (int i = 0; i < 50; i++) {
      stars.add(StarItem(screenWidth: screenWidth, screenHeight: screenHeight, random: random));
    }
  }

  void updateSkin(Color skinColor) {
    activeSkinColor = skinColor;
    final isMatrix = skinColor.toARGB32() == 0xFF001000 || skinColor.toARGB32() == 0xFF000000;
    gridColor = isMatrix ? const Color(0xFF39FF14) : const Color(0xFF313033);
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
    // 1. Fill background skin base
    _bgPaint.color = activeSkinColor;
    canvas.drawRect(Offset.zero & size, _bgPaint);

    // 2. Draw stars
    for (final star in stars) {
      _starPaint.color = star.baseColor.withValues(alpha: star.alpha);
      canvas.drawCircle(Offset(star.x, star.y), star.size, _starPaint);
    }

    // 3. Vertical lane divider lines
    _linePaint.color = gridColor.withValues(alpha: 0.25);
    final lane1 = size.width / 4;
    final lane2 = 3 * size.width / 4;
    final centerLane = size.width / 2;

    canvas.drawLine(Offset(lane1, 0), Offset(lane1, size.height), _linePaint);
    canvas.drawLine(Offset(lane2, 0), Offset(lane2, size.height), _linePaint);
    canvas.drawLine(Offset(centerLane, 0), Offset(centerLane, size.height), _linePaint);

    // 4. Horizontal moving perspective lines
    for (double y = gridOffset; y < size.height; y += 150) {
      final alphaFactor = (y / size.height).clamp(0.0, 1.0);
      _linePaint.color = gridColor.withValues(alpha: 0.15 * alphaFactor);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _linePaint);
    }
  }
}
