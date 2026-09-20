import 'package:flutter/foundation.dart';

/// Placeholder audio service for sound effects.
/// Architecture is in place — actual audio files can be added later.
class AudioService {
  bool _soundEnabled = true;
  bool _initialized = false;

  bool get soundEnabled => _soundEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  Future<void> initialize() async {
    // TODO: Initialize audio player when assets are available.
    _initialized = true;
    debugPrint('AudioService: initialized (placeholder)');
  }

  void playButtonTap() => _play('button_tap');
  void playRoleReveal() => _play('role_reveal');
  void playCountdown() => _play('countdown');
  void playVoting() => _play('voting');
  void playElimination() => _play('elimination');
  void playImposterCaught() => _play('imposter_caught');
  void playVictory() => _play('victory');
  void playDefeat() => _play('defeat');

  void _play(String soundName) {
    if (!_soundEnabled || !_initialized) return;
    // TODO: Play actual sound file when available.
    debugPrint('AudioService: play $soundName (placeholder)');
  }

  void dispose() {
    // TODO: Dispose audio player.
    debugPrint('AudioService: disposed');
  }
}
