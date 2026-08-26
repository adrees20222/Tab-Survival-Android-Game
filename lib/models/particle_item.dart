import 'dart:math';
import 'package:flutter/material.dart';

class ParticleItem {
  double x;
  double y;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  double alpha;
  final double fadeSpeed;

  ParticleItem({
    required this.x,
    required this.y,
    required this.color,
  })  : vx = (Random().nextDouble() - 0.5) * 20,
        vy = (Random().nextDouble() - 0.5) * 20,
        size = Random().nextDouble() * 10 + 5,
        alpha = 1.0,
        fadeSpeed = Random().nextDouble() * 0.04 + 0.02;

  void update() {
    x += vx;
    y += vy;
    alpha -= fadeSpeed;
  }

  bool get isDead => alpha <= 0;
}
