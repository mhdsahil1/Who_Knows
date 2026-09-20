import 'dart:math';

import '../data/word_database.dart';
import '../models/word.dart';

/// Selects words from the database, avoiding repeats.
class WordManager {
  final Random _random;
  final Set<String> _usedWords = {};

  WordManager({Random? random}) : _random = random ?? Random();

  /// Pick a random word matching the given filters.
  /// Returns null if no eligible words remain.
  Word? pickWord({
    String? category,
    Set<String>? categories,
  }) {
    final effectiveCategories =
        categories ?? (category != null ? {category} : null);
    final candidates = WordDatabase.getWords(
      categories: effectiveCategories,
    ).where((w) => !_usedWords.contains(w.word)).toList();

    if (candidates.isEmpty) {
      // All words used — reset and try again.
      _usedWords.clear();
      final fresh = WordDatabase.getWords(
        categories: effectiveCategories,
      );
      if (fresh.isEmpty) return null;
      final word = fresh[_random.nextInt(fresh.length)];
      _usedWords.add(word.word);
      return word;
    }

    final word = candidates[_random.nextInt(candidates.length)];
    _usedWords.add(word.word);
    return word;
  }

  /// Pick [count] unique words from the eligible pool.
  /// Returns null if fewer than [count] distinct eligible words exist in the database.
  List<Word>? pickUniqueWords(
    int count, {
    Set<String>? categories,
  }) {
    final allEligible = WordDatabase.getWords(
      categories: categories,
    );

    if (allEligible.length < count) {
      return null;
    }

    // Try picking unused first, then refill if needed
    final unused =
        allEligible.where((w) => !_usedWords.contains(w.word)).toList();
    List<Word> selected = [];

    if (unused.length >= count) {
      final shuffled = List<Word>.from(unused)..shuffle(_random);
      selected = shuffled.take(count).toList();
    } else {
      // Clear used words and shuffle all eligible
      _usedWords.clear();
      final shuffled = List<Word>.from(allEligible)..shuffle(_random);
      selected = shuffled.take(count).toList();
    }

    for (final w in selected) {
      _usedWords.add(w.word);
    }
    return selected;
  }

  /// Reset the used-words tracker (e.g. on full game reset).
  void reset() {
    _usedWords.clear();
  }

  /// How many words have been used.
  int get usedCount => _usedWords.length;
}
