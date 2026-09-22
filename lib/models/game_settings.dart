import 'enums.dart';
import '../constants/game_constants.dart';
import '../data/word_database.dart';

/// Persisted game configuration.
class GameSettings {
  final int imposterCount;
  final ImposterMode imposterMode;
  final int customImposterCount;
  final Set<String> selectedCategories;
  final GameMode gameMode;
  final WordDistribution wordDistribution;
  final bool finalGuessEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool showHintToImposter;
  final bool myWordsEnabled;
  final bool associatedWordsEnabled;
  final bool canImposterStart;
  final bool impostersKnowEachOther;

  GameSettings({
    this.imposterCount = GameConstants.defaultImposterCount,
    this.imposterMode = ImposterMode.fixed,
    this.customImposterCount = 1,
    Set<String>? selectedCategories,
    String? selectedCategory,
    this.gameMode = GameMode.classic,
    this.wordDistribution = WordDistribution.shared,
    this.finalGuessEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.showHintToImposter = true,
    this.myWordsEnabled = false,
    this.associatedWordsEnabled = false,
    this.canImposterStart = true,
    this.impostersKnowEachOther = false,
  }) : selectedCategories = selectedCategory != null
            ? {selectedCategory}
            : (selectedCategories ?? WordDatabase.categories.toSet());

  /// Backwards-compatibility getter for single category.
  String? get selectedCategory =>
      selectedCategories.length == 1 ? selectedCategories.first : null;

  GameSettings copyWith({
    int? imposterCount,
    ImposterMode? imposterMode,
    int? customImposterCount,
    Set<String>? selectedCategories,
    String? selectedCategory,
    bool clearCategory = false,
    GameMode? gameMode,
    WordDistribution? wordDistribution,
    bool? finalGuessEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? showHintToImposter,
    bool? myWordsEnabled,
    bool? associatedWordsEnabled,
    bool? canImposterStart,
    bool? impostersKnowEachOther,
  }) {
    Set<String>? resolvedCategories;
    if (clearCategory) {
      resolvedCategories = {};
    } else if (selectedCategory != null) {
      resolvedCategories = {selectedCategory};
    } else if (selectedCategories != null) {
      resolvedCategories = selectedCategories;
    } else {
      resolvedCategories = this.selectedCategories;
    }

    return GameSettings(
      imposterCount: imposterCount ?? this.imposterCount,
      imposterMode: imposterMode ?? this.imposterMode,
      customImposterCount: customImposterCount ?? this.customImposterCount,
      selectedCategories: resolvedCategories,
      gameMode: gameMode ?? this.gameMode,
      wordDistribution: wordDistribution ?? this.wordDistribution,
      finalGuessEnabled: finalGuessEnabled ?? this.finalGuessEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      showHintToImposter: showHintToImposter ?? this.showHintToImposter,
      myWordsEnabled: myWordsEnabled ?? this.myWordsEnabled,
      associatedWordsEnabled:
          associatedWordsEnabled ?? this.associatedWordsEnabled,
      canImposterStart: canImposterStart ?? this.canImposterStart,
      impostersKnowEachOther:
          impostersKnowEachOther ?? this.impostersKnowEachOther,
    );
  }

  @override
  String toString() =>
      'GameSettings(imposters: $imposterCount, mode: $imposterMode, '
      'custom: $customImposterCount, cats: ${selectedCategories.length}, '
      'gameMode: $gameMode, dist: $wordDistribution, finalGuess: $finalGuessEnabled, '
      'sound: $soundEnabled, vib: $vibrationEnabled, '
      'showHint: $showHintToImposter, myWords: $myWordsEnabled, '
      'assocWords: $associatedWordsEnabled, canImposterStart: $canImposterStart, '
      'impostersKnowEachOther: $impostersKnowEachOther)';
}
