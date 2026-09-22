import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:who_knows/data/word_database.dart';
import 'package:who_knows/game/word_manager.dart';

void main() {
  group('WordManager', () {
    test('picks a word from the database', () {
      final manager = WordManager(random: Random(42));
      final word = manager.pickWord();
      expect(word, isNotNull);
      expect(word!.word, isNotEmpty);
      expect(word.category, isNotEmpty);
    });

    test('picks a word from a specific category', () {
      final manager = WordManager(random: Random(42));
      final word = manager.pickWord(category: 'Food');
      expect(word, isNotNull);
      expect(word!.category, equals('Food'));
    });

    test('avoids repeating words', () {
      final manager = WordManager(random: Random(42));
      final picked = <String>{};
      // Pick many words and verify no duplicates.
      for (var i = 0; i < 20; i++) {
        final word = manager.pickWord();
        expect(word, isNotNull);
        expect(picked.contains(word!.word), isFalse,
            reason: '${word.word} was picked twice');
        picked.add(word.word);
      }
    });

    test('resets used words and picks again when exhausted', () {
      final manager = WordManager(random: Random(42));
      final foodWords = WordDatabase.getWords(category: 'Food');
      final count = foodWords.length;

      for (var i = 0; i < count; i++) {
        final word = manager.pickWord(category: 'Food');
        expect(word, isNotNull);
      }

      // Next pick should still work (resets internally).
      final word = manager.pickWord(category: 'Food');
      expect(word, isNotNull);
    });

    test('returns null for nonexistent category', () {
      final manager = WordManager(random: Random(42));
      final word = manager.pickWord(category: 'Nonexistent');
      expect(word, isNull);
    });

    test('reset clears used words', () {
      final manager = WordManager(random: Random(42));
      manager.pickWord();
      manager.pickWord();
      expect(manager.usedCount, equals(2));
      manager.reset();
      expect(manager.usedCount, equals(0));
    });
  });

  group('WordDatabase', () {
    test('has at least 200 words', () {
      expect(WordDatabase.allWords.length, greaterThanOrEqualTo(200));
    });

    test('has at least 12 categories', () {
      expect(WordDatabase.categories.length, greaterThanOrEqualTo(12));
    });

    test('every word has non-empty word and category', () {
      for (final word in WordDatabase.allWords) {
        expect(word.word, isNotEmpty);
        expect(word.category, isNotEmpty);
      }
    });

    test('categories list is sorted', () {
      final cats = WordDatabase.categories;
      final sorted = List<String>.from(cats)..sort();
      expect(cats, equals(sorted));
    });
  });
}
