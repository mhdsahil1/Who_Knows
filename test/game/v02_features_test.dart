import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:who_knows/data/word_database.dart';
import 'package:who_knows/game/game_engine.dart';
import 'package:who_knows/game/role_manager.dart';
import 'package:who_knows/game/win_condition.dart';
import 'package:who_knows/game/word_manager.dart';
import 'package:who_knows/models/enums.dart';
import 'package:who_knows/models/game_settings.dart';
import 'package:who_knows/services/associated_words_service.dart';
import 'package:who_knows/services/my_words_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('V0.2 — Starting Player Feature', () {
    test('Starting player is randomly selected from active players on startGame', () {
      final engine = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
      );
      engine.startNewGame();
      engine.addPlayer('Asheel');
      engine.addPlayer('Sahil');
      engine.addPlayer('Afnan');

      final error = engine.startGame();
      expect(error, isNull);
      expect(engine.state.startingPlayerId, isNotNull);
      expect(engine.state.startingPlayer, isNotNull);
      expect(
        ['Asheel', 'Sahil', 'Afnan'].contains(engine.state.startingPlayer!.name),
        isTrue,
      );
    });

    test('Starting player does not reveal or depend on imposter role', () {
      // Run multiple games and confirm both civilians and imposters can be starting player
      var civilianStarted = false;
      var imposterStarted = false;

      for (var seed = 0; seed < 50; seed++) {
        final engine = GameEngine(
          roleManager: RoleManager(random: Random(seed)),
          wordManager: WordManager(random: Random(seed)),
        );
        engine.startNewGame();
        engine.addPlayer('P1');
        engine.addPlayer('P2');
        engine.addPlayer('P3');
        engine.startGame();

        final starter = engine.state.startingPlayer!;
        if (starter.isImposter) {
          imposterStarted = true;
        } else {
          civilianStarted = true;
        }
        if (civilianStarted && imposterStarted) break;
      }

      expect(civilianStarted, isTrue);
      expect(imposterStarted, isTrue);
    });

    test('Starting player is reset on new game', () {
      final engine = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
      );
      engine.startNewGame();
      engine.addPlayer('Asheel');
      engine.addPlayer('Sahil');
      engine.addPlayer('Afnan');
      engine.startGame();

      expect(engine.state.startingPlayerId, isNotNull);

      engine.restartGame();
      expect(engine.state.startingPlayerId, isNull);
      expect(engine.state.startingPlayer, isNull);
    });

    test('startNextRound updates starting player if previous was eliminated', () {
      final engine = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
      );
      engine.startNewGame();
      engine.addPlayer('Asheel');
      engine.addPlayer('Sahil');
      engine.addPlayer('Afnan');
      engine.addPlayer('Adam');
      engine.startGame();

      final initialStarter = engine.state.startingPlayer!;
      initialStarter.eliminate();

      engine.startNextRound();
      expect(engine.state.startingPlayer, isNotNull);
      expect(engine.state.startingPlayer!.isActive, isTrue);
      expect(engine.state.startingPlayer!.id, isNot(equals(initialStarter.id)));
    });
  });

  group('V0.2 — Word Categories (Internet & School) & Difficulty Absence', () {
    test('Internet category exists and contains all required words', () {
      expect(WordDatabase.categories.contains('Internet'), isTrue);
      final internetWords =
          WordDatabase.getWords(category: 'Internet').map((w) => w.word).toSet();

      final requiredInternet = [
        'YouTube',
        'Instagram',
        'WhatsApp',
        'Reddit',
        'ChatGPT',
        'Netflix',
        'Amazon Prime',
        'Flipkart',
        'VLC',
        'Chrome',
        'HBO Max',
        'MX Player',
        'TikTok',
        'Memes',
        'Channels',
        'Zee5',
      ];

      for (final req in requiredInternet) {
        expect(internetWords.contains(req), isTrue,
            reason: 'Internet missing $req');
      }
    });

    test('School category exists and contains required words', () {
      expect(WordDatabase.categories.contains('School'), isTrue);
      final schoolWords =
          WordDatabase.getWords(category: 'School').map((w) => w.word).toSet();

      final requiredSchool = [
        'Classroom',
        'Teacher',
        'Principal',
        'Homework',
        'Exam',
        'Uniform',
        'Blackboard',
        'Lunch Break',
        'Assembly',
        'School Bus',
        'School Bell',
        'Report Card',
      ];

      for (final req in requiredSchool) {
        expect(schoolWords.contains(req), isTrue,
            reason: 'School missing $req');
      }
    });

    test('Category word counts are calculated dynamically', () {
      final internetCount =
          WordDatabase.getWordCountForCategory('Internet');
      expect(internetCount, equals(16));

      final schoolCount = WordDatabase.getWordCountForCategory('School');
      expect(schoolCount, greaterThanOrEqualTo(12));
    });
  });

  group('V0.2 — My Words Feature', () {
    test('MyWordsService is empty by default and supports add/edit/delete', () async {
      final service = MyWordsService();
      await service.loadWords();
      expect(service.words, isEmpty);

      // Add word
      final err1 = await service.addWord('Our Canteen');
      expect(err1, isNull);
      expect(service.words.length, equals(1));
      expect(service.words.first.text, equals('Our Canteen'));

      // Rejects empty
      final errEmpty = await service.addWord('   ');
      expect(errEmpty, isNotNull);

      // Rejects duplicate (case-insensitive)
      final errDup = await service.addWord('our canteen');
      expect(errDup, isNotNull);

      // Edit word
      final wordId = service.words.first.id;
      final errEdit = await service.editWord(wordId, 'My College Canteen');
      expect(errEdit, isNull);
      expect(service.words.first.text, equals('My College Canteen'));

      // Delete word
      final deleted = await service.deleteWord(wordId);
      expect(deleted, isTrue);
      expect(service.words, isEmpty);
    });

    test('My Words persist across reloads', () async {
      final service1 = MyWordsService();
      await service1.loadWords();
      await service1.addWord('That Coffee Shop');

      // Second service loading from same mock prefs
      final service2 = MyWordsService();
      await service2.loadWords();
      expect(service2.words.length, equals(1));
      expect(service2.words.first.text, equals('That Coffee Shop'));
    });
  });

  group('V0.2 — Associated Words Feature', () {
    test('AssociatedWordsService has protected built-in words and supports user words', () async {
      final service = AssociatedWordsService();
      await service.loadWords();

      // Has built-in words like Bike, Car, Phone, Laptop
      expect(service.builtInWords.isNotEmpty, isTrue);
      final builtInTexts = service.builtInWords.map((w) => w.text).toSet();
      expect(builtInTexts.contains('Bike'), isTrue);
      expect(builtInTexts.contains('Car'), isTrue);
      expect(builtInTexts.contains('Phone'), isTrue);
      expect(builtInTexts.contains('Laptop'), isTrue);

      // Cannot edit or delete built-in words
      final builtIn = service.builtInWords.first;
      final editErr = await service.editUserWord(builtIn.id, 'Modified');
      expect(editErr, contains('Cannot edit built-in'));

      final deleteErr = await service.deleteUserWord(builtIn.id);
      expect(deleteErr, isFalse);

      // Add user word
      final addErr = await service.addUserWord('That Weird Teacher');
      expect(addErr, isNull);
      expect(service.userWords.length, equals(1));
      expect(service.userWords.first.text, equals('That Weird Teacher'));

      // getAllWords includes both
      expect(
        service.allWords.map((w) => w.text).contains('That Weird Teacher'),
        isTrue,
      );
      expect(service.allWords.map((w) => w.text).contains('Bike'), isTrue);

      // Delete user word
      final userWordId = service.userWords.first.id;
      final deleted = await service.deleteUserWord(userWordId);
      expect(deleted, isTrue);
      expect(service.userWords, isEmpty);
    });

    test('Associated word dynamic combination in normal mode', () {
      final assocService = AssociatedWordsService();
      final myWordsService = MyWordsService();

      final engine = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
        myWordsService: myWordsService,
        associatedWordsService: assocService,
      );

      engine.startNewGame();
      engine.addPlayer('Asheel');
      engine.addPlayer('Sahil');
      engine.addPlayer('Afnan');

      // Enable only Associated Words
      engine.updateSettings(
        GameSettings(
          selectedCategories: {},
          myWordsEnabled: false,
          associatedWordsEnabled: true,
        ),
      );

      final error = engine.startGame();
      expect(error, isNull);

      final secret = engine.state.secretWord!;
      // Secret must be of the form "<Player>'s <GenericWord>"
      expect(secret.contains("'s "), isTrue);
      final parts = secret.split("'s ");
      expect(['Asheel', 'Sahil', 'Afnan'].contains(parts[0]), isTrue);
      // The base word must come from the generic associated words
      expect(assocService.allWords.map((w) => w.text).contains(parts[1]), isTrue);
    });

    test('Associated word dynamic combination in Chaos Words mode', () {
      final assocService = AssociatedWordsService();
      final myWordsService = MyWordsService();

      final engine = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
        myWordsService: myWordsService,
        associatedWordsService: assocService,
      );

      engine.startNewGame();
      engine.addPlayer('Asheel');
      engine.addPlayer('Sahil');
      engine.addPlayer('Afnan');

      // Enable only Associated Words with unique distribution
      engine.updateSettings(
        GameSettings(
          selectedCategories: {},
          myWordsEnabled: false,
          associatedWordsEnabled: true,
          wordDistribution: WordDistribution.unique,
        ),
      );

      final error = engine.startGame();
      expect(error, isNull);

      // Check assigned chaos words
      for (var i = 0; i < engine.state.players.length; i++) {
        final player = engine.state.players[i];
        final word = engine.state.assignedChaosWords[i];
        expect(word.word.startsWith("${player.name}'s "), isTrue);
      }
    });
  });

  group('V0.2 — Imposter Final Guess for Associated Words', () {
    const winCondition = WinCondition();

    test('Accepts exact phrase or base word, rejects player name or wrong word', () {
      const secret = "Asheel's Bike";

      // Exact phrase
      expect(winCondition.checkFinalGuess(guess: "Asheel's Bike", secretWord: secret), isTrue);
      expect(winCondition.checkFinalGuess(guess: "asheel's bike", secretWord: secret), isTrue);

      // Base word only
      expect(winCondition.checkFinalGuess(guess: "Bike", secretWord: secret), isTrue);
      expect(winCondition.checkFinalGuess(guess: "bike", secretWord: secret), isTrue);

      // Rejected variants
      expect(winCondition.checkFinalGuess(guess: "Asheel", secretWord: secret), isFalse);
      expect(winCondition.checkFinalGuess(guess: "asheel", secretWord: secret), isFalse);
      expect(winCondition.checkFinalGuess(guess: "Car", secretWord: secret), isFalse);
      expect(winCondition.checkFinalGuess(guess: "Sahil's Bike", secretWord: secret), isFalse);
      expect(winCondition.checkFinalGuess(guess: "", secretWord: secret), isFalse);
    });

    test('Normal word requires exact match', () {
      const secret = "Pizza";
      expect(winCondition.checkFinalGuess(guess: "Pizza", secretWord: secret), isTrue);
      expect(winCondition.checkFinalGuess(guess: "pizza", secretWord: secret), isTrue);
      expect(winCondition.checkFinalGuess(guess: "Burger", secretWord: secret), isFalse);
    });
  });

  group('V0.2 — Leave Game Preserves Persistent Data', () {
    test('Leave game resets session state but preserves My Words and Associated Words', () async {
      final myWords = MyWordsService();
      final assocWords = AssociatedWordsService();
      await myWords.loadWords();
      await assocWords.loadWords();

      await myWords.addWord('Custom Secret Word');
      await assocWords.addUserWord('Custom Jetpack');

      final engine = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
        myWordsService: myWords,
        associatedWordsService: assocWords,
      );

      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');
      engine.addPlayer('Charlie');
      engine.startGame();

      expect(engine.state.currentWord, isNotNull);
      expect(engine.state.startingPlayerId, isNotNull);

      // Leave game
      engine.leaveGame();

      // Session state is reset to lobby
      expect(engine.state.phase, equals(GamePhase.lobby));
      expect(engine.state.currentWord, isNull);
      expect(engine.state.startingPlayerId, isNull);

      // Persistent words remain intact
      expect(myWords.words.map((w) => w.text).contains('Custom Secret Word'), isTrue);
      expect(assocWords.userWords.map((w) => w.text).contains('Custom Jetpack'), isTrue);
    });
  });

  group('V0.2 — Can Imposter Start Feature', () {
    test('canImposterStart = YES allows Imposter to start', () {
      var imposterStarted = false;
      for (var seed = 0; seed < 50; seed++) {
        final engine = GameEngine(
          roleManager: RoleManager(random: Random(seed)),
          wordManager: WordManager(random: Random(seed)),
        );
        engine.startNewGame();
        engine.addPlayer('P1');
        engine.addPlayer('P2');
        engine.addPlayer('P3');
        engine.updateSettings(
          engine.state.settings.copyWith(canImposterStart: true),
        );
        engine.startGame();

        if (engine.state.startingPlayer!.isImposter) {
          imposterStarted = true;
          break;
        }
      }
      expect(imposterStarted, isTrue);
    });

    test('canImposterStart = NO excludes all Imposters from starting', () {
      for (var seed = 0; seed < 50; seed++) {
        final engine = GameEngine(
          roleManager: RoleManager(random: Random(seed)),
          wordManager: WordManager(random: Random(seed)),
        );
        engine.startNewGame();
        engine.addPlayer('P1');
        engine.addPlayer('P2');
        engine.addPlayer('P3');
        engine.addPlayer('P4');
        engine.updateSettings(
          engine.state.settings.copyWith(
            imposterCount: 2,
            canImposterStart: false,
          ),
        );
        engine.startGame();

        final starter = engine.state.startingPlayer!;
        expect(starter.isCivilian, isTrue,
            reason: 'Imposter was selected when canImposterStart was false!');
        expect(starter.isImposter, isFalse);
      }
    });

    test('Zero-civilian edge case does not crash and picks random active player', () {
      final engine = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
      );
      engine.startNewGame();
      engine.addPlayer('P1');
      engine.addPlayer('P2');
      engine.addPlayer('P3');

      // Set custom imposters = 3 (all imposters) and canImposterStart = false
      engine.updateSettings(
        engine.state.settings.copyWith(
          imposterMode: ImposterMode.custom,
          customImposterCount: 3,
          canImposterStart: false,
        ),
      );

      final error = engine.startGame();
      expect(error, isNull);
      expect(engine.state.startingPlayerId, isNotNull);
      expect(engine.state.startingPlayer, isNotNull);
      expect(engine.state.startingPlayer!.isActive, isTrue);
    });
  });

  group('V0.2 — Multi-Imposter Teamwork (impostersKnowEachOther)', () {
    test('impostersKnowEachOther = YES shows every other imposter to each imposter', () {
      final engine = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
      );
      engine.startNewGame();
      engine.addPlayer('Asheel');
      engine.addPlayer('Sahil');
      engine.addPlayer('Afnan');
      engine.addPlayer('Adam');

      engine.updateSettings(
        engine.state.settings.copyWith(
          imposterMode: ImposterMode.custom,
          customImposterCount: 3,
          impostersKnowEachOther: true,
        ),
      );
      engine.startGame();

      final imposters = engine.state.players.where((p) => p.isImposter).toList();
      expect(imposters.length, equals(3));

      // Each imposter sees all other imposters except themselves
      for (final imposter in imposters) {
        final teammates = engine.state.players
            .where((p) => p.isImposter && p.id != imposter.id)
            .map((p) => p.name)
            .toList();
        expect(teammates.length, equals(2));
        expect(teammates.contains(imposter.name), isFalse);
      }
    });

    test('impostersKnowEachOther = NO does not show other imposters', () {
      final engine = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
      );
      engine.startNewGame();
      engine.addPlayer('Asheel');
      engine.addPlayer('Sahil');
      engine.addPlayer('Afnan');

      engine.updateSettings(
        engine.state.settings.copyWith(
          imposterMode: ImposterMode.fixed,
          imposterCount: 2,
          impostersKnowEachOther: false,
        ),
      );
      engine.startGame();

      expect(engine.state.settings.impostersKnowEachOther, isFalse);
    });

    test('Civilians never receive Imposter teammate information', () {
      final engine = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
      );
      engine.startNewGame();
      engine.addPlayer('Civilian1');
      engine.addPlayer('Civilian2');
      engine.addPlayer('Imp1');
      engine.addPlayer('Imp2');

      engine.updateSettings(
        engine.state.settings.copyWith(
          imposterCount: 2,
          impostersKnowEachOther: true,
        ),
      );
      engine.startGame();

      final civilians = engine.state.players.where((p) => p.isCivilian).toList();
      for (final civ in civilians) {
        expect(civ.isImposter, isFalse);
        // Civilians do not have teammate knowledge
      }
    });
  });

  group('V0.2 — Associated Word Database Architecture & Purity', () {
    test('Associated Word database stores only generic words without player names', () async {
      final service = AssociatedWordsService();
      await service.loadWords();

      for (final word in service.builtInWords) {
        expect(word.text.contains("'s "), isFalse);
        expect(word.text.contains("'"), isFalse);
      }

      await service.addUserWord('Headphones');
      for (final word in service.userWords) {
        expect(word.text.contains("'s "), isFalse);
      }
    });
  });

  group('V0.2 — Core Game Mechanics & Regressions', () {
    test('Voting and elimination works', () {
      final engine = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
      );
      engine.startNewGame();
      engine.addPlayer('P1');
      engine.addPlayer('P2');
      engine.addPlayer('P3');
      engine.startGame();

      engine.state.phase = GamePhase.voting;
      final target = engine.state.players.first;
      final selected = engine.selectAccusedPlayer(target.id);
      expect(selected, isTrue);

      final confirmed = engine.confirmGroupVote();
      expect(confirmed, isTrue);
      expect(target.isActive, isFalse);
      expect(engine.state.eliminatedPlayer, equals(target));
    });

    test('Hint system works according to showHintToImposter', () {
      // With hints enabled
      final engine1 = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
      );
      engine1.startNewGame();
      engine1.addPlayer('P1');
      engine1.addPlayer('P2');
      engine1.addPlayer('P3');
      engine1.setShowHintToImposter(true);
      engine1.startGame();

      final imposter1 = engine1.state.players.firstWhere((p) => p.isImposter);
      expect(imposter1.categoryHint, isNotNull);

      // With hints disabled
      final engine2 = GameEngine(
        roleManager: RoleManager(random: Random(42)),
        wordManager: WordManager(random: Random(42)),
      );
      engine2.startNewGame();
      engine2.addPlayer('P1');
      engine2.addPlayer('P2');
      engine2.addPlayer('P3');
      engine2.setShowHintToImposter(false);
      engine2.startGame();

      final imposter2 = engine2.state.players.firstWhere((p) => p.isImposter);
      expect(imposter2.categoryHint, isNull);
    });
  });
}
