import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:who_knows/constants/game_constants.dart';
import 'package:who_knows/game/game_engine.dart';
import 'package:who_knows/game/role_manager.dart';
import 'package:who_knows/game/win_condition.dart';
import 'package:who_knows/game/word_manager.dart';
import 'package:who_knows/models/enums.dart';
import 'package:who_knows/models/game_settings.dart';
import 'package:who_knows/models/player.dart';

/// Create a GameEngine with a seeded random for deterministic tests.
GameEngine _createEngine({int seed = 42, GameSettings? settings}) {
  final random = Random(seed);
  return GameEngine(
    wordManager: WordManager(random: random),
    roleManager: RoleManager(random: random),
    winCondition: const WinCondition(),
  )..updateSettings(settings ?? GameSettings());
}

/// Add n players and start the game, returning the engine in roleReveal phase.
GameEngine _setupAndStart({
  int playerCount = 6,
  int imposterCount = 1,
  int seed = 42,
}) {
  final engine = _createEngine(
    seed: seed,
    settings: GameSettings(imposterCount: imposterCount),
  );
  engine.startNewGame();
  for (var i = 0; i < playerCount; i++) {
    engine.addPlayer('Player $i');
  }
  final error = engine.startGame();
  assert(error == null, 'startGame failed: $error');
  return engine;
}

/// Advance past all role reveals.
void _revealAll(GameEngine engine) {
  final count = engine.state.activePlayers.length;
  for (var i = 0; i < count; i++) {
    engine.nextReveal();
  }
}

void main() {
  group('Who knows! — Required 20 Unit Tests', () {
    // 1. Minimum player count
    test('1. Minimum player count', () {
      final engine = _createEngine();
      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');

      expect(engine.state.players.length, equals(2));
      final error = engine.startGame();
      expect(error, contains('Need at least ${GameConstants.minPlayers} players'));
      expect(engine.state.phase, equals(GamePhase.playerSetup));

      engine.addPlayer('Charlie');
      expect(engine.state.players.length, equals(3));
      final successError = engine.startGame();
      expect(successError, isNull);
      expect(engine.state.phase, equals(GamePhase.roleReveal));
    });

    // 2. Maximum player count
    test('2. Maximum player count', () {
      final engine = _createEngine();
      engine.startNewGame();
      for (var i = 0; i < GameConstants.maxPlayers; i++) {
        expect(engine.addPlayer('Player $i'), isTrue);
      }
      expect(engine.state.players.length, equals(GameConstants.maxPlayers));
      expect(engine.addPlayer('Player 21'), isFalse);
      expect(engine.state.players.length, equals(GameConstants.maxPlayers));
    });

    // 3. Player creation
    test('3. Player creation', () {
      final engine = _createEngine();
      engine.startNewGame();
      expect(engine.addPlayer('Sahil'), isTrue);
      expect(engine.addPlayer(''), isFalse);
      expect(engine.addPlayer('   '), isFalse);
      expect(engine.addPlayer('A very long name that exceeds max characters limit'), isFalse);

      final player = engine.state.players.first;
      expect(player.name, equals('Sahil'));

      // Edit player name
      expect(engine.editPlayerName(player.id, 'Rahul'), isTrue);
      expect(engine.state.players.first.name, equals('Rahul'));
      expect(engine.editPlayerName(player.id, ''), isFalse);
    });

    // 4. Imposter assignment
    test('4. Imposter assignment', () {
      final engine = _setupAndStart(playerCount: 6);
      final imposters = engine.state.players.where((p) => p.isImposter).toList();
      expect(imposters.length, equals(1));

      final civilians = engine.state.players.where((p) => p.isCivilian).toList();
      expect(civilians.length, equals(5));
    });

    // 5. Civilian receives word
    test('5. Civilian receives word', () {
      final engine = _setupAndStart();
      final secretWord = engine.state.currentWord!.word;
      final civilians = engine.state.activeCivilians;

      for (final civ in civilians) {
        expect(civ.secretWord, equals(secretWord));
        expect(civ.categoryHint, isNull);
      }
    });

    // 6. Imposter does not receive word
    test('6. Imposter does not receive word', () {
      final engine = _setupAndStart();
      final category = engine.state.currentWord!.category;
      final imposters = engine.state.activeImposters;

      for (final imp in imposters) {
        expect(imp.secretWord, isNull);
        expect(imp.categoryHint, equals(category));
      }
    });

    // 7. Role reveal progression
    test('7. Role reveal progression', () {
      final engine = _setupAndStart(playerCount: 4);
      expect(engine.state.currentRevealIndex, equals(0));
      expect(engine.state.currentRevealPlayer?.name, equals('Player 0'));

      engine.nextReveal();
      expect(engine.state.currentRevealIndex, equals(1));
      expect(engine.state.currentRevealPlayer?.name, equals('Player 1'));

      engine.nextReveal();
      expect(engine.state.currentRevealIndex, equals(2));
      expect(engine.state.currentRevealPlayer?.name, equals('Player 2'));
    });

    // 8. Role information reset/hide
    test('8. Role information reset/hide', () {
      final player = Player(
        id: 'p1',
        name: 'Test',
        role: PlayerRole.civilian,
        secretWord: 'Pizza',
        categoryHint: null,
      );
      player.resetRole();
      expect(player.role, equals(PlayerRole.unassigned));
      expect(player.secretWord, isNull);
      expect(player.categoryHint, isNull);
    });

    // 9. Role reveal → discussion transition
    test('9. Role reveal → discussion transition', () {
      final engine = _setupAndStart(playerCount: 3);
      expect(engine.state.phase, equals(GamePhase.roleReveal));

      _revealAll(engine);
      expect(engine.state.phase, equals(GamePhase.discussion));
    });

    // 10. Discussion → voting transition
    test('10. Discussion → voting transition', () {
      final engine = _setupAndStart();
      _revealAll(engine);
      expect(engine.state.phase, equals(GamePhase.discussion));

      engine.startVoting();
      expect(engine.state.phase, equals(GamePhase.voting));
      expect(engine.state.selectedAccusedPlayerId, isNull);
    });

    // 11. Group accusation selection
    test('11. Group accusation selection', () {
      final engine = _setupAndStart();
      _revealAll(engine);
      engine.startVoting();

      final target = engine.state.activePlayers.first;
      final selected = engine.selectAccusedPlayer(target.id);
      expect(selected, isTrue);
      expect(engine.state.selectedAccusedPlayerId, equals(target.id));
      expect(engine.state.selectedAccusedPlayer?.id, equals(target.id));
    });

    // 12. Cannot select eliminated player
    test('12. Cannot select eliminated player', () {
      final engine = _setupAndStart();
      _revealAll(engine);
      engine.startVoting();

      final firstCivilian = engine.state.activeCivilians.first;
      engine.selectAccusedPlayer(firstCivilian.id);
      engine.confirmGroupVote();
      engine.proceedFromVoteResult(); // Now back in discussion

      expect(firstCivilian.isEliminated, isTrue);

      engine.startVoting();
      final selectAttempt = engine.selectAccusedPlayer(firstCivilian.id);
      expect(selectAttempt, isFalse);
      expect(engine.state.selectedAccusedPlayerId, isNull);
    });

    // 13. Civilian elimination
    test('13. Civilian elimination', () {
      final engine = _setupAndStart(playerCount: 6);
      _revealAll(engine);
      engine.startVoting();

      final civilian = engine.state.activeCivilians.first;
      engine.selectAccusedPlayer(civilian.id);
      final confirmed = engine.confirmGroupVote();

      expect(confirmed, isTrue);
      expect(civilian.status, equals(PlayerStatus.eliminated));
      expect(civilian.isEliminated, isTrue);
      expect(engine.state.players.contains(civilian), isTrue); // Not deleted!
      expect(engine.state.eliminatedPlayers.contains(civilian), isTrue);
      expect(engine.state.activePlayers.contains(civilian), isFalse);
      expect(engine.state.phase, equals(GamePhase.voteResult));
      expect(engine.state.caughtImposter, isNull);
    });

    // 14. Civilian elimination → discussion
    test('14. Civilian elimination → discussion', () {
      final engine = _setupAndStart(playerCount: 6);
      _revealAll(engine);
      engine.startVoting();

      final civilian = engine.state.activeCivilians.first;
      engine.selectAccusedPlayer(civilian.id);
      engine.confirmGroupVote();
      expect(engine.state.phase, equals(GamePhase.voteResult));

      final roundBefore = engine.state.roundNumber;
      engine.proceedFromVoteResult();

      expect(engine.state.phase, equals(GamePhase.discussion));
      expect(engine.state.roundNumber, equals(roundBefore + 1));
      expect(engine.state.activePlayers.length, equals(5));
    });

    // 15. Imposter elimination → final guess
    test('15. Imposter elimination → final guess', () {
      final engine = _setupAndStart(playerCount: 6);
      _revealAll(engine);
      engine.startVoting();

      final imposter = engine.state.activeImposters.first;
      engine.selectAccusedPlayer(imposter.id);
      engine.confirmGroupVote();

      expect(engine.state.phase, equals(GamePhase.voteResult));
      expect(engine.state.caughtImposter, equals(imposter));

      engine.proceedFromVoteResult();
      expect(engine.state.phase, equals(GamePhase.finalGuess));
    });

    // 16. Correct final guess
    test('16. Correct final guess', () {
      final engine = _setupAndStart(playerCount: 6);
      _revealAll(engine);
      engine.startVoting();

      final imposter = engine.state.activeImposters.first;
      engine.selectAccusedPlayer(imposter.id);
      engine.confirmGroupVote();
      engine.proceedFromVoteResult();

      final secretWord = engine.state.currentWord!.word;
      // Case-insensitive & trimmed
      engine.submitFinalGuess('  ${secretWord.toLowerCase()}  ');

      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.imposters));
    });

    // 17. Incorrect final guess
    test('17. Incorrect final guess', () {
      final engine = _setupAndStart(playerCount: 6);
      _revealAll(engine);
      engine.startVoting();

      final imposter = engine.state.activeImposters.first;
      engine.selectAccusedPlayer(imposter.id);
      engine.confirmGroupVote();
      engine.proceedFromVoteResult();

      engine.submitFinalGuess('definitely wrong guess 12345');

      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.civilians));
    });

    // 18. Game over
    test('18. Game over', () {
      final engine = _setupAndStart();
      _revealAll(engine);
      engine.startVoting();

      final imposter = engine.state.activeImposters.first;
      engine.selectAccusedPlayer(imposter.id);
      engine.confirmGroupVote();
      engine.proceedFromVoteResult();
      engine.submitFinalGuess(engine.state.currentWord!.word);

      expect(engine.state.phase, equals(GamePhase.gameOver));
      expect(engine.state.winner, equals(Winner.imposters));
      expect(engine.state.activePlayers.isNotEmpty, isTrue);
    });

    // 19. Game reset
    test('19. Game reset', () {
      final engine = _setupAndStart(playerCount: 4);
      _revealAll(engine);
      engine.startVoting();

      final imp = engine.state.activeImposters.first;
      engine.selectAccusedPlayer(imp.id);
      engine.confirmGroupVote();
      engine.proceedFromVoteResult();
      engine.submitFinalGuess('wrong');
      expect(engine.state.phase, equals(GamePhase.gameOver));

      // Play again preserves players
      engine.playAgain();
      expect(engine.state.phase, equals(GamePhase.playerSetup));
      expect(engine.state.players.length, equals(4));
      for (final p in engine.state.players) {
        expect(p.isActive, isTrue);
        expect(p.role, equals(PlayerRole.unassigned));
      }

      // Return to lobby
      engine.returnToLobby();
      expect(engine.state.phase, equals(GamePhase.lobby));
    });

    // 20. Invalid game configurations
    test('20. Invalid game configurations', () {
      final engine = _createEngine();
      // Cannot start from lobby
      expect(engine.startGame(), equals('Cannot start game from current phase'));

      engine.startNewGame();
      // Reject duplicate player names
      expect(engine.addPlayer('Sahil'), isTrue);
      expect(engine.addPlayer('sahil'), isFalse);
      expect(engine.addPlayer('SAHIL'), isFalse);

      // 2 players cannot start
      engine.addPlayer('Arun');
      expect(engine.startGame(), isNotNull);

      // Cannot select non-existent or unselected player
      engine.addPlayer('Meera');
      engine.startGame();
      _revealAll(engine);
      engine.startVoting();
      expect(engine.selectAccusedPlayer('non_existent_id'), isFalse);
      expect(engine.confirmGroupVote(), isFalse);
    });

    // 21. Imposter count screen start game transition (6 players, 1 imposter)
    test('21. Imposter count screen transition with 6 players and 1 imposter', () {
      final engine = _createEngine();
      engine.startNewGame();
      expect(engine.state.currentPhase, equals(GamePhase.playerSetup));

      // Add 6 players
      final names = ['Alice', 'Bob', 'Charlie', 'Diana', 'Evan', 'Fiona'];
      for (final name in names) {
        expect(engine.addPlayer(name), isTrue);
      }
      expect(engine.state.players.length, equals(6));

      // Set 1 imposter (default & recommended)
      engine.setImposterCount(1);
      expect(engine.state.settings.imposterCount, equals(1));
      expect(engine.state.currentPhase, equals(GamePhase.playerSetup));

      // Request start game
      final error = engine.startGame();
      expect(error, isNull);

      // Verify phase transitioned to roleReveal
      expect(engine.state.currentPhase, equals(GamePhase.roleReveal));
      expect(engine.state.phase, equals(GamePhase.roleReveal));

      // Verify word selected
      expect(engine.state.currentWord, isNotNull);
      expect(engine.state.secretWord, isNotNull);
      expect(engine.state.secretWord!.isNotEmpty, isTrue);

      // Verify role assignment
      expect(engine.state.activeImposters.length, equals(1));
      expect(engine.state.activeCivilians.length, equals(5));

      final imposter = engine.state.activeImposters.first;
      expect(imposter.role, equals(PlayerRole.imposter));
      expect(imposter.secretWord, isNull);
      expect(imposter.categoryHint, equals(engine.state.currentWord!.category));

      for (final civ in engine.state.activeCivilians) {
        expect(civ.role, equals(PlayerRole.civilian));
        expect(civ.secretWord, equals(engine.state.secretWord));
        expect(civ.categoryHint, isNull);
      }
    });

    // 22. Player and imposter validation errors before startGame
    test('22. Player and imposter validation errors before startGame', () {
      final engine = _createEngine();
      engine.startNewGame();

      // Empty players
      expect(engine.startGame(), equals('No players added. Please add players first.'));

      // 1 player
      engine.addPlayer('Alice');
      expect(engine.startGame(), equals('Need at least 3 players'));

      // 2 players
      engine.addPlayer('Bob');
      expect(engine.startGame(), equals('Need at least 3 players'));

      // 3 players with invalid imposter count
      engine.addPlayer('Charlie');
      engine.updateSettings(engine.state.settings.copyWith(imposterCount: 3));
      expect(engine.startGame(), equals('Imposter count must be less than player count'));
    });
  });
}
