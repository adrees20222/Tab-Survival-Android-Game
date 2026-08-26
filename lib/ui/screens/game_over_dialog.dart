import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../game/game_controller.dart';
import '../widgets/custom_action_button.dart';

class GameOverDialog extends StatelessWidget {
  final GameController controller;

  const GameOverDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isNewHighScore = controller.score >= controller.highScore && controller.score > 0;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.dangerRed, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.dangerRed.withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: AppColors.dangerRed,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),

            if (isNewHighScore)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold),
                ),
                child: const Text(
                  '🎉 NEW HIGH SCORE!',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            Text(
              'Final Score: ${controller.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'High Score: ${controller.highScore}',
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💎 Gems: ', style: TextStyle(color: AppColors.secondary, fontSize: 16)),
                Text(
                  '${controller.gems}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            CustomActionButton(
              text: 'RETRY',
              isPrimary: true,
              height: 50,
              widthPercent: 0.65,
              onPressed: () => controller.startGame(),
            ),
            CustomActionButton(
              text: 'MAIN MENU',
              isPrimary: false,
              height: 50,
              widthPercent: 0.65,
              onPressed: () => controller.switchState(GameState.mainMenu),
            ),
          ],
        ),
      ),
    );
  }
}
