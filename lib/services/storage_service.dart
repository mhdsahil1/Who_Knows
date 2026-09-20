import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_settings.dart';

/// Persists user settings locally using SharedPreferences.
class StorageService {
  static const String _keySound = 'sound_enabled';
  static const String _keyVibration = 'vibration_enabled';
  static const String _keyImposterCount = 'imposter_count';
  static const String _keyCategory = 'selected_category';
  static const String _keyShowHint = 'show_hint_to_imposter';

  Future<GameSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return GameSettings(
      soundEnabled: prefs.getBool(_keySound) ?? true,
      vibrationEnabled: prefs.getBool(_keyVibration) ?? true,
      imposterCount: prefs.getInt(_keyImposterCount) ?? 1,
      selectedCategory: prefs.getString(_keyCategory),
      showHintToImposter: prefs.getBool(_keyShowHint) ?? true,
    );
  }

  Future<void> saveSettings(GameSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keySound, settings.soundEnabled);
    await prefs.setBool(_keyVibration, settings.vibrationEnabled);
    await prefs.setInt(_keyImposterCount, settings.imposterCount);
    if (settings.selectedCategory != null) {
      await prefs.setString(_keyCategory, settings.selectedCategory!);
    } else {
      await prefs.remove(_keyCategory);
    }
    await prefs.setBool(_keyShowHint, settings.showHintToImposter);
  }
}
