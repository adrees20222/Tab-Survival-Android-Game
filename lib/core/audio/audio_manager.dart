import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();

  // Fixed pool of SFX players to prevent MediaPlayer resource exhaustion
  static const int _sfxPoolSize = 4;
  final List<AudioPlayer> _sfxPool = [];
  int _currentSfxIndex = 0;

  bool musicEnabled = true;
  bool soundEnabled = true;
  bool vibrationEnabled = true;

  bool _isBgmPlaying = false;

  Future<void> init({
    required bool music,
    required bool sound,
    required bool vibration,
  }) async {
    musicEnabled = music;
    soundEnabled = sound;
    vibrationEnabled = vibration;

    try {
      // Global Audio Context: do not steal focus on SFX, use game audio mode
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );

      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);

      // Initialize pre-allocated SFX pool
      _sfxPool.clear();
      for (int i = 0; i < _sfxPoolSize; i++) {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        _sfxPool.add(player);
      }
    } catch (_) {
      // Audio initialization fallback
    }
  }

  Future<void> startBgm() async {
    if (!musicEnabled) return;
    if (_isBgmPlaying) return;

    try {
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
      _isBgmPlaying = true;
    } catch (_) {
      // Ignored if device audio is busy
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      _isBgmPlaying = false;
    } catch (_) {
      // Ignored
    }
  }

  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
      _isBgmPlaying = false;
    } catch (_) {
      // Ignored
    }
  }

  Future<void> resumeBgm() async {
    if (!musicEnabled) return;
    try {
      await _bgmPlayer.resume();
      _isBgmPlaying = true;
    } catch (_) {
      startBgm();
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    musicEnabled = enabled;
    if (enabled) {
      startBgm();
    } else {
      stopBgm();
    }
  }

  void playSfx(String assetPath) {
    if (!soundEnabled) return;
    if (_sfxPool.isEmpty) return;

    try {
      final player = _sfxPool[_currentSfxIndex];
      _currentSfxIndex = (_currentSfxIndex + 1) % _sfxPoolSize;

      player.play(AssetSource(assetPath)).catchError((_) {
        // Suppress transient audio playback errors silently
      });
    } catch (_) {
      // Ignored
    }
  }

  void playSwitchLane() => playSfx('audio/switch_lane.wav');
  void playCollect() => playSfx('audio/collect.wav');
  void playCrash() => playSfx('audio/crash.wav');
  void playFever() => playSfx('audio/fever.wav');
  void playGhost() => playSfx('audio/ghost.wav');
  void playLevelUp() => playSfx('audio/level_up.wav');
  void playMagnet() => playSfx('audio/magnet.wav');
  void playShield() => playSfx('audio/shield.wav');

  // Haptic feedback methods
  void vibrateLight() {
    if (!vibrationEnabled) return;
    HapticFeedback.lightImpact();
  }

  void vibrateMedium() {
    if (!vibrationEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void vibrateHeavy() {
    if (!vibrationEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void vibratePattern() {
    if (!vibrationEnabled) return;
    HapticFeedback.vibrate();
  }

  void dispose() {
    _bgmPlayer.dispose();
    for (final player in _sfxPool) {
      player.dispose();
    }
  }
}
