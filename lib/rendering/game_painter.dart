import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../game/game_controller.dart';
import '../models/collectible_item.dart';
import 'shape_renderer.dart';

class GamePainter extends CustomPainter {
  final GameController controller;

  GamePainter(this.controller) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    // Apply camera shake if active
    if (controller.shakeDuration > 0) {
      canvas.save();
      canvas.translate(controller.shakeOffsetX, controller.shakeOffsetY);
    }

    // 1. Draw Background
    controller.background.draw(canvas, size);

    // 2. Draw Particles
    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (final p in controller.particles) {
      particlePaint.color = p.color.withValues(alpha: p.alpha.clamp(0.0, 1.0));
      canvas.drawRect(Rect.fromLTWH(p.x, p.y, p.size, p.size), particlePaint);
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
    final paint = Paint()..style = PaintingStyle.fill;

    for (final c in controller.collectibles) {
      switch (c.type) {
        case CollectibleType.shield:
          paint.color = AppColors.shieldGreen;
          canvas.drawCircle(Offset(c.x + c.size / 2, c.y + c.size / 2), c.size / 2, paint);
          final textPainter = TextPainter(
            text: TextSpan(
              text: '🛡️',
              style: TextStyle(fontSize: c.size * 0.65),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          textPainter.paint(
            canvas,
            Offset(c.x + (c.size - textPainter.width) / 2, c.y + (c.size - textPainter.height) / 2),
          );
          break;

        case CollectibleType.star:
          paint.color = AppColors.gold;
          canvas.save();
          canvas.translate(c.x + c.size / 2, c.y + c.size / 2);
          canvas.rotate(pi / 4);
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: c.size * 0.8, height: c.size * 0.8),
            paint,
          );
          canvas.restore();
          break;

        case CollectibleType.magnet:
          paint.color = AppColors.magnetPink;
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(c.x, c.y, c.size, c.size), const Radius.circular(8)),
            paint,
          );
          final textPainter = TextPainter(
            text: TextSpan(
              text: '🧲',
              style: TextStyle(fontSize: c.size * 0.65),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          textPainter.paint(
            canvas,
            Offset(c.x + (c.size - textPainter.width) / 2, c.y + (c.size - textPainter.height) / 2),
          );
          break;

        case CollectibleType.ghost:
          paint.color = AppColors.ghostBlue.withValues(alpha: 0.8);
          canvas.drawCircle(Offset(c.x + c.size / 2, c.y + c.size / 2), c.size / 2, paint);
          final textPainter = TextPainter(
            text: TextSpan(
              text: '👻',
              style: TextStyle(fontSize: c.size * 0.65),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          textPainter.paint(
            canvas,
            Offset(c.x + (c.size - textPainter.width) / 2, c.y + (c.size - textPainter.height) / 2),
          );
          break;

        case CollectibleType.gem:
          paint.color = AppColors.gemPurple;
          canvas.save();
          canvas.translate(c.x + c.size / 2, c.y + c.size / 2);
          canvas.rotate(pi / 4);
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: c.size * 0.8, height: c.size * 0.8),
            paint,
          );
          canvas.restore();
          break;
      }
    }
  }

  void _drawObstacles(Canvas canvas) {
    final shape = controller.currentObstacleShape.type;
    final color = controller.currentObstacleColor.color;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final o in controller.obstacles) {
      // Shifter warning border
      if (o.isShifter && !o.hasShifted) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.white;
        ShapeRenderer.drawShape(
          canvas: canvas,
          paint: paint,
          type: shape,
          x: o.x,
          y: o.y,
          size: o.size,
        );
        paint.style = PaintingStyle.fill;
      }

      paint.color = color;
      ShapeRenderer.drawShape(
        canvas: canvas,
        paint: paint,
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

    Color themeColor = isFever ? AppColors.gold : controller.currentTheme.color;
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Neon Glow Pass
    paint.color = themeColor.withValues(alpha: isGhost ? 0.15 : 0.35);
    final glowSize = player.size * 1.25;
    final glowOffset = (glowSize - player.size) / 2;
    ShapeRenderer.drawShape(
      canvas: canvas,
      paint: paint,
      type: player.currentIcon.type,
      x: player.x - glowOffset,
      y: player.y - glowOffset,
      size: glowSize,
      emoji: player.currentIcon.emoji,
    );

    // 2. Trail Pass
    for (int i = 0; i < player.trailPositions.length; i++) {
      final pos = player.trailPositions[i];
      final trailRatio = 1.0 - (i / player.trailPositions.length);
      final alpha = (0.5 * trailRatio) * (isGhost ? 0.4 : 1.0);
      paint.color = themeColor.withValues(alpha: alpha);

      final trailSize = player.size * (1.0 - (i / player.trailPositions.length) * 0.4);
      final offset = (player.size - trailSize) / 2;

      ShapeRenderer.drawShape(
        canvas: canvas,
        paint: paint,
        type: player.currentIcon.type,
        x: pos.dx + offset,
        y: pos.dy + offset,
        size: trailSize,
        emoji: player.currentIcon.emoji,
      );
    }

    // 3. Shield Glow & Ripple Ring
    if (player.hasShield) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = AppColors.shieldGreen.withValues(alpha: isGhost ? 0.4 : 1.0);

      canvas.drawCircle(
        Offset(player.x + player.size / 2, player.y + player.size / 2),
        player.size * 0.75,
        paint,
      );

      // Animated Expanding Ripple
      final now = DateTime.now().millisecondsSinceEpoch;
      final rippleProgress = (now % 1000) / 1000.0;
      final rippleRadius = player.size * (0.75 + rippleProgress * 0.6);
      final rippleAlpha = (1.0 - rippleProgress) * (isGhost ? 0.3 : 0.6);

      paint
        ..strokeWidth = 2
        ..color = AppColors.shieldGreen.withValues(alpha: rippleAlpha);
      canvas.drawCircle(
        Offset(player.x + player.size / 2, player.y + player.size / 2),
        rippleRadius,
        paint,
      );

      paint.style = PaintingStyle.fill;
    }

    // 4. Main Shape Body
    paint.color = themeColor.withValues(alpha: isGhost ? 0.6 : 1.0);
    ShapeRenderer.drawShape(
      canvas: canvas,
      paint: paint,
      type: player.currentIcon.type,
      x: player.x,
      y: player.y,
      size: player.size,
      emoji: player.currentIcon.emoji,
    );
  }

  void _drawFloatingTexts(Canvas canvas) {
    for (final ft in controller.floatingTexts) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: ft.text,
          style: TextStyle(
            fontSize: 28,
            color: Colors.white.withValues(alpha: ft.alpha.clamp(0.0, 1.0)),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(ft.x - textPainter.width / 2, ft.y - textPainter.height / 2),
      );
    }
  }

  void _drawAlerts(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Speed Up Banner
    if (controller.speedUpIndicator > 0) {
      final alpha = (controller.speedUpIndicator / 60.0).clamp(0.0, 1.0);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '⚡ SPEED UP!',
          style: TextStyle(
            fontSize: 36,
            color: Colors.white.withValues(alpha: alpha),
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, size.height * 0.3));
    }

    // Level Up Banner
    if (controller.levelUpIndicator > 0) {
      final alpha = (controller.levelUpIndicator / 100.0).clamp(0.0, 1.0);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '🏆 LEVEL UP!',
          style: TextStyle(
            fontSize: 44,
            color: AppColors.gold.withValues(alpha: alpha),
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, size.height * 0.45));
    }

    // Perfect Dodge Banner
    if (controller.perfectDodgeIndicator > 0) {
      final alpha = (controller.perfectDodgeIndicator / 40.0).clamp(0.0, 1.0);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '⭐ PERFECT DODGE! +50',
          style: TextStyle(
            fontSize: 26,
            color: AppColors.gold.withValues(alpha: alpha),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, size.height * 0.25));
    }

    // Level Challenge Initial Banner
    if (controller.currentState == GameState.playing && controller.countdown > 0) {
      final double overlayHeight = 140;
      final overlayRect = Rect.fromCenter(
        center: Offset(centerX, size.height / 2),
        width: size.width * 0.9,
        height: overlayHeight,
      );

      final bgPaint = Paint()
        ..color = AppColors.surface.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(RRect.fromRectAndRadius(overlayRect, const Radius.circular(16)), bgPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(overlayRect, const Radius.circular(16)), borderPaint);

      final titlePainter = TextPainter(
        text: TextSpan(
          text: 'LEVEL ${controller.currentLevel} CHALLENGE',
          style: const TextStyle(
            fontSize: 22,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      titlePainter.paint(canvas, Offset(centerX - titlePainter.width / 2, size.height / 2 - 45));

      final subPainter = TextPainter(
        text: TextSpan(
          text: 'Reach ${controller.levelTargetScore} Total Score\nto complete this level!',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.onSurface,
            height: 1.3,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      subPainter.paint(canvas, Offset(centerX - subPainter.width / 2, size.height / 2 - 5));
    }
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
