import 'package:flutter/material.dart';
import '../game/game_controller.dart';
import '../rendering/game_painter.dart';
import '../ui/screens/about_view.dart';
import '../ui/screens/game_over_dialog.dart';
import '../ui/screens/high_scores_view.dart';
import '../ui/screens/hud_overlay.dart';
import '../ui/screens/main_menu_view.dart';
import '../ui/screens/pause_dialog.dart';
import '../ui/screens/settings_view.dart';
import '../ui/screens/shop_view.dart';

class GameView extends StatefulWidget {
  final GameController controller;

  const GameView({super.key, required this.controller});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_gameLoop);

    _animController.repeat();
  }

  void _gameLoop() {
    if (_initialized) {
      widget.controller.updateGame();
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_gameLoop);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: controller.currentSkin.color,
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (!_initialized) {
                controller.init(constraints.maxWidth, constraints.maxHeight);
                _initialized = true;
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Core 60+ FPS CustomPainter Game Canvas
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: GamePainter(controller),
                  ),

                  // 2. In-Game Tap Area (for lane switching & shooting during gameplay)
                  if (controller.currentState == GameState.playing)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown: (details) {
                          controller.handleTap(details.localPosition);
                        },
                      ),
                    ),

                  // 3. Dynamic UI Overlay Layer (rebuilds reactively on state changes)
                  _buildActiveScreen(controller),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActiveScreen(GameController controller) {
    switch (controller.currentState) {
      case GameState.mainMenu:
        return MainMenuView(controller: controller);

      case GameState.playing:
        return HudOverlay(controller: controller);

      case GameState.paused:
        return Stack(
          fit: StackFit.expand,
          children: [
            HudOverlay(controller: controller),
            Container(
              color: Colors.black54,
              child: PauseDialog(controller: controller),
            ),
          ],
        );

      case GameState.gameOver:
        return Container(
          color: Colors.black87,
          child: GameOverDialog(controller: controller),
        );

      case GameState.shop:
        return Container(
          color: controller.currentSkin.color.withValues(alpha: 0.98),
          child: ShopView(controller: controller),
        );

      case GameState.settings:
        return Container(
          color: controller.currentSkin.color.withValues(alpha: 0.98),
          child: SettingsView(controller: controller),
        );

      case GameState.highScores:
        return Container(
          color: controller.currentSkin.color.withValues(alpha: 0.98),
          child: HighScoresView(controller: controller),
        );

      case GameState.about:
        return Container(
          color: controller.currentSkin.color.withValues(alpha: 0.98),
          child: AboutView(controller: controller),
        );
    }
  }
}
