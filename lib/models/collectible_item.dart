import 'dart:math';
import 'package:flutter/material.dart';

enum CollectibleType { shield, star, magnet, ghost, gem }

class CollectibleItem {
  final CollectibleType type;
  double x;
  double y;
  final double size;
  final double speed;

  CollectibleItem({
    required double screenWidth,
    required this.speed,
    required this.type,
    double? initialY,
  })  : size = screenWidth / 10,
        x = (Random().nextBool() ? (screenWidth / 4) : (3 * screenWidth / 4)) - (screenWidth / 20),
        y = initialY ?? -(screenWidth / 10);

  void update() {
    y += speed;
  }

  bool isOffScreen(double screenHeight) {
    return y > screenHeight;
  }

  Rect get collisionRect => Rect.fromLTWH(x, y, size, size);
}
