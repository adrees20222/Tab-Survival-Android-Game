import 'dart:math';
import 'package:flutter/material.dart';

class ObstacleItem {
  double x;
  double y;
  final double size;
  final double speed;
  final double screenWidth;
  bool isShifter = false;
  bool hasShifted = false;
  late double targetX;

  ObstacleItem({
    required this.screenWidth,
    required this.speed,
  })  : size = screenWidth / 6,
        x = 0,
        y = -(screenWidth / 6) {
    final random = Random();
    final bool leftLane = random.nextBool();

    if (leftLane) {
      x = (screenWidth / 4) - (size / 2);
    } else {
      x = (3 * screenWidth / 4) - (size / 2);
    }

    // 25% chance to be a shifter when speed is high enough
    if (speed > 18 && random.nextDouble() < 0.25) {
      isShifter = true;
      targetX = leftLane ? (3 * screenWidth / 4) - (size / 2) : (screenWidth / 4) - (size / 2);
    } else {
      targetX = x;
    }
  }

  void update() {
    y += speed;

    if (isShifter && !hasShifted && y > screenWidth * 0.4) {
      final moveSpeed = speed * 0.8;
      if (x < targetX) {
        x = min(x + moveSpeed, targetX);
      } else if (x > targetX) {
        x = max(x - moveSpeed, targetX);
      }

      if ((x - targetX).abs() < 1.0) {
        x = targetX;
        hasShifted = true;
      }
    }
  }

  bool isOffScreen(double screenHeight) {
    return y > screenHeight;
  }

  Rect get collisionRect => Rect.fromLTWH(x, y, size, size);
}
