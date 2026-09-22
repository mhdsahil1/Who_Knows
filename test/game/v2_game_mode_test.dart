import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:who_knows/game/game_engine.dart';
import 'package:who_knows/game/role_manager.dart';
import 'package:who_knows/game/win_condition.dart';
import 'package:who_knows/game/word_manager.dart';
import 'package:who_knows/models/enums.dart';
import 'package:who_knows/models/game_settings.dart';
import 'package:who_knows/services/storage_service.dart';

GameEngine _createEngine({int seed = 42, GameSettings? settings}) {
  final random = Random(seed);
  return GameEngine(
    wordManager: WordManager(random: random),
    roleManager: RoleManager(random: random),
    winCondition: const WinCondition(),
  )..updateSettings(settings ?? GameSettings());
}

void main() {
  group('Who Knows! V2.0.0 Game Mode Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    // ── 1. DEFAULT MODE TESTS ─────────────────────────────
    test('1. Default GameMode in GameSettings is classic', () {
      final settings = GameSettings();
      expect(settings.gameMode, equals(GameMode.classic));
    });

    test('2. New GameEngine starts in classic mode', () {
      final engine = _createEngine();
      expect(engine.state.settings.gameMode, equals(GameMode.classic));
    });

    // ── 2. PERSISTENCE & RESTORATION TESTS ────────────────
    test('3. GameMode persists and restores correctly', () async {
      final storage = StorageService();
      final settings = GameSettings(gameMode: GameMode.oneShotVote);
      await storage.saveSettings(settings);

      final loaded = await storage.loadSettings();
      expect(loaded.gameMode, equals(GameMode.oneShotVote));
    });

    test('4. Legacy or missing game mode defaults to classic', () async {
      SharedPreferences.setMockInitialValues({
        'game_mode': 'invalid_mode_name',
      });
      final storage = StorageService();
      final loaded = await storage.loadSettings();
      expect(loaded.gameMode, equals(GameMode.classic));
    });

    test('5. Empty storage defaults to classic', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final loaded = await storage.loadSettings();
      expect(loaded.gameMode, equals(GameMode.classic));
    });

    // ── 3. CLASSIC MODE ELIMINATION FLOW ──────────────────
    test('6. Classic Mode: Eliminating civilian advances to next discussion round', () {
      final engine = _createEngine();
      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');
      engine.addPlayer('Charlie');
      engine.addPlayer('Dave');
      engine.setGameMode(GameMode.classic);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      // Find civilian
      final civilian = engine.state.players.firstWhere((p) => !p.isImposter);
      final initialRound = engine.state.currentRound;

      // Cast vote
      engine.confirmGroupVote(civilian.id);
      expect(engine.state.phase, equals(GamePhase.voteResult));
      expect(civilian.isAlive, isFalse);

      // Proceed from vote result
      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.discussion));
      expect(engine.state.currentRound, equals(initialRound + 1));
      expect(engine.state.winner, equals(Winner.none));
    });

    test('7. Classic Mode: Eliminating imposter triggers final guess or civilian win', () {
      final engine = _createEngine();
      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');
      engine.addPlayer('Charlie');
      engine.addPlayer('Dave');
      engine.setGameMode(GameMode.classic);
      engine.setFinalGuessEnabled(true);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final imposter = engine.state.players.firstWhere((p) => p.isImposter);
      engine.confirmGroupVote(imposter.id);
      expect(engine.state.phase, equals(GamePhase.voteResult));

      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.finalGuess));
    });

    // ── 4. ONE-SHOT VOTE MODE FLOW ────────────────────────
    test('8. One-Shot Vote: Eliminating civilian results in immediate Imposter win', () {
      final engine = _createEngine();
      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');
      engine.addPlayer('Charlie');
      engine.addPlayer('Dave');
      engine.setGameMode(GameMode.oneShotVote);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final civilian = engine.state.players.firstWhere((p) => !p.isImposter);
      final success = engine.confirmGroupVote(civilian.id);

      expect(success, isTrue);
      expect(engine.state.oneShotVoteCompleted, isTrue);
      expect(engine.state.phase, equals(GamePhase.voteResult));

      // Proceed to game over
      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.imposters));
    });

    test('9. One-Shot Vote: Only one vote allowed per game', () {
      final engine = _createEngine();
      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');
      engine.addPlayer('Charlie');
      engine.addPlayer('Dave');
      engine.setGameMode(GameMode.oneShotVote);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final civilian = engine.state.players.firstWhere((p) => !p.isImposter);
      expect(engine.confirmGroupVote(civilian.id), isTrue);
      expect(engine.state.oneShotVoteCompleted, isTrue);

      // Attempt second vote
      final secondCivilian = engine.state.players.firstWhere((p) => !p.isImposter && p.isAlive);
      expect(engine.confirmGroupVote(secondCivilian.id), isFalse);
    });

    test('10. One-Shot Vote: Eliminating imposter with Final Guess OFF results in immediate Civilian win', () {
      final engine = _createEngine();
      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');
      engine.addPlayer('Charlie');
      engine.addPlayer('Dave');
      engine.setGameMode(GameMode.oneShotVote);
      engine.setFinalGuessEnabled(false);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final imposter = engine.state.players.firstWhere((p) => p.isImposter);
      final success = engine.confirmGroupVote(imposter.id);

      expect(success, isTrue);
      expect(engine.state.oneShotVoteCompleted, isTrue);
      expect(engine.state.phase, equals(GamePhase.voteResult));

      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.civilians));
    });

    // ── 5. FINAL GUESS IN ONE-SHOT VOTE ───────────────────
    test('11. One-Shot Vote: Eliminating imposter with Final Guess ON routes to Final Guess', () {
      final engine = _createEngine();
      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');
      engine.addPlayer('Charlie');
      engine.addPlayer('Dave');
      engine.setGameMode(GameMode.oneShotVote);
      engine.setFinalGuessEnabled(true);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final imposter = engine.state.players.firstWhere((p) => p.isImposter);
      engine.confirmGroupVote(imposter.id);

      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.finalGuess));

      // Imposter guesses correctly -> Imposter wins
      final secret = engine.state.secretWord!;
      engine.submitFinalGuess(secret);
      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.imposters));
    });

    test('12. One-Shot Vote: Imposter guessing incorrectly in Final Guess means Civilians win', () {
      final engine = _createEngine();
      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');
      engine.addPlayer('Charlie');
      engine.addPlayer('Dave');
      engine.setGameMode(GameMode.oneShotVote);
      engine.setFinalGuessEnabled(true);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final imposter = engine.state.players.firstWhere((p) => p.isImposter);
      engine.confirmGroupVote(imposter.id);
      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.finalGuess));

      engine.submitFinalGuess('COMPLETELY_WRONG_GUESS');
      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.civilians));
    });

    // ── 6. RESET & REPLAY COMPATIBILITY ───────────────────
    test('13. Resetting game resets oneShotVoteCompleted', () {
      final engine = _createEngine();
      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');
      engine.addPlayer('Charlie');
      engine.addPlayer('Dave');
      engine.setGameMode(GameMode.oneShotVote);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final civilian = engine.state.players.firstWhere((p) => !p.isImposter);
      engine.confirmGroupVote(civilian.id);
      expect(engine.state.oneShotVoteCompleted, isTrue);

      engine.resetForNewGame();
      expect(engine.state.oneShotVoteCompleted, isFalse);
      expect(engine.state.phase, equals(GamePhase.playerSetup));
    });

    // ── 7. PERSONAL WORD SOURCES & CHAOS MODE COMPATIBILITY ─
    test('14. One-Shot Vote works with Chaos Mode', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 6; i++) {
        engine.addPlayer('P$i');
      }
      engine.setGameMode(GameMode.oneShotVote);
      engine.setImposterMode(ImposterMode.chaos);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      expect(engine.state.settings.gameMode, equals(GameMode.oneShotVote));
      expect(engine.state.settings.imposterMode, equals(ImposterMode.chaos));

      final firstPlayer = engine.state.players.first;
      expect(engine.confirmGroupVote(firstPlayer.id), isTrue);
      expect(engine.state.oneShotVoteCompleted, isTrue);
    });

    // ── 8. MULTI-IMPOSTER ONE-SHOT VOTE TESTS ─────────────
    test('15. One-Shot Vote with 2 imposters: choosing all imposters correctly causes Civilians to win', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 6; i++) {
        engine.addPlayer('P$i');
      }
      engine.setGameMode(GameMode.oneShotVote);
      engine.setImposterMode(ImposterMode.fixed);
      engine.setCustomImposterCount(2);
      engine.setFinalGuessEnabled(false);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final imposters = engine.state.players.where((p) => p.isImposter).toList();
      expect(imposters.length, equals(2));

      final success = engine.confirmGroupVote(imposters.map((p) => p.id).toList());
      expect(success, isTrue);
      expect(engine.state.oneShotVoteCompleted, isTrue);

      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.civilians));
    });

    test('16. One-Shot Vote with 2 imposters: choosing 1 imposter and 1 civilian causes Imposters to win', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 6; i++) {
        engine.addPlayer('P$i');
      }
      engine.setGameMode(GameMode.oneShotVote);
      engine.setImposterMode(ImposterMode.fixed);
      engine.setCustomImposterCount(2);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final imposter = engine.state.players.firstWhere((p) => p.isImposter);
      final civilian = engine.state.players.firstWhere((p) => !p.isImposter);

      final success = engine.confirmGroupVote([imposter.id, civilian.id]);
      expect(success, isTrue);
      expect(engine.state.oneShotVoteCompleted, isTrue);

      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.imposters));
    });

    test('17. One-Shot Vote with 2 imposters: choosing only 1 imposter (missing the other) causes Imposters to win', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 6; i++) {
        engine.addPlayer('P$i');
      }
      engine.setGameMode(GameMode.oneShotVote);
      engine.setImposterMode(ImposterMode.fixed);
      engine.setCustomImposterCount(2);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final imposter = engine.state.players.firstWhere((p) => p.isImposter);

      // Only voting for 1 of the 2 imposters
      final success = engine.confirmGroupVote([imposter.id]);
      expect(success, isTrue);
      expect(engine.state.oneShotVoteCompleted, isTrue);

      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.imposters));
    });

    test('18. One-Shot Vote with 2 imposters: choosing all imposters with Final Guess ON routes to Final Guess', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 6; i++) {
        engine.addPlayer('P$i');
      }
      engine.setGameMode(GameMode.oneShotVote);
      engine.setImposterMode(ImposterMode.fixed);
      engine.setCustomImposterCount(2);
      engine.setFinalGuessEnabled(true);
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final imposters = engine.state.players.where((p) => p.isImposter).toList();
      final success = engine.confirmGroupVote(imposters.map((p) => p.id).toList());
      expect(success, isTrue);

      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.finalGuess));
    });

    test('19. toggleAccusedPlayer supports multi-selection with maxSelectable limit', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 1; i <= 5; i++) {
        engine.addPlayer('P$i');
      }
      engine.startGame();
      engine.state.phase = GamePhase.voting;

      final p1 = engine.state.players[0].id;
      final p2 = engine.state.players[1].id;
      final p3 = engine.state.players[2].id;

      expect(engine.toggleAccusedPlayer(p1, maxSelectable: 2), isTrue);
      expect(engine.state.selectedAccusedPlayerIds, equals([p1]));

      expect(engine.toggleAccusedPlayer(p2, maxSelectable: 2), isTrue);
      expect(engine.state.selectedAccusedPlayerIds, equals([p1, p2]));

      // Attempting to select 3rd when limit is 2 should fail
      expect(engine.toggleAccusedPlayer(p3, maxSelectable: 2), isFalse);
      expect(engine.state.selectedAccusedPlayerIds, equals([p1, p2]));

      // Toggling p1 removes it
      expect(engine.toggleAccusedPlayer(p1, maxSelectable: 2), isTrue);
      expect(engine.state.selectedAccusedPlayerIds, equals([p2]));
    });
  });
}
