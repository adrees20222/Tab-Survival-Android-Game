import 'dart:math';
import 'package:flutter/material.dart';
import '../core/audio/audio_manager.dart';
import '../core/constants/app_colors.dart';
import '../core/storage/game_storage.dart';
import '../models/actor_icon.dart';
import '../models/collectible_item.dart';
import '../models/floating_text_item.dart';
import '../models/obstacle_item.dart';
import '../models/particle_item.dart';
import '../models/theme_color_item.dart';
import 'game_background.dart';
import 'player_entity.dart';

enum GameState {
  mainMenu,
  playing,
  paused,
  gameOver,
  shop,
  settings,
  about,
  highScores,
}

class GameController extends ChangeNotifier {
  final GameStorage storage;
  final AudioManager audio = AudioManager();

  GameState currentState = GameState.mainMenu;
  GameState previousState = GameState.mainMenu;

  double screenWidth = 400;
  double screenHeight = 800;

  late PlayerEntity player;
  late GameBackground background;

  // Customization inventories
  List<ActorIcon> allIcons = [];
  List<ThemeColorItem> playerColors = [];
  List<ActorIcon> obstacleShapes = [];
  List<ThemeColorItem> obstacleColors = [];
  List<ThemeColorItem> allSkins = [];

  late ActorIcon currentIcon;
  late ThemeColorItem currentTheme;
  late ActorIcon currentObstacleShape;
  late ThemeColorItem currentObstacleColor;
  late ThemeColorItem currentSkin;

  // Gameplay state
  int score = 0;
  int bonusScore = 0;
  int highScore = 0;
  int gems = 0;
  int bullets = 0;
  int superBullets = 0;

  int currentLevel = 1;
  int levelTargetScore = 5000;
  int lastLevelTargetScore = 0;

  int combo = 0;
  double comboMultiplier = 1.0;
  double obstacleSpeed = 15.0;
  double lastSpeed = 15.0;

  int magnetTimer = 0;
  int ghostTimer = 0;
  int feverTimer = 0;
  int starCombo = 0;
  int sameLaneCount = 0;
  double lastObstacleX = -1.0;

  int speedUpIndicator = 0;
  int levelUpIndicator = 0;
  int perfectDodgeIndicator = 0;
  int countdown = 0;
  bool isInitialCountdown = false;

  int shakeDuration = 0;
  final Random random = Random();

  DateTime? gameStartTime;
  DateTime? pauseStartTime;
  int lastSpawnTimeMs = 0;
  int lastItemSpawnTimeMs = 0;
  int lastObstacleSpawnTimeMs = 0;
  int lastPlayerTouchTimeMs = 0;
  int spawnIntervalMs = 1500;

  final List<ObstacleItem> obstacles = [];
  final List<CollectibleItem> collectibles = [];
  final List<ParticleItem> particles = [];
  final List<FloatingTextItem> floatingTexts = [];

  // Shop and settings tabs
  int shopTab = 0;
  int settingsTab = 0;

  // Lightweight HUD refresh notifier (~10Hz) to prevent full widget tree churn
  final ValueNotifier<int> hudNotifier = ValueNotifier<int>(0);
  int _frameCounter = 0;

  GameController(this.storage) {
    _loadFromStorage();
  }

  void init(double width, double height) {
    screenWidth = width;
    screenHeight = height;
    player.init(width, height);
    background = GameBackground(
      screenWidth: width,
      screenHeight: height,
      activeSkinColor: currentSkin.color,
    );
  }

  void _loadFromStorage() {
    highScore = storage.highScore;
    gems = storage.gems;
    bullets = storage.bullets;
    superBullets = storage.superBullets;
    currentLevel = storage.currentLevel;
    levelTargetScore = storage.levelTargetScore;
    lastLevelTargetScore = storage.lastLevelTargetScore;

    // Load icons
    allIcons = ActorIcon.getInitialIcons(currentLevel);
    final unlockedIconsList = storage.unlockedIcons.split(',');
    for (final icon in allIcons) {
      if (unlockedIconsList.contains(icon.id) || icon.unlockLevel <= currentLevel) {
        icon.unlocked = true;
      }
    }
    currentIcon = allIcons.firstWhere(
      (i) => i.id == storage.currentIconId && i.unlocked,
      orElse: () => allIcons.first,
    );

    // Load player colors
    playerColors = ThemeColorItem.getPlayerThemes();
    final unlockedPlayerThemesList = storage.unlockedPlayerThemes.split(',');
    for (final theme in playerColors) {
      if (unlockedPlayerThemesList.contains(theme.id)) {
        theme.unlocked = true;
      }
    }
    currentTheme = playerColors.firstWhere(
      (t) => t.id == storage.currentPlayerColorId && t.unlocked,
      orElse: () => playerColors.first,
    );

    // Load obstacle shapes
    obstacleShapes = ActorIcon.getObstacleShapes();
    final unlockedObstacleShapesList = storage.unlockedObstacleShapes.split(',');
    for (final shape in obstacleShapes) {
      if (unlockedObstacleShapesList.contains(shape.id)) {
        shape.unlocked = true;
      }
    }
    currentObstacleShape = obstacleShapes.firstWhere(
      (s) => s.id == storage.currentObstacleShapeId && s.unlocked,
      orElse: () => obstacleShapes.first,
    );

    // Load obstacle colors
    obstacleColors = ThemeColorItem.getObstacleColors();
    final unlockedThemesList = storage.unlockedThemes.split(',');
    for (final color in obstacleColors) {
      if (unlockedThemesList.contains(color.id)) {
        color.unlocked = true;
      }
    }
    currentObstacleColor = obstacleColors.firstWhere(
      (c) => c.id == storage.currentObstacleColorId && c.unlocked,
      orElse: () => obstacleColors.first,
    );

    // Load skins
    allSkins = ThemeColorItem.getSkins();
    final unlockedSkinsList = storage.unlockedSkins.split(',');
    for (final skin in allSkins) {
      if (unlockedSkinsList.contains(skin.id)) {
        skin.unlocked = true;
      }
    }
    currentSkin = allSkins.firstWhere(
      (s) => s.id == storage.currentSkinId && s.unlocked,
      orElse: () => allSkins.first,
    );

    player = PlayerEntity(
      currentIcon: currentIcon,
      currentTheme: currentTheme,
    );
  }

  void switchState(GameState newState) {
    if (currentState == newState) return;
    previousState = currentState;
    currentState = newState;

    if (newState == GameState.playing) {
      audio.startBgm();
    }
    notifyListeners();
  }

  void startGame() {
    obstacles.clear();
    collectibles.clear();
    particles.clear();
    floatingTexts.clear();

    score = 0;
    bonusScore = 0;
    combo = 0;
    comboMultiplier = 1.0;
    obstacleSpeed = 15.0;
    lastSpeed = 15.0;

    magnetTimer = 0;
    ghostTimer = 0;
    feverTimer = 0;
    starCombo = 0;
    sameLaneCount = 0;
    lastObstacleX = -1.0;
    countdown = 120;
    isInitialCountdown = true;

    lastLevelTargetScore = 0;
    levelTargetScore = 4000 + random.nextInt(2501);

    gameStartTime = DateTime.now();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    lastSpawnTimeMs = nowMs;
    lastItemSpawnTimeMs = nowMs;
    lastObstacleSpawnTimeMs = nowMs;

    player.reset();
    storage.clearSavedSession();

    switchState(GameState.playing);
  }

  void pauseGame() {
    if (currentState != GameState.playing) return;
    pauseStartTime = DateTime.now();
    _saveCurrentSession();
    switchState(GameState.paused);
  }

  void resumeGame() {
    if (pauseStartTime != null && gameStartTime != null) {
      final pausedDuration = DateTime.now().difference(pauseStartTime!);
      gameStartTime = gameStartTime!.add(pausedDuration);
      pauseStartTime = null;
    }
    switchState(GameState.playing);
  }

  void _saveCurrentSession() {
    if (gameStartTime == null) return;
    final elapsed = DateTime.now().difference(gameStartTime!).inMilliseconds;
    storage.saveGameSession(
      score: score,
      bonusScore: bonusScore,
      elapsedTime: elapsed,
      obstacleSpeed: obstacleSpeed,
      currentLevel: currentLevel,
      levelTargetScore: levelTargetScore,
      lastLevelTargetScore: lastLevelTargetScore,
      bullets: bullets,
      superBullets: superBullets,
    );
  }

  void updateGame() {
    // Update visual background
    background.update(currentState == GameState.playing ? obstacleSpeed : 10.0);

    // Update particles
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update();
      if (particles[i].isDead) {
        particles.removeAt(i);
      }
    }

    // Update floating texts
    for (int i = floatingTexts.length - 1; i >= 0; i--) {
      floatingTexts[i].update();
      if (floatingTexts[i].isDead) {
        floatingTexts.removeAt(i);
      }
    }

    if (shakeDuration > 0) shakeDuration--;

    if (currentState != GameState.playing) {
      return;
    }

    // Initial countdown
    if (countdown > 0) {
      countdown--;
      if (isInitialCountdown) {
        return;
      }
    }

    if (gameStartTime == null) return;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final elapsedMs = DateTime.now().difference(gameStartTime!).inMilliseconds;

    score = ((elapsedMs ~/ 500) * comboMultiplier).toInt() + bonusScore;
    obstacleSpeed = (elapsedMs / 12000.0) + 15.0;

    if (obstacleSpeed > lastSpeed + 1.0) {
      speedUpIndicator = 60;
      lastSpeed = obstacleSpeed;
    }

    if (speedUpIndicator > 0) speedUpIndicator--;
    if (levelUpIndicator > 0) levelUpIndicator--;
    if (perfectDodgeIndicator > 0) perfectDodgeIndicator--;

    spawnIntervalMs = max(600, 1500 - ((elapsedMs ~/ 10000) * 100));

    if (score >= levelTargetScore) {
      _levelUp();
    }

    // Spawn obstacles or fever stars
    if (nowMs - lastSpawnTimeMs > spawnIntervalMs) {
      if (feverTimer > 0) {
        collectibles.add(
          CollectibleItem(
            screenWidth: screenWidth,
            speed: obstacleSpeed,
            type: CollectibleType.star,
          ),
        );
      } else {
        final newObstacle = ObstacleItem(
          screenWidth: screenWidth,
          speed: obstacleSpeed,
        );

        if (newObstacle.x == lastObstacleX) {
          sameLaneCount++;
        } else {
          sameLaneCount = 0;
        }

        final bool laneSwitched = newObstacle.x != lastObstacleX;
        final double timeSinceLast = (nowMs - lastObstacleSpawnTimeMs).toDouble();

        if (laneSwitched && timeSinceLast < 600.0) {
          newObstacle.x = lastObstacleX;
          sameLaneCount++;
        } else if (!laneSwitched && sameLaneCount >= 3) {
          final double leftX = (screenWidth / 4) - (newObstacle.size / 2);
          final double rightX = (3 * screenWidth / 4) - (newObstacle.size / 2);
          newObstacle.x = (newObstacle.x == leftX) ? rightX : leftX;
          sameLaneCount = 0;
        }

        obstacles.add(newObstacle);
        lastObstacleX = newObstacle.x;
        lastObstacleSpawnTimeMs = nowMs;
      }
      lastSpawnTimeMs = nowMs;
    }

    // Spawn collectibles (shield, star, magnet, ghost, gem)
    if (nowMs - lastItemSpawnTimeMs > random.nextInt(4000) + 4000) {
      final double r = random.nextDouble();
      CollectibleType type;
      if (r < 0.25) {
        type = CollectibleType.star;
      } else if (r < 0.35) {
        type = CollectibleType.shield;
      } else if (r < 0.45) {
        type = CollectibleType.magnet;
      } else {
        type = (r < 0.55) ? CollectibleType.ghost : CollectibleType.gem;
      }

      collectibles.add(
        CollectibleItem(
          screenWidth: screenWidth,
          speed: obstacleSpeed,
          type: type,
        ),
      );

      // Gem cluster bonus spawn
      if (type == CollectibleType.gem && random.nextDouble() < 0.15) {
        for (int j = 1; j <= 2; j++) {
          collectibles.add(
            CollectibleItem(
              screenWidth: screenWidth,
              speed: obstacleSpeed,
              type: CollectibleType.gem,
              initialY: -(screenWidth / 10) * (j + 1) * 2,
            ),
          );
        }
      }
      lastItemSpawnTimeMs = nowMs;
    }

    player.update();

    // Update collectibles
    for (int i = collectibles.length - 1; i >= 0; i--) {
      final c = collectibles[i];
      c.update();

      // Magnet attraction
      if (magnetTimer > 0 && (c.type == CollectibleType.star || c.type == CollectibleType.gem)) {
        final double dx = (player.x + player.size / 2) - (c.x + c.size / 2);
        final double dy = (player.y + player.size / 2) - (c.y + c.size / 2);
        final double dist = sqrt(dx * dx + dy * dy);
        if (dist < screenWidth * 0.6) {
          c.x += dx * 0.15;
          c.y += dy * 0.15;
        }
      }

      // Collectible collision with player
      if (player.collisionRect.overlaps(c.collisionRect)) {
        audio.vibrateLight();
        audio.playCollect();

        Color collColor = AppColors.gold;
        String emojiChar = '✨';

        switch (c.type) {
          case CollectibleType.shield:
            player.hasShield = true;
            collColor = AppColors.shieldGreen;
            emojiChar = '🛡️';
            audio.playShield();
            break;
          case CollectibleType.magnet:
            magnetTimer = 600;
            collColor = AppColors.magnetPink;
            emojiChar = '🧲';
            audio.playMagnet();
            break;
          case CollectibleType.ghost:
            ghostTimer = 600;
            collColor = AppColors.ghostBlue;
            emojiChar = '👻';
            audio.playGhost();
            break;
          case CollectibleType.gem:
            gems += 2;
            bonusScore += 50;
            storage.setGems(gems);
            collColor = AppColors.gemPurple;
            emojiChar = '💎';
            break;
          case CollectibleType.star:
            bonusScore += (elapsedMs ~/ 1000) + 25;
            collColor = AppColors.gold;
            emojiChar = '⭐';
            if (feverTimer == 0) {
              starCombo++;
              if (starCombo >= 5) {
                feverTimer = 180;
                starCombo = 0;
                audio.vibrateMedium();
                audio.playFever();
              }
            }
            break;
        }

        _triggerCollectEffect(c.x + c.size / 2, c.y + c.size / 2, emojiChar, collColor);
        collectibles.removeAt(i);
      } else if (c.isOffScreen(screenHeight)) {
        collectibles.removeAt(i);
      }
    }

    if (magnetTimer > 0) magnetTimer--;
    if (ghostTimer > 0) ghostTimer--;
    if (feverTimer > 0) feverTimer--;

    // Update obstacles
    for (int i = obstacles.length - 1; i >= 0; i--) {
      final o = obstacles[i];
      o.update();

      // Crash check if not in ghost or fever mode
      if (ghostTimer == 0 && feverTimer == 0 && player.collisionRect.overlaps(o.collisionRect)) {
        if (!player.hasShield) {
          // Game over!
          currentState = GameState.gameOver;
          combo = 0;
          comboMultiplier = 1.0;
          shakeDuration = 0;
          _triggerExplosion(player.x + player.size / 2, player.y + player.size / 2, currentTheme.color);
          audio.vibrateHeavy();
          audio.playCrash();

          if (score > highScore) {
            highScore = score;
            storage.setHighScore(highScore);
          }
          storage.clearSavedSession();
          notifyListeners();
          return;
        } else {
          // Shield absorbed impact
          player.hasShield = false;
          obstacles.removeAt(i);
          shakeDuration = 10;
          _triggerExplosion(o.x + o.size / 2, o.y + o.size / 2, currentObstacleColor.color);
          audio.vibrateMedium();
          audio.playCrash();
        }
      }

      if (o.isOffScreen(screenHeight)) {
        obstacles.removeAt(i);
        combo++;
        comboMultiplier = (combo / 10.0) + 1.0;
      }
    }

    _frameCounter++;
    if (_frameCounter % 6 == 0) {
      hudNotifier.value = _frameCounter;
    }
  }

  void _levelUp() {
    levelUpIndicator = 100;
    currentLevel++;
    lastLevelTargetScore = levelTargetScore;
    levelTargetScore += random.nextInt(2501) + 4000;
    isInitialCountdown = false;
    countdown = 120;

    // Check newly unlocked icons
    for (final icon in allIcons) {
      if (icon.unlockLevel <= currentLevel) {
        icon.unlocked = true;
      }
    }

    audio.playLevelUp();
    audio.vibratePattern();

    storage.setCurrentLevel(currentLevel);
    storage.setLevelTargetScore(levelTargetScore);
    storage.setLastLevelTargetScore(lastLevelTargetScore);
    notifyListeners();
  }

  void handleTap(Offset position) {
    if (currentState == GameState.playing) {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check if tap was on player for shooting
      final playerTapRect = Rect.fromLTWH(
        player.x - player.size * 0.5,
        player.y - player.size * 0.5,
        player.size * 2,
        player.size * 2,
      );

      if (playerTapRect.contains(position)) {
        if (now - lastPlayerTouchTimeMs < 400) {
          shoot();
          lastPlayerTouchTimeMs = 0;
          return;
        } else {
          lastPlayerTouchTimeMs = now;
          return;
        }
      }

      // Normal lane switch
      player.toggleLane();
      _onPlayerToggleLane();
    }
  }

  void _onPlayerToggleLane() {
    audio.vibrateLight();
    audio.playSwitchLane();

    // Check perfect dodge
    for (final o in obstacles) {
      final double distY = (o.y - player.y).abs();
      final double laneX = (player.isLeftLane ? (3 * screenWidth / 4) : (screenWidth / 4)) - (o.size / 2);
      if (distY < 300.0 && (o.x - laneX).abs() < 20.0) {
        perfectDodgeIndicator = 40;
        bonusScore += 50;
        audio.vibrateMedium();
        break;
      }
    }
  }

  void shoot() {
    if (superBullets > 0) {
      superBullets--;
      storage.setSuperBullets(superBullets);
      for (final o in obstacles) {
        _triggerExplosion(o.x + o.size / 2, o.y + o.size / 2, currentObstacleColor.color);
      }
      obstacles.clear();
      audio.vibrateHeavy();
      return;
    }

    if (bullets <= 0) return;
    bullets--;
    storage.setBullets(bullets);

    // Find nearest obstacle in same lane ahead of player
    ObstacleItem? target;
    double minDist = double.infinity;
    for (final o in obstacles) {
      final double distY = player.y - o.y;
      if (distY > 0 && distY < minDist && (o.x - player.x).abs() < screenWidth / 2) {
        minDist = distY;
        target = o;
      }
    }

    if (target != null) {
      _triggerExplosion(target.x + target.size / 2, target.y + target.size / 2, currentObstacleColor.color);
      obstacles.remove(target);
      audio.vibrateMedium();
    } else {
      audio.vibrateLight();
    }
  }

  void _triggerExplosion(double x, double y, Color color) {
    if (particles.length > 40) {
      particles.removeRange(0, particles.length - 20);
    }
    for (int i = 0; i < 12; i++) {
      particles.add(ParticleItem(x: x, y: y, color: color));
    }
  }

  void _triggerCollectEffect(double x, double y, String emoji, Color color) {
    if (floatingTexts.length > 5) {
      floatingTexts.removeAt(0);
    }
    floatingTexts.add(FloatingTextItem(x: x, y: y, text: emoji));
    _triggerExplosion(x, y, color);
  }

  // Shop purchase methods
  bool buyObstacleShape(ActorIcon shape) {
    if (shape.unlocked) {
      currentObstacleShape = shape;
      storage.setCurrentObstacleShapeId(shape.id);
      notifyListeners();
      return true;
    } else if (gems >= shape.price) {
      gems -= shape.price;
      shape.unlocked = true;
      currentObstacleShape = shape;

      final updated = '${storage.unlockedObstacleShapes},${shape.id}';
      storage.setUnlockedObstacleShapes(updated);
      storage.setGems(gems);
      storage.setCurrentObstacleShapeId(shape.id);
      audio.vibrateMedium();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool buyObstacleColor(ThemeColorItem color) {
    if (color.unlocked) {
      currentObstacleColor = color;
      storage.setCurrentObstacleColorId(color.id);
      notifyListeners();
      return true;
    } else if (gems >= color.price) {
      gems -= color.price;
      color.unlocked = true;
      currentObstacleColor = color;

      final updated = '${storage.unlockedThemes},${color.id}';
      storage.setUnlockedThemes(updated);
      storage.setGems(gems);
      storage.setCurrentObstacleColorId(color.id);
      audio.vibrateMedium();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool buySkin(ThemeColorItem skin) {
    if (skin.unlocked) {
      currentSkin = skin;
      background.activeSkinColor = skin.color;
      storage.setCurrentSkinId(skin.id);
      notifyListeners();
      return true;
    } else if (gems >= skin.price) {
      gems -= skin.price;
      skin.unlocked = true;
      currentSkin = skin;
      background.activeSkinColor = skin.color;

      final updated = '${storage.unlockedSkins},${skin.id}';
      storage.setUnlockedSkins(updated);
      storage.setGems(gems);
      storage.setCurrentSkinId(skin.id);
      audio.vibrateMedium();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool buyBullets() {
    if (gems >= 10) {
      gems -= 10;
      bullets++;
      storage.setGems(gems);
      storage.setBullets(bullets);
      audio.vibrateMedium();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool buySuperBullets() {
    if (gems >= 15) {
      gems -= 15;
      superBullets++;
      storage.setGems(gems);
      storage.setSuperBullets(superBullets);
      audio.vibrateHeavy();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Character select methods
  bool selectActorIcon(ActorIcon icon) {
    if (icon.unlocked) {
      currentIcon = icon;
      player.currentIcon = icon;
      storage.setCurrentIconId(icon.id);
      notifyListeners();
      return true;
    }
    return false;
  }

  bool selectPlayerTheme(ThemeColorItem theme) {
    if (theme.unlocked) {
      currentTheme = theme;
      player.currentTheme = theme;
      storage.setCurrentPlayerColorId(theme.id);
      notifyListeners();
      return true;
    } else if (gems >= theme.price) {
      gems -= theme.price;
      theme.unlocked = true;
      currentTheme = theme;
      player.currentTheme = theme;

      final updated = '${storage.unlockedPlayerThemes},${theme.id}';
      storage.setUnlockedPlayerThemes(updated);
      storage.setGems(gems);
      storage.setCurrentPlayerColorId(theme.id);
      audio.vibrateMedium();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Preferences toggles
  void toggleMusic() {
    final next = !audio.musicEnabled;
    audio.setMusicEnabled(next);
    storage.setMusicEnabled(next);
    audio.vibrateLight();
    notifyListeners();
  }

  void toggleSound() {
    audio.soundEnabled = !audio.soundEnabled;
    storage.setSoundEnabled(audio.soundEnabled);
    audio.vibrateLight();
    notifyListeners();
  }

  void toggleVibration() {
    audio.vibrationEnabled = !audio.vibrationEnabled;
    storage.setVibrationEnabled(audio.vibrationEnabled);
    audio.vibrateLight();
    notifyListeners();
  }

  double get levelProgress {
    final range = levelTargetScore - lastLevelTargetScore;
    if (range <= 0) return 0.0;
    return ((score - lastLevelTargetScore) / range).clamp(0.0, 1.0);
  }

  double get shakeOffsetX {
    if (shakeDuration > 0) {
      return (random.nextDouble() - 0.5) * 20.0;
    }
    return 0.0;
  }

  double get shakeOffsetY {
    if (shakeDuration > 0) {
      return (random.nextDouble() - 0.5) * 20.0;
    }
    return 0.0;
  }
}
