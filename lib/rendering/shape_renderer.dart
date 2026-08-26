import 'dart:math';
import 'package:flutter/material.dart';
import '../models/actor_icon.dart';

class ShapeRenderer {
  static void drawShape({
    required Canvas canvas,
    required Paint paint,
    required ActorType type,
    required double x,
    required double y,
    required double size,
    String emoji = '',
  }) {
    switch (type) {
      case ActorType.square:
        canvas.drawRect(Rect.fromLTWH(x, y, size, size), paint);
        break;

      case ActorType.circle:
        canvas.drawCircle(Offset(x + size / 2, y + size / 2), size / 2, paint);
        break;

      case ActorType.triangle:
        final path = Path()
          ..moveTo(x + size / 2, y)
          ..lineTo(x, y + size)
          ..lineTo(x + size, y + size)
          ..close();
        canvas.drawPath(path, paint);
        break;

      case ActorType.hexagon:
        final path = Path();
        final double cx = x + size / 2;
        final double cy = y + size / 2;
        final double radius = size / 2;
        for (int i = 0; i < 6; i++) {
          final double angle = (60 * i - 30) * pi / 180;
          final double px = cx + radius * cos(angle);
          final double py = cy + radius * sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;

      case ActorType.diamond:
        final path = Path()
          ..moveTo(x + size / 2, y)
          ..lineTo(x + size, y + size / 2)
          ..lineTo(x + size / 2, y + size)
          ..lineTo(x, y + size / 2)
          ..close();
        canvas.drawPath(path, paint);
        break;

      case ActorType.heart:
        final path = Path();
        final double cx = x + size / 2;
        final double cy = y + size / 2;
        path.moveTo(cx, cy + size / 4);
        path.cubicTo(x, y, x, y + size / 2, cx, y + size);
        path.cubicTo(x + size, y + size / 2, x + size, y, cx, cy + size / 4);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case ActorType.pentagon:
        final path = Path();
        final double cx = x + size / 2;
        final double cy = y + size / 2;
        final double radius = size / 2;
        for (int i = 0; i < 5; i++) {
          final double angle = (72 * i - 90) * pi / 180;
          final double px = cx + radius * cos(angle);
          final double py = cy + radius * sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
        break;

      case ActorType.emoji:
        final textSpan = TextSpan(
          text: emoji,
          style: TextStyle(
            fontSize: size * 0.75,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            x + (size - textPainter.width) / 2,
            y + (size - textPainter.height) / 2,
          ),
        );
        break;
    }
  }
}
