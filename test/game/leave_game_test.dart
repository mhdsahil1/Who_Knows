import 'package:flutter_test/flutter_test.dart';
import 'package:who_knows/game/game_engine.dart';
import 'package:who_knows/models/enums.dart';

void main() {
  group('LeaveGame Tests', () {
    late GameEngine engine;

    setUp(() {
      engine = GameEngine();
      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');
      engine.addPlayer('Charlie');
    });

    test('leaveGame from playerSetup resets to lobby phase', () {
      expect(engine.state.phase, GamePhase.playerSetup);
      engine.leaveGame();
      expect(engine.state.phase, GamePhase.lobby);
      expect(engine.state.players, isEmpty);
    });

    test('leaveGame from roleReveal resets to lobby phase', () {
      final err = engine.startGame();
      expect(err, isNull);
      expect(engine.state.phase, GamePhase.roleReveal);

      engine.leaveGame();
      expect(engine.state.phase, GamePhase.lobby);
      expect(engine.state.players, isEmpty);
      expect(engine.state.currentWord, isNull);
    });

    test('leaveGame from discussion resets to lobby phase', () {
      engine.startGame();
      engine.completeRoleReveal();
      expect(engine.state.phase, GamePhase.discussion);

      engine.leaveGame();
      expect(engine.state.phase, GamePhase.lobby);
    });

    test('leaveGame from voting resets to lobby phase', () {
      engine.startGame();
      engine.completeRoleReveal();
      engine.startVoting();
      expect(engine.state.phase, GamePhase.voting);

      engine.leaveGame();
      expect(engine.state.phase, GamePhase.lobby);
    });

    test('leaveGame preserves game settings', () {
      engine.setShowHintToImposter(false);
      engine.setFinalGuessEnabled(false);
      engine.setImposterCount(2);

      engine.leaveGame();

      expect(engine.state.settings.showHintToImposter, false);
      expect(engine.state.settings.finalGuessEnabled, false);
      expect(engine.state.settings.imposterCount, 2);
    });

    test('showHintToImposter setting controls categoryHint on players', () {
      // With hints enabled:
      engine.setShowHintToImposter(true);
      engine.startGame();
      final imposterWithHint = engine.state.players.firstWhere((p) => p.isImposter);
      expect(imposterWithHint.categoryHint, isNotNull);

      // Reset and test with hints disabled:
      engine.leaveGame();
      engine.startNewGame();
      engine.addPlayer('Alice');
      engine.addPlayer('Bob');
      engine.addPlayer('Charlie');
      engine.setShowHintToImposter(false);
      engine.startGame();
      final imposterWithoutHint = engine.state.players.firstWhere((p) => p.isImposter);
      expect(imposterWithoutHint.categoryHint, isNull);
    });
  });
}
