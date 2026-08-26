import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../game/game_controller.dart';
import '../widgets/custom_action_button.dart';

class PauseDialog extends StatelessWidget {
  final GameController controller;

  const PauseDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME PAUSED',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Current Score: ${controller.score}',
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 28),

            CustomActionButton(
              text: 'CONTINUE',
              isPrimary: true,
              height: 50,
              widthPercent: 0.65,
              onPressed: () => controller.resumeGame(),
            ),
            CustomActionButton(
              text: 'RETRY',
              isPrimary: false,
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
