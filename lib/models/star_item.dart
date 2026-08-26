import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StarItem {
  double x;
  double y;
  double speed;
  double size;
  double alpha;
  Color baseColor;

  StarItem({
    required double screenWidth,
    required double screenHeight,
    Random? random,
  })  : x = 0,
        y = 0,
        speed = 0,
        size = 0,
        alpha = 0,
        baseColor = Colors.white {
    final r = random ?? Random();
    x = r.nextDouble() * screenWidth;
    y = r.nextDouble() * screenHeight;
    speed = 2.0 + r.nextDouble() * 5.0;
    size = 1.0 + r.nextDouble() * 4.0;
    alpha = 0.4 + r.nextDouble() * 0.6;

    final colorIdx = r.nextInt(4);
    if (colorIdx == 0) {
      baseColor = AppColors.primary;
    } else if (colorIdx == 1) {
      baseColor = AppColors.tertiary;
    } else if (colorIdx == 2) {
      baseColor = AppColors.secondary;
    } else {
      baseColor = Colors.white;
    }
  }

  void update({
    required double speedMultiplier,
    required double screenWidth,
    required double screenHeight,
    Random? random,
  }) {
    y += speed * speedMultiplier;
    if (y > screenHeight) {
      final r = random ?? Random();
      y = -10;
      x = r.nextDouble() * screenWidth;
    }
  }
}
