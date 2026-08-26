import 'dart:math';
import 'package:flutter/material.dart';
import '../models/actor_icon.dart';
import '../models/theme_color_item.dart';

class PlayerEntity {
  double x = 0;
  double y = 0;
  double size = 60;
  double screenWidth = 400;
  double screenHeight = 800;
  bool isLeftLane = true;
  double targetX = 0;
  double speed = 50.0;
  bool hasShield = false;

  ActorIcon currentIcon;
  ThemeColorItem currentTheme;

  final List<Offset> trailPositions = [];
  static const int maxTrail = 10;

  PlayerEntity({
    required this.currentIcon,
    required this.currentTheme,
  });

  void init(double width, double height) {
    screenWidth = width;
    screenHeight = height;
    size = screenWidth / 6;
    y = screenHeight - (size * 2);
    reset();
  }

  void reset() {
    isLeftLane = true;
    targetX = (screenWidth / 4) - (size / 2);
    x = targetX;
    hasShield = false;
    trailPositions.clear();
    for (int i = 0; i < maxTrail; i++) {
      trailPositions.add(Offset(x, y));
    }
  }

  void toggleLane() {
    isLeftLane = !isLeftLane;
    if (isLeftLane) {
      targetX = (screenWidth / 4) - (size / 2);
    } else {
      targetX = (3 * screenWidth / 4) - (size / 2);
    }
  }

  void update() {
    // Smooth lane transition interpolation
    if (x < targetX) {
      x = min(x + speed, targetX);
    } else if (x > targetX) {
      x = max(x - speed, targetX);
    }

    // Update trail
    if (trailPositions.isNotEmpty) {
      trailPositions.removeLast();
    }
    trailPositions.insert(0, Offset(x, y));
  }

  Rect get collisionRect => Rect.fromLTWH(x, y, size, size);
}
