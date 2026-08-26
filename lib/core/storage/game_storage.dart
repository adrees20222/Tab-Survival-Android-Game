import 'package:shared_preferences/shared_preferences.dart';

class GameStorage {
  static const String _keyHighScore = 'highScore';
  static const String _keyGems = 'gems';
  static const String _keyBullets = 'bullets';
  static const String _keySuperBullets = 'superBullets';
  static const String _keyCurrentLevel = 'currentLevel';
  static const String _keyLevelTargetScore = 'levelTargetScore';
  static const String _keyLastLevelTargetScore = 'lastLevelTargetScore';
  static const String _keyUnlockedIcons = 'unlockedIcons';
  static const String _keyUnlockedThemes = 'unlockedThemes';
  static const String _keyUnlockedPlayerThemes = 'unlockedPlayerThemes';
  static const String _keyUnlockedObstacleShapes = 'unlockedObstacleShapes';
  static const String _keyUnlockedSkins = 'unlockedSkins';
  static const String _keyCurrentIconId = 'currentIconId';
  static const String _keyCurrentPlayerColorId = 'currentPlayerColorId';
  static const String _keyCurrentObstacleShapeId = 'currentObstacleShapeId';
  static const String _keyCurrentObstacleColorId = 'currentObstacleColorId';
  static const String _keyCurrentSkinId = 'currentSkinId';
  static const String _keySoundEnabled = 'soundEnabled';
  static const String _keyMusicEnabled = 'musicEnabled';
  static const String _keyVibrationEnabled = 'vibrationEnabled';
  static const String _keyHasSavedGame = 'hasSavedGame';
  static const String _keySavedScore = 'savedScore';
  static const String _keySavedBonusScore = 'savedBonusScore';
  static const String _keySavedElapsedTime = 'savedElapsedTime';
  static const String _keySavedObstacleSpeed = 'savedObstacleSpeed';
  static const String _keySavedCurrentLevel = 'savedCurrentLevel';
  static const String _keySavedLevelTargetScore = 'savedLevelTargetScore';
  static const String _keySavedLastLevelTargetScore = 'savedLastLevelTargetScore';
  static const String _keySavedBullets = 'savedBullets';
  static const String _keySavedSuperBullets = 'savedSuperBullets';

  final SharedPreferences prefs;

  GameStorage(this.prefs);

  static Future<GameStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return GameStorage(prefs);
  }

  // Getters
  int get highScore => prefs.getInt(_keyHighScore) ?? 0;
  int get gems => prefs.getInt(_keyGems) ?? 0;
  int get bullets => prefs.getInt(_keyBullets) ?? 0;
  int get superBullets => prefs.getInt(_keySuperBullets) ?? 0;
  int get currentLevel => prefs.getInt(_keyCurrentLevel) ?? 1;
  int get levelTargetScore => prefs.getInt(_keyLevelTargetScore) ?? 5000;
  int get lastLevelTargetScore => prefs.getInt(_keyLastLevelTargetScore) ?? 0;

  String get unlockedIcons => prefs.getString(_keyUnlockedIcons) ?? 'default,circle,triangle';
  String get unlockedThemes => prefs.getString(_keyUnlockedThemes) ?? 'danger_red';
  String get unlockedPlayerThemes => prefs.getString(_keyUnlockedPlayerThemes) ?? 'default';
  String get unlockedObstacleShapes => prefs.getString(_keyUnlockedObstacleShapes) ?? 'square,circle,triangle';
  String get unlockedSkins => prefs.getString(_keyUnlockedSkins) ?? 'default';

  String get currentIconId => prefs.getString(_keyCurrentIconId) ?? 'default';
  String get currentPlayerColorId => prefs.getString(_keyCurrentPlayerColorId) ?? 'default';
  String get currentObstacleShapeId => prefs.getString(_keyCurrentObstacleShapeId) ?? 'square';
  String get currentObstacleColorId => prefs.getString(_keyCurrentObstacleColorId) ?? 'danger_red';
  String get currentSkinId => prefs.getString(_keyCurrentSkinId) ?? 'default';

  bool get soundEnabled => prefs.getBool(_keySoundEnabled) ?? true;
  bool get musicEnabled => prefs.getBool(_keyMusicEnabled) ?? true;
  bool get vibrationEnabled => prefs.getBool(_keyVibrationEnabled) ?? true;

  bool get hasSavedGame => prefs.getBool(_keyHasSavedGame) ?? false;
  int get savedScore => prefs.getInt(_keySavedScore) ?? 0;
  int get savedBonusScore => prefs.getInt(_keySavedBonusScore) ?? 0;
  int get savedElapsedTime => prefs.getInt(_keySavedElapsedTime) ?? 0;
  double get savedObstacleSpeed => prefs.getDouble(_keySavedObstacleSpeed) ?? 15.0;
  int get savedCurrentLevel => prefs.getInt(_keySavedCurrentLevel) ?? 1;
  int get savedLevelTargetScore => prefs.getInt(_keySavedLevelTargetScore) ?? 5000;
  int get savedLastLevelTargetScore => prefs.getInt(_keySavedLastLevelTargetScore) ?? 0;
  int get savedBullets => prefs.getInt(_keySavedBullets) ?? 0;
  int get savedSuperBullets => prefs.getInt(_keySavedSuperBullets) ?? 0;

  // Setters
  Future<void> setHighScore(int val) => prefs.setInt(_keyHighScore, val);
  Future<void> setGems(int val) => prefs.setInt(_keyGems, val);
  Future<void> setBullets(int val) => prefs.setInt(_keyBullets, val);
  Future<void> setSuperBullets(int val) => prefs.setInt(_keySuperBullets, val);
  Future<void> setCurrentLevel(int val) => prefs.setInt(_keyCurrentLevel, val);
  Future<void> setLevelTargetScore(int val) => prefs.setInt(_keyLevelTargetScore, val);
  Future<void> setLastLevelTargetScore(int val) => prefs.setInt(_keyLastLevelTargetScore, val);

  Future<void> setUnlockedIcons(String val) => prefs.setString(_keyUnlockedIcons, val);
  Future<void> setUnlockedThemes(String val) => prefs.setString(_keyUnlockedThemes, val);
  Future<void> setUnlockedPlayerThemes(String val) => prefs.setString(_keyUnlockedPlayerThemes, val);
  Future<void> setUnlockedObstacleShapes(String val) => prefs.setString(_keyUnlockedObstacleShapes, val);
  Future<void> setUnlockedSkins(String val) => prefs.setString(_keyUnlockedSkins, val);

  Future<void> setCurrentIconId(String val) => prefs.setString(_keyCurrentIconId, val);
  Future<void> setCurrentPlayerColorId(String val) => prefs.setString(_keyCurrentPlayerColorId, val);
  Future<void> setCurrentObstacleShapeId(String val) => prefs.setString(_keyCurrentObstacleShapeId, val);
  Future<void> setCurrentObstacleColorId(String val) => prefs.setString(_keyCurrentObstacleColorId, val);
  Future<void> setCurrentSkinId(String val) => prefs.setString(_keyCurrentSkinId, val);

  Future<void> setSoundEnabled(bool val) => prefs.setBool(_keySoundEnabled, val);
  Future<void> setMusicEnabled(bool val) => prefs.setBool(_keyMusicEnabled, val);
  Future<void> setVibrationEnabled(bool val) => prefs.setBool(_keyVibrationEnabled, val);

  Future<void> saveGameSession({
    required int score,
    required int bonusScore,
    required int elapsedTime,
    required double obstacleSpeed,
    required int currentLevel,
    required int levelTargetScore,
    required int lastLevelTargetScore,
    required int bullets,
    required int superBullets,
  }) async {
    await prefs.setInt(_keySavedScore, score);
    await prefs.setInt(_keySavedBonusScore, bonusScore);
    await prefs.setInt(_keySavedElapsedTime, elapsedTime);
    await prefs.setDouble(_keySavedObstacleSpeed, obstacleSpeed);
    await prefs.setInt(_keySavedCurrentLevel, currentLevel);
    await prefs.setInt(_keySavedLevelTargetScore, levelTargetScore);
    await prefs.setInt(_keySavedLastLevelTargetScore, lastLevelTargetScore);
    await prefs.setInt(_keySavedBullets, bullets);
    await prefs.setInt(_keySavedSuperBullets, superBullets);
    await prefs.setBool(_keyHasSavedGame, true);
  }

  Future<void> clearSavedSession() async {
    await prefs.remove(_keySavedScore);
    await prefs.remove(_keySavedBonusScore);
    await prefs.remove(_keySavedElapsedTime);
    await prefs.remove(_keySavedObstacleSpeed);
    await prefs.remove(_keySavedCurrentLevel);
    await prefs.remove(_keySavedLevelTargetScore);
    await prefs.remove(_keySavedLastLevelTargetScore);
    await prefs.remove(_keySavedBullets);
    await prefs.remove(_keySavedSuperBullets);
    await prefs.setBool(_keyHasSavedGame, false);
  }
}
