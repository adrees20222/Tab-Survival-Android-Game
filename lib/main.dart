import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/audio/audio_manager.dart';
import 'core/constants/app_colors.dart';
import 'core/storage/game_storage.dart';
import 'game/game_controller.dart';
import 'game/game_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive Sticky Fullscreen mode (hides navigation & status bars like original native Android app)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Lock orientation to portrait for optimal mobile gaming experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize storage
  final storage = await GameStorage.init();

  // Initialize audio manager
  await AudioManager().init(
    music: storage.musicEnabled,
    sound: storage.soundEnabled,
    vibration: storage.vibrationEnabled,
  );

  // Create game controller
  final controller = GameController(storage);

  runApp(TapSurvivalApp(controller: controller));
}

class TapSurvivalApp extends StatelessWidget {
  final GameController controller;

  const TapSurvivalApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Survival',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          surfaceContainerHighest: AppColors.surfaceVariant,
          outline: AppColors.outline,
        ),
        useMaterial3: true,
      ),
      home: GameView(controller: controller),
    );
  }
}
