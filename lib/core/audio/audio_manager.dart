import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();

  // Dedicated sound players for each distinct sound effect
  final AudioPlayer _switchPlayer = AudioPlayer();
  final AudioPlayer _collectPlayer = AudioPlayer();
  final AudioPlayer _crashPlayer = AudioPlayer();
  final AudioPlayer _feverPlayer = AudioPlayer();
  final AudioPlayer _ghostPlayer = AudioPlayer();
  final AudioPlayer _levelUpPlayer = AudioPlayer();
  final AudioPlayer _magnetPlayer = AudioPlayer();
  final AudioPlayer _shieldPlayer = AudioPlayer();

  final Map<String, int> _lastPlayTime = {};
  static const int _throttleMs = 50;

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
      // Global non-focus-stealing game audio context
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

      final sfxPlayers = [
        _switchPlayer,
        _collectPlayer,
        _crashPlayer,
        _feverPlayer,
        _ghostPlayer,
        _levelUpPlayer,
        _magnetPlayer,
        _shieldPlayer,
      ];

      for (final p in sfxPlayers) {
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setPlayerMode(PlayerMode.lowLatency);
      }
    } catch (_) {
      // Fallback
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

  void _safePlay(AudioPlayer player, String path) {
    if (!soundEnabled) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTime = _lastPlayTime[path] ?? 0;
    if (now - lastTime < _throttleMs) return;
    _lastPlayTime[path] = now;

    try {
      if (player.state == PlayerState.playing) {
        player.stop().then((_) {
          player.play(AssetSource(path)).catchError((_) {});
        }).catchError((_) {});
      } else {
        player.play(AssetSource(path)).catchError((_) {});
      }
    } catch (_) {
      // Suppress transient audio error
    }
  }

  void playSwitchLane() => _safePlay(_switchPlayer, 'audio/switch_lane.wav');
  void playCollect() => _safePlay(_collectPlayer, 'audio/collect.wav');
  void playCrash() => _safePlay(_crashPlayer, 'audio/crash.wav');
  void playFever() => _safePlay(_feverPlayer, 'audio/fever.wav');
  void playGhost() => _safePlay(_ghostPlayer, 'audio/ghost.wav');
  void playLevelUp() => _safePlay(_levelUpPlayer, 'audio/level_up.wav');
  void playMagnet() => _safePlay(_magnetPlayer, 'audio/magnet.wav');
  void playShield() => _safePlay(_shieldPlayer, 'audio/shield.wav');

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
    _switchPlayer.dispose();
    _collectPlayer.dispose();
    _crashPlayer.dispose();
    _feverPlayer.dispose();
    _ghostPlayer.dispose();
    _levelUpPlayer.dispose();
    _magnetPlayer.dispose();
    _shieldPlayer.dispose();
  }
}
