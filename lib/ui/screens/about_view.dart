import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../game/game_controller.dart';
import '../widgets/custom_action_button.dart';

class AboutView extends StatelessWidget {
  final GameController controller;

  const AboutView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'ABOUT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap Survival: Reflex Challenge (Flutter Edition)',
              style: TextStyle(color: AppColors.secondary, fontSize: 14),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.3)),
              ),
              child: const Column(
                children: [
                  Text(
                    'Developed by:\nMuhammad Adrees\n+923077377945',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Avoid blocks, collect gems & power-ups,\nand survive as long as you can!\n\nRe-engineered in Flutter for\nbutter-smooth 60+ FPS performance\nand enhanced responsive gameplay.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      height: 1.5,
                    ),
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
