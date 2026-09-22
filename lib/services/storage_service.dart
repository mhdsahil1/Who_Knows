import 'package:shared_preferences/shared_preferences.dart';
import '../models/enums.dart';
import '../models/game_settings.dart';

/// Persists user settings locally using SharedPreferences.
class StorageService {
  static const String _keySound = 'sound_enabled';
  static const String _keyVibration = 'vibration_enabled';
  static const String _keyImposterCount = 'imposter_count';
  static const String _keyCategory = 'selected_category';
  static const String _keyShowHint = 'show_hint_to_imposter';
  static const String _keyMyWords = 'my_words_enabled';
  static const String _keyAssociatedWords = 'associated_words_enabled';
  static const String _keyCanImposterStart = 'can_imposter_start';
  static const String _keyImpostersKnowEachOther = 'imposters_know_each_other';
  static const String _keyGameMode = 'game_mode';

  Future<GameSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final gameModeStr = prefs.getString(_keyGameMode);
    final gameMode = GameMode.values.firstWhere(
      (m) => m.name == gameModeStr,
      orElse: () => GameMode.classic,
    );

    return GameSettings(
      soundEnabled: prefs.getBool(_keySound) ?? true,
      vibrationEnabled: prefs.getBool(_keyVibration) ?? true,
      imposterCount: prefs.getInt(_keyImposterCount) ?? 1,
      selectedCategory: prefs.getString(_keyCategory),
      showHintToImposter: prefs.getBool(_keyShowHint) ?? true,
      myWordsEnabled: prefs.getBool(_keyMyWords) ?? false,
      associatedWordsEnabled: prefs.getBool(_keyAssociatedWords) ?? false,
      canImposterStart: prefs.getBool(_keyCanImposterStart) ?? true,
      impostersKnowEachOther: prefs.getBool(_keyImpostersKnowEachOther) ?? false,
      gameMode: gameMode,
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
    await prefs.setBool(_keyMyWords, settings.myWordsEnabled);
    await prefs.setBool(_keyAssociatedWords, settings.associatedWordsEnabled);
    await prefs.setBool(_keyCanImposterStart, settings.canImposterStart);
    await prefs.setBool(
        _keyImpostersKnowEachOther, settings.impostersKnowEachOther);
    await prefs.setString(_keyGameMode, settings.gameMode.name);
  }
}
