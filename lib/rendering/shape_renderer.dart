import 'dart:math';
import 'package:flutter/material.dart';
import '../models/actor_icon.dart';

class ShapeRenderer {
  static final Map<String, TextPainter> _emojiPainterCache = {};

  // Unit-sized precalculated paths (0.0 to 1.0)
  static final Path _unitTriangle = Path()
    ..moveTo(0.5, 0.0)
    ..lineTo(0.0, 1.0)
    ..lineTo(1.0, 1.0)
    ..close();

  static final Path _unitDiamond = Path()
    ..moveTo(0.5, 0.0)
    ..lineTo(1.0, 0.5)
    ..lineTo(0.5, 1.0)
    ..lineTo(0.0, 0.5)
    ..close();

  static final Path _unitHexagon = _createPolygon(6, -30);
  static final Path _unitPentagon = _createPolygon(5, -90);

  static final Path _unitHeart = Path()
    ..moveTo(0.5, 0.25)
    ..cubicTo(0.0, 0.0, 0.0, 0.5, 0.5, 1.0)
    ..cubicTo(1.0, 0.5, 1.0, 0.0, 0.5, 0.25)
    ..close();

  static Path _createPolygon(int sides, double startAngleDeg) {
    final path = Path();
    const double cx = 0.5;
    const double cy = 0.5;
    const double radius = 0.5;
    final double step = (2 * pi) / sides;
    final double startRad = startAngleDeg * pi / 180;

    for (int i = 0; i < sides; i++) {
      final double angle = startRad + (i * step);
      final double px = cx + radius * cos(angle);
      final double py = cy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

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
        _drawUnitPath(canvas, _unitTriangle, x, y, size, paint);
        break;

      case ActorType.hexagon:
        _drawUnitPath(canvas, _unitHexagon, x, y, size, paint);
        break;

      case ActorType.diamond:
        _drawUnitPath(canvas, _unitDiamond, x, y, size, paint);
        break;

      case ActorType.heart:
        _drawUnitPath(canvas, _unitHeart, x, y, size, paint);
        break;

      case ActorType.pentagon:
        _drawUnitPath(canvas, _unitPentagon, x, y, size, paint);
        break;

      case ActorType.emoji:
        if (emoji.isEmpty) return;
        final fontSize = (size * 0.75).roundToDouble();
        final cacheKey = '$emoji-$fontSize';

        var textPainter = _emojiPainterCache[cacheKey];
        if (textPainter == null) {
          textPainter = TextPainter(
            text: TextSpan(
              text: emoji,
              style: TextStyle(fontSize: fontSize),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          )..layout();
          _emojiPainterCache[cacheKey] = textPainter;
        }

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

  static void _drawUnitPath(Canvas canvas, Path path, double x, double y, double size, Paint paint) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(size, size);
    canvas.drawPath(path, paint);
    canvas.restore();
  }
}
