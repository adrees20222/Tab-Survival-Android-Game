import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../game/game_controller.dart';
import '../widgets/custom_action_button.dart';
import '../widgets/level_badge.dart';

class MainMenuView extends StatelessWidget {
  final GameController controller;

  const MainMenuView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            controller.currentSkin.color.withValues(alpha: 0.92),
            AppColors.background.withValues(alpha: 0.96),
          ],
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      width: 110,
                      height: 110,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.games_rounded,
                        size: 90,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    const Text(
                      'TAP SURVIVAL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(color: AppColors.primaryContainer, blurRadius: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Level Badge
                    LevelBadge(
                      level: controller.currentLevel,
                      progress: controller.levelProgress,
                    ),
                    const SizedBox(height: 32),

                    // Menu Buttons
                    CustomActionButton(
                      text: 'NEW GAME',
                      isPrimary: true,
                      onPressed: () => controller.startGame(),
                    ),
                    CustomActionButton(
                      text: 'SHOP',
                      isPrimary: false,
                      leading: const Text('🛒', style: TextStyle(fontSize: 20)),
                      onPressed: () => controller.switchState(GameState.shop),
                    ),
                    CustomActionButton(
                      text: 'HIGH SCORES',
                      isPrimary: false,
                      leading: const Text('🏆', style: TextStyle(fontSize: 20)),
                      onPressed: () => controller.switchState(GameState.highScores),
                    ),
                    CustomActionButton(
                      text: 'SETTINGS',
                      isPrimary: false,
                      leading: const Text('⚙️', style: TextStyle(fontSize: 20)),
                      onPressed: () => controller.switchState(GameState.settings),
                    ),
                    CustomActionButton(
                      text: 'ABOUT',
                      isPrimary: false,
                      leading: const Text('ℹ️', style: TextStyle(fontSize: 20)),
                      onPressed: () => controller.switchState(GameState.about),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
