import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../game/game_controller.dart';
import '../widgets/custom_action_button.dart';

class HighScoresView extends StatelessWidget {
  final GameController controller;

  const HighScoresView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'HIGH SCORES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your best survival records',
              style: TextStyle(color: AppColors.secondary, fontSize: 14),
            ),
            const SizedBox(height: 36),

            // High Score Card
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.tertiary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tertiary.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'BEST SCORE',
                    style: TextStyle(
                      color: AppColors.tertiary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${controller.highScore}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('💎 Total Gems: ', style: TextStyle(color: AppColors.secondary, fontSize: 16)),
                      Text(
                        '${controller.gems}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),
            CustomActionButton(
              text: 'BACK',
              isPrimary: false,
              height: 48,
              widthPercent: 0.6,
              onPressed: () => controller.switchState(GameState.mainMenu),
            ),
          ],
        ),
      ),
    );
  }
}
