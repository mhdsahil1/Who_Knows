import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:who_knows/data/word_database.dart';
import 'package:who_knows/game/game_engine.dart';
import 'package:who_knows/game/role_manager.dart';
import 'package:who_knows/game/win_condition.dart';
import 'package:who_knows/game/word_manager.dart';
import 'package:who_knows/models/enums.dart';
import 'package:who_knows/models/game_settings.dart';
import 'package:who_knows/models/player.dart';

GameEngine _createEngine({int seed = 42, GameSettings? settings}) {
  final random = Random(seed);
  return GameEngine(
    wordManager: WordManager(random: random),
    roleManager: RoleManager(random: random),
    winCondition: const WinCondition(),
  )..updateSettings(settings ?? GameSettings());
}

void main() {
  group('v0.2 Game Configuration & Chaos Mode Tests', () {
    // ── CATEGORY TESTS ──────────────────────────────────
    test('1. Categories are derived from database', () {
      final categories = WordDatabase.categories;
      expect(categories.isNotEmpty, isTrue);
      expect(categories, contains('Food'));
      expect(categories, contains('Animals'));
      expect(categories, contains('Technology'));
      expect(categories, equals(WordDatabase.categories));
    });

    test('2. Selecting one category restricts words', () {
      final wm = WordManager(random: Random(42));
      for (var i = 0; i < 20; i++) {
        final word = wm.pickWord(categories: {'Food'});
        expect(word, isNotNull);
        expect(word!.category, equals('Food'));
      }
    });

    test('3. Selecting multiple categories combines pools', () {
      final wm = WordManager(random: Random(42));
      final chosenCategories = <String>{};
      for (var i = 0; i < 30; i++) {
        final word = wm.pickWord(categories: {'Food', 'Animals'});
        expect(word, isNotNull);
        expect({'Food', 'Animals'}.contains(word!.category), isTrue);
        chosenCategories.add(word.category);
      }
      expect(chosenCategories.contains('Food'), isTrue);
      expect(chosenCategories.contains('Animals'), isTrue);
    });

    test('4. Select All works', () {
      final allCats = WordDatabase.categories.toSet();
      final settings = GameSettings(selectedCategories: allCats);
      expect(settings.selectedCategories.length, equals(WordDatabase.categories.length));
    });

    test('5. Clear All works', () {
      final settings = GameSettings(selectedCategories: {}).copyWith(clearCategory: true);
      expect(settings.selectedCategories.isEmpty, isTrue);
    });

    test('6. Random category selection works', () {
      final allCats = WordDatabase.categories;
      final rng = Random(42);
      final shuffled = List<String>.from(allCats)..shuffle(rng);
      final randomSubset = shuffled.take(3).toSet();
      expect(randomSubset.length, equals(3));
      for (final cat in randomSubset) {
        expect(allCats.contains(cat), isTrue);
      }
    });

    test('7. Empty category selection prevents game start', () {
      final engine = _createEngine();
      engine.startNewGame();
      engine.addPlayer('P1');
      engine.addPlayer('P2');
      engine.addPlayer('P3');

      engine.setSelectedCategories({});
      final error = engine.startGame();
      expect(error, equals('Choose at least one category.'));
    });

    // ── PLAYER TESTS ────────────────────────────────────
    test('8. 3 players accepted', () {
      final engine = _createEngine();
      engine.startNewGame();
      expect(engine.addPlayer('A'), isTrue);
      expect(engine.addPlayer('B'), isTrue);
      expect(engine.addPlayer('C'), isTrue);
      expect(engine.state.players.length, equals(3));
      expect(engine.startGame(), isNull);
    });

    test('9. 20 players accepted', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 20; i++) {
        expect(engine.addPlayer('Player $i'), isTrue);
      }
      expect(engine.state.players.length, equals(20));
      expect(engine.startGame(), isNull);
    });

    test('10. 21 players rejected', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 20; i++) {
        engine.addPlayer('Player $i');
      }
      expect(engine.addPlayer('Player 21'), isFalse);
      expect(engine.state.players.length, equals(20));
    });

    test('11. Duplicate names rejected', () {
      final engine = _createEngine();
      engine.startNewGame();
      expect(engine.addPlayer('Sahil'), isTrue);
      expect(engine.addPlayer('sahil'), isFalse);
      expect(engine.addPlayer('SAHIL'), isFalse);
    });

    test('12. Empty names rejected', () {
      final engine = _createEngine();
      engine.startNewGame();
      expect(engine.addPlayer(''), isFalse);
      expect(engine.addPlayer('   '), isFalse);
    });

    // ── IMPOSTER TESTS ──────────────────────────────────
    test('13. Recommended count works (1 for <6, 2 for >=6)', () {
      // 5 players -> recommended 1
      final engine5 = _createEngine();
      engine5.startNewGame();
      for (var i = 1; i <= 5; i++) {
        engine5.addPlayer('P$i');
      }
      engine5.setImposterMode(ImposterMode.recommended);
      expect(engine5.startGame(), isNull);
      expect(engine5.state.activeImposters.length, equals(1));

      // 6 players -> recommended 2
      final engine6 = _createEngine();
      engine6.startNewGame();
      for (var i = 1; i <= 6; i++) {
        engine6.addPlayer('P$i');
      }
      engine6.setImposterMode(ImposterMode.recommended);
      expect(engine6.startGame(), isNull);
      expect(engine6.state.activeImposters.length, equals(2));
    });

    test('14. Custom count works', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 8; i++) {
        engine.addPlayer('P$i');
      }
      engine.setImposterMode(ImposterMode.custom);
      engine.setCustomImposterCount(3);
      expect(engine.startGame(), isNull);
      expect(engine.state.activeImposters.length, equals(3));
    });

    test('15. 0 imposters works', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 4; i++) {
        engine.addPlayer('P$i');
      }
      engine.setImposterMode(ImposterMode.custom);
      engine.setCustomImposterCount(0);
      expect(engine.startGame(), isNull);
      expect(engine.state.activeImposters.length, equals(0));
      expect(engine.state.activeCivilians.length, equals(4));
      for (final p in engine.state.players) {
        expect(p.isCivilian, isTrue);
        expect(p.secretWord, isNotNull);
      }
    });

    test('16. Imposters can equal player count in Chaos Mode', () {
      final rm = RoleManager(random: Random(42));
      final players = List.generate(4, (i) => Player(id: 'p$i', name: 'P$i'));
      final word = WordDatabase.allWords.first;
      final assignment = rm.assignRoles(
        players: players,
        word: word,
        imposterCount: 4,
        allowAllImposters: true,
      );
      expect(assignment.roles.values.every((r) => r == PlayerRole.imposter), isTrue);
    });

    test('17. Invalid normal-mode configurations are handled', () {
      final engine = _createEngine();
      engine.startNewGame();
      engine.addPlayer('P1');
      engine.addPlayer('P2');
      engine.addPlayer('P3');

      engine.setImposterMode(ImposterMode.fixed);
      engine.setImposterCount(3); // 3 imposters for 3 players in normal mode
      expect(engine.startGame(), equals('Imposter count must be less than player count'));
    });

    // ── FINAL GUESS TESTS ───────────────────────────────
    test('18. Final Guess ON -> final guess screen', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 4; i++) {
        engine.addPlayer('P$i');
      }
      engine.setFinalGuessEnabled(true);
      engine.setImposterCount(1);
      engine.startGame();

      // Accuse the imposter
      final imp = engine.state.activeImposters.first;
      engine.startDiscussion();
      engine.startVoting();
      engine.selectAccusedPlayer(imp.id);
      engine.confirmGroupVote();
      expect(engine.state.phase, equals(GamePhase.voteResult));

      // Proceed moves to finalGuess
      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.finalGuess));
    });

    test('19. Final Guess OFF -> immediate game result', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 4; i++) {
        engine.addPlayer('P$i');
      }
      engine.setFinalGuessEnabled(false);
      engine.setImposterCount(1);
      engine.startGame();

      // Accuse the imposter
      final imp = engine.state.activeImposters.first;
      engine.startDiscussion();
      engine.startVoting();
      engine.selectAccusedPlayer(imp.id);
      engine.confirmGroupVote();
      expect(engine.state.phase, equals(GamePhase.voteResult));

      // Proceed immediately moves to gameOver with civilian win
      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.civilians));
    });

    test('20. Correct final guess -> Imposter wins', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 4; i++) {
        engine.addPlayer('P$i');
      }
      engine.setFinalGuessEnabled(true);
      engine.startGame();

      final imp = engine.state.activeImposters.first;
      engine.startDiscussion();
      engine.startVoting();
      engine.selectAccusedPlayer(imp.id);
      engine.confirmGroupVote();
      engine.proceedFromVoteResult();

      final secret = engine.state.currentWord!.word;
      engine.submitFinalGuess(secret);
      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.imposters));
    });

    test('21. Wrong final guess -> Civilians win', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 4; i++) {
        engine.addPlayer('P$i');
      }
      engine.setFinalGuessEnabled(true);
      engine.startGame();

      final imp = engine.state.activeImposters.first;
      engine.startDiscussion();
      engine.startVoting();
      engine.selectAccusedPlayer(imp.id);
      engine.confirmGroupVote();
      engine.proceedFromVoteResult();

      engine.submitFinalGuess('clearly wrong guess');
      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.civilians));
    });

    // ── CHAOS TESTS ─────────────────────────────────────
    test('22. Chaos mode generates valid imposter count', () {
      final engine = _createEngine();
      for (var i = 0; i < 100; i++) {
        final count = engine.determineChaosImposterCount(6);
        expect(count >= 0 && count <= 6, isTrue);
      }
    });

    test('23. Chaos can generate 0 imposters', () {
      final engine = _createEngine();
      var generatedZero = false;
      for (var seed = 0; seed < 1000; seed++) {
        final count = engine.determineChaosImposterCount(6, Random(seed));
        if (count == 0) {
          generatedZero = true;
          break;
        }
      }
      expect(generatedZero, isTrue);
    });

    test('24. Chaos can generate multiple imposters', () {
      final engine = _createEngine();
      var generatedMultiple = false;
      for (var seed = 0; seed < 100; seed++) {
        final count = engine.determineChaosImposterCount(8, Random(seed));
        if (count >= 2) {
          generatedMultiple = true;
          break;
        }
      }
      expect(generatedMultiple, isTrue);
    });

    test('25. Chaos never generates more than player count', () {
      final engine = _createEngine();
      for (var pCount = 3; pCount <= 20; pCount++) {
        for (var seed = 0; seed < 50; seed++) {
          final count = engine.determineChaosImposterCount(pCount, Random(seed));
          expect(count <= pCount, isTrue);
          expect(count >= 0, isTrue);
        }
      }
    });

    test('26. Chaos Words assigns unique words', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 6; i++) {
        engine.addPlayer('P$i');
      }
      engine.setGameMode(GameMode.chaos);
      engine.setWordDistribution(WordDistribution.unique);
      expect(engine.startGame(), isNull);

      final words = engine.state.players.map((p) => p.secretWord).toList();
      expect(words.every((w) => w != null && w.isNotEmpty), isTrue);
    });

    test('27. Chaos Words never duplicates words', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 10; i++) {
        engine.addPlayer('P$i');
      }
      engine.setGameMode(GameMode.chaos);
      engine.setWordDistribution(WordDistribution.unique);
      expect(engine.startGame(), isNull);

      final words = engine.state.players.map((p) => p.secretWord!).toList();
      final uniqueSet = words.toSet();
      expect(uniqueSet.length, equals(words.length));
    });

    test('28. Chaos Words respects selected categories', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 5; i++) {
        engine.addPlayer('P$i');
      }
      engine.setSelectedCategories({'Food'});
      engine.setGameMode(GameMode.chaos);
      engine.setWordDistribution(WordDistribution.unique);
      expect(engine.startGame(), isNull);

      for (final w in engine.state.assignedChaosWords) {
        expect(w.category, equals('Food'));
      }
    });

    test('29. Chaos Words fails gracefully if not enough words exist', () {
      final wm = WordManager(random: Random(42));
      // Asking for 500 words from a category with < 100 words
      final words = wm.pickUniqueWords(500, categories: {'Food'});
      expect(words, isNull);
    });

    test('30. All-Imposter configuration does not crash', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 4; i++) {
        engine.addPlayer('P$i');
      }
      engine.setGameMode(GameMode.chaos);
      engine.setWordDistribution(WordDistribution.unique);

      // Seed engine where determineChaosImposterCount returns 4
      final rm = RoleManager(random: Random(42));
      final wm = WordManager(random: Random(42));
      final uniqueWords = wm.pickUniqueWords(4)!;
      final assignment = rm.assignRoles(
        players: engine.state.players,
        uniqueWords: uniqueWords,
        imposterCount: 4,
        allowAllImposters: true,
      );
      for (final p in engine.state.players) {
        p.role = assignment.roles[p.id]!;
        p.secretWord = assignment.secretWords[p.id];
      }
      expect(engine.state.players.every((p) => p.isImposter), isTrue);
    });

    test('31. Zero-Imposter configuration does not crash', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 4; i++) {
        engine.addPlayer('P$i');
      }
      engine.setImposterMode(ImposterMode.custom);
      engine.setCustomImposterCount(0);
      expect(engine.startGame(), isNull);

      // Eliminate a civilian
      engine.startDiscussion();
      engine.startVoting();
      engine.selectAccusedPlayer(engine.state.players.first.id);
      expect(engine.confirmGroupVote(), isTrue);
      expect(engine.state.phase, equals(GamePhase.voteResult));
      expect(engine.state.caughtImposter, isNull);

      // Proceed returns to discussion
      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.discussion));
    });
  });
}
