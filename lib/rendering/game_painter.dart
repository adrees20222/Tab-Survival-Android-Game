import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../game/game_controller.dart';
import '../game/player_entity.dart';
import '../models/collectible_item.dart';
import 'shape_renderer.dart';

class GamePainter extends CustomPainter {
  final GameController controller;

  // Reusable Paint instances to prevent per-frame allocations
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _strokePaint = Paint()..style = PaintingStyle.stroke;
  static final Paint _particlePaint = Paint()..style = PaintingStyle.fill;
  static final Paint _bannerBgPaint = Paint()
    ..color = AppColors.surface.withValues(alpha: 0.85)
    ..style = PaintingStyle.fill;
  static final Paint _bannerBorderPaint = Paint()
    ..color = AppColors.primary
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  // Global static cache for pre-rendered TextPainters
  static final Map<String, TextPainter> _textPainterCache = {};

  static TextPainter _getTextPainter({
    required String text,
    required TextStyle style,
    TextAlign textAlign = TextAlign.center,
  }) {
    final key = '$text-${style.fontSize}-${style.fontWeight?.value}-${style.color?.toARGB32()}';
    return _textPainterCache.putIfAbsent(key, () {
      final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        textAlign: textAlign,
      );
      tp.layout();
      return tp;
    });
  }

  GamePainter(this.controller, {Listenable? repaint}) : super(repaint: repaint ?? controller);

  @override
  void paint(Canvas canvas, Size size) {
    // Apply camera shake if active
    if (controller.shakeDuration > 0) {
      canvas.save();
      canvas.translate(controller.shakeOffsetX, controller.shakeOffsetY);
    }

    // 1. Draw Background (Starfield + Neon Perspective Grid)
    controller.background.draw(canvas, size);

    // 2. Draw Particles
    for (final p in controller.particles) {
      _particlePaint.color = p.color.withValues(alpha: p.alpha.clamp(0.0, 1.0));
      canvas.drawRect(Rect.fromLTWH(p.x, p.y, p.size, p.size), _particlePaint);
    }

    // 3. Draw Game entities ONLY during gameplay or pause
    final bool isGameActive = controller.currentState == GameState.playing ||
        controller.currentState == GameState.paused ||
        controller.currentState == GameState.gameOver;

    if (isGameActive) {
      _drawCollectibles(canvas);
      _drawObstacles(canvas);
      _drawPlayer(canvas);
      _drawFloatingTexts(canvas);
      _drawAlerts(canvas, size);
    }

    if (controller.shakeDuration > 0) {
      canvas.restore();
    }
  }

  void _drawCollectibles(Canvas canvas) {
    for (final c in controller.collectibles) {
      switch (c.type) {
        case CollectibleType.shield:
          _fillPaint.color = AppColors.shieldGreen;
          canvas.drawCircle(Offset(c.x + c.size / 2, c.y + c.size / 2), c.size / 2, _fillPaint);
          _drawCachedEmoji(canvas, '🛡️', c.x, c.y, c.size, 0.65);
          break;

        case CollectibleType.star:
          _fillPaint.color = AppColors.gold;
          canvas.save();
          canvas.translate(c.x + c.size / 2, c.y + c.size / 2);
          canvas.rotate(pi / 4);
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: c.size * 0.8, height: c.size * 0.8),
            _fillPaint,
          );
          canvas.restore();
          break;

        case CollectibleType.magnet:
          _fillPaint.color = AppColors.magnetPink;
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(c.x, c.y, c.size, c.size), const Radius.circular(8)),
            _fillPaint,
          );
          _drawCachedEmoji(canvas, '🧲', c.x, c.y, c.size, 0.65);
          break;

        case CollectibleType.ghost:
          _fillPaint.color = AppColors.ghostBlue.withValues(alpha: 0.8);
          canvas.drawCircle(Offset(c.x + c.size / 2, c.y + c.size / 2), c.size / 2, _fillPaint);
          _drawCachedEmoji(canvas, '👻', c.x, c.y, c.size, 0.65);
          break;

        case CollectibleType.gem:
          _fillPaint.color = AppColors.gemPurple;
          canvas.save();
          canvas.translate(c.x + c.size / 2, c.y + c.size / 2);
          canvas.rotate(pi / 4);
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: c.size * 0.8, height: c.size * 0.8),
            _fillPaint,
          );
          canvas.restore();
          break;
      }
    }
  }

  void _drawCachedEmoji(Canvas canvas, String emoji, double x, double y, double size, double scaleRatio) {
    final fontSize = (size * scaleRatio).roundToDouble();
    final tp = _getTextPainter(
      text: emoji,
      style: TextStyle(fontSize: fontSize),
    );
    tp.paint(
      canvas,
      Offset(x + (size - tp.width) / 2, y + (size - tp.height) / 2),
    );
  }

  void _drawObstacles(Canvas canvas) {
    final shape = controller.currentObstacleShape.type;
    final color = controller.currentObstacleColor.color;

    for (final o in controller.obstacles) {
      // Shifter warning border
      if (o.isShifter && !o.hasShifted) {
        _strokePaint
          ..strokeWidth = 3
          ..color = Colors.white;
        ShapeRenderer.drawShape(
          canvas: canvas,
          paint: _strokePaint,
          type: shape,
          x: o.x,
          y: o.y,
          size: o.size,
        );
      }

      _fillPaint.color = color;
      ShapeRenderer.drawShape(
        canvas: canvas,
        paint: _fillPaint,
        type: shape,
        x: o.x,
        y: o.y,
        size: o.size,
      );
    }
  }

  void _drawPlayer(Canvas canvas) {
    final player = controller.player;
    final isGhost = controller.ghostTimer > 0;
    final isFever = controller.feverTimer > 0;

    final Color themeColor = isFever ? AppColors.gold : controller.currentTheme.color;

    // 1. Neon Glow Pass
    _fillPaint.color = themeColor.withValues(alpha: isGhost ? 0.15 : 0.35);
    final glowSize = player.size * 1.25;
    final glowOffset = (glowSize - player.size) / 2;
    ShapeRenderer.drawShape(
      canvas: canvas,
      paint: _fillPaint,
      type: player.currentIcon.type,
      x: player.x - glowOffset,
      y: player.y - glowOffset,
      size: glowSize,
      emoji: player.currentIcon.emoji,
    );

    // 2. Trail Pass
    for (int i = 0; i < PlayerEntity.maxTrail; i++) {
      final int index = (player.trailIndex - i + PlayerEntity.maxTrail) % PlayerEntity.maxTrail;
      final px = player.trailX[index];
      final py = player.trailY[index];
      final trailRatio = 1.0 - (i / PlayerEntity.maxTrail);
      final alpha = (0.5 * trailRatio) * (isGhost ? 0.4 : 1.0);
      _fillPaint.color = themeColor.withValues(alpha: alpha);

      final trailSize = player.size * (1.0 - (i / PlayerEntity.maxTrail) * 0.4);
      final offset = (player.size - trailSize) / 2;

      ShapeRenderer.drawShape(
        canvas: canvas,
        paint: _fillPaint,
        type: player.currentIcon.type,
        x: px + offset,
        y: py + offset,
        size: trailSize,
        emoji: player.currentIcon.emoji,
      );
    }

    // 3. Shield Glow & Ripple Ring
    if (player.hasShield) {
      _strokePaint
        ..strokeWidth = 4
        ..color = AppColors.shieldGreen.withValues(alpha: isGhost ? 0.4 : 1.0);

      canvas.drawCircle(
        Offset(player.x + player.size / 2, player.y + player.size / 2),
        player.size * 0.75,
        _strokePaint,
      );

      // Animated Expanding Ripple
      final now = DateTime.now().millisecondsSinceEpoch;
      final rippleProgress = (now % 1000) / 1000.0;
      final rippleRadius = player.size * (0.75 + rippleProgress * 0.6);
      final rippleAlpha = (1.0 - rippleProgress) * (isGhost ? 0.3 : 0.6);

      _strokePaint
        ..strokeWidth = 2
        ..color = AppColors.shieldGreen.withValues(alpha: rippleAlpha);
      canvas.drawCircle(
        Offset(player.x + player.size / 2, player.y + player.size / 2),
        rippleRadius,
        _strokePaint,
      );
    }

    // 4. Main Shape Body
    _fillPaint.color = themeColor.withValues(alpha: isGhost ? 0.6 : 1.0);
    ShapeRenderer.drawShape(
      canvas: canvas,
      paint: _fillPaint,
      type: player.currentIcon.type,
      x: player.x,
      y: player.y,
      size: player.size,
      emoji: player.currentIcon.emoji,
    );
  }

  void _drawFloatingTexts(Canvas canvas) {
    for (final ft in controller.floatingTexts) {
      final alpha = ft.alpha.clamp(0.0, 1.0);
      final tp = _getTextPainter(
        text: ft.text,
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );

      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(255, 255, 255, alpha));
      tp.paint(
        canvas,
        Offset(ft.x - tp.width / 2, ft.y - tp.height / 2),
      );
      canvas.restore();
    }
  }

  void _drawAlerts(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Speed Up Banner
    if (controller.speedUpIndicator > 0) {
      final alpha = (controller.speedUpIndicator / 60.0).clamp(0.0, 1.0);
      final tp = _getTextPainter(
        text: '⚡ SPEED UP!',
        style: const TextStyle(
          fontSize: 36,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      );
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(255, 255, 255, alpha));
      tp.paint(canvas, Offset(centerX - tp.width / 2, size.height * 0.3));
      canvas.restore();
    }

    // Level Up Banner
    if (controller.levelUpIndicator > 0) {
      final alpha = (controller.levelUpIndicator / 100.0).clamp(0.0, 1.0);
      final tp = _getTextPainter(
        text: '🏆 LEVEL UP!',
        style: const TextStyle(
          fontSize: 44,
          color: AppColors.gold,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
        ),
      );
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(255, 255, 255, alpha));
      tp.paint(canvas, Offset(centerX - tp.width / 2, size.height * 0.45));
      canvas.restore();
    }

    // Perfect Dodge Banner
    if (controller.perfectDodgeIndicator > 0) {
      final alpha = (controller.perfectDodgeIndicator / 40.0).clamp(0.0, 1.0);
      final tp = _getTextPainter(
        text: '⭐ PERFECT DODGE! +50',
        style: const TextStyle(
          fontSize: 26,
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
        ),
      );
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(255, 255, 255, alpha));
      tp.paint(canvas, Offset(centerX - tp.width / 2, size.height * 0.25));
      canvas.restore();
    }

    // Level Challenge Initial Banner
    if (controller.currentState == GameState.playing && controller.countdown > 0) {
      final double overlayHeight = 140;
      final overlayRect = Rect.fromCenter(
        center: Offset(centerX, size.height / 2),
        width: size.width * 0.9,
        height: overlayHeight,
      );

      canvas.drawRRect(RRect.fromRectAndRadius(overlayRect, const Radius.circular(16)), _bannerBgPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(overlayRect, const Radius.circular(16)), _bannerBorderPaint);

      final titlePainter = _getTextPainter(
        text: 'LEVEL ${controller.currentLevel} CHALLENGE',
        style: const TextStyle(
          fontSize: 22,
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      );
      titlePainter.paint(canvas, Offset(centerX - titlePainter.width / 2, size.height / 2 - 45));

      final subPainter = _getTextPainter(
        text: 'Reach ${controller.levelTargetScore} Total Score\nto complete this level!',
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.onSurface,
          height: 1.3,
        ),
      );
      subPainter.paint(canvas, Offset(centerX - subPainter.width / 2, size.height / 2 - 5));
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
