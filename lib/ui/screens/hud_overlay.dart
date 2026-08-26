import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../game/game_controller.dart';
import '../widgets/circular_powerup_timer.dart';

class HudOverlay extends StatelessWidget {
  final GameController controller;

  const HudOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Top Bar: Score & Combo & Pause Button
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gems Counter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('💎 ', style: TextStyle(fontSize: 14)),
                          Text(
                            '${controller.gems}',
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center Score & Combo
                    Column(
                      children: [
                        Text(
                          'Score: ${controller.score}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 8),
                            ],
                          ),
                        ),
                        if (controller.combo > 1) ...[
                          const SizedBox(height: 2),
                          Text(
                            'COMBO X${controller.comboMultiplier.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Pause Button
                    IconButton(
                      icon: const Icon(Icons.pause_circle_filled, size: 36, color: Colors.white70),
                      onPressed: () => controller.pauseGame(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Level Progress Bar
                Container(
                  width: 220,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: controller.levelProgress,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'LVL ${controller.currentLevel}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Left Side: Active Powerup Timers
          Positioned(
            top: 120,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircularPowerupTimer(
                  label: 'MAG',
                  emoji: '🧲',
                  currentFrames: controller.magnetTimer,
                  maxFrames: 600,
                  accentColor: AppColors.magnetPink,
                ),
                CircularPowerupTimer(
                  label: 'GST',
                  emoji: '👻',
                  currentFrames: controller.ghostTimer,
                  maxFrames: 600,
                  accentColor: AppColors.ghostBlue,
                ),
                CircularPowerupTimer(
                  label: 'FEV',
                  emoji: '🔥',
                  currentFrames: controller.feverTimer,
                  maxFrames: 180,
                  accentColor: AppColors.gold,
                ),
              ],
            ),
          ),

          // Bottom Bar: Bullets Info (Unlocked at level 5+)
          if (controller.currentLevel >= 5)
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔫 ', style: TextStyle(fontSize: 16)),
                    Text(
                      '${controller.bullets}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (controller.currentLevel >= 10) ...[
                      const SizedBox(width: 14),
                      const Text('🧨 ', style: TextStyle(fontSize: 16)),
                      Text(
                        '${controller.superBullets}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
