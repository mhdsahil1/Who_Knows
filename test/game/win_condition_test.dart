import 'package:flutter_test/flutter_test.dart';
import 'package:who_knows/game/win_condition.dart';
import 'package:who_knows/models/enums.dart';
import 'package:who_knows/models/player.dart';

Player _makePlayer(String id, PlayerRole role) {
  return Player(id: id, name: id, role: role);
}

void main() {
  const winCondition = WinCondition();

  group('WinCondition', () {
    test('imposter caught triggers imposterCaught outcome', () {
      final imposter = _makePlayer('imp', PlayerRole.imposter);
      imposter.eliminate();
      final remaining = [
        _makePlayer('c1', PlayerRole.civilian),
        _makePlayer('c2', PlayerRole.civilian),
        _makePlayer('c3', PlayerRole.civilian),
      ];

      final outcome = winCondition.evaluateAfterElimination(
        eliminatedPlayer: imposter,
        remainingActivePlayers: remaining,
      );

      expect(outcome, equals(RoundOutcome.imposterCaught));
    });

    test('civilian eliminated continues game', () {
      final civilian = _makePlayer('c1', PlayerRole.civilian);
      civilian.eliminate();
      final remaining = [
        _makePlayer('c2', PlayerRole.civilian),
        _makePlayer('c3', PlayerRole.civilian),
        _makePlayer('imp', PlayerRole.imposter),
      ];

      final outcome = winCondition.evaluateAfterElimination(
        eliminatedPlayer: civilian,
        remainingActivePlayers: remaining,
      );

      expect(outcome, equals(RoundOutcome.civilianEliminated));
    });

    test('civilian eliminated causing imposter majority triggers impostersWin', () {
      final civilian = _makePlayer('c1', PlayerRole.civilian);
      civilian.eliminate();
      final remaining = [
        _makePlayer('c2', PlayerRole.civilian),
        _makePlayer('imp1', PlayerRole.imposter),
      ];

      final outcome = winCondition.evaluateAfterElimination(
        eliminatedPlayer: civilian,
        remainingActivePlayers: remaining,
      );

      expect(outcome, equals(RoundOutcome.impostersWin));
    });

    test('imposters outnumber civilians detected', () {
      final active = [
        _makePlayer('imp1', PlayerRole.imposter),
        _makePlayer('imp2', PlayerRole.imposter),
        _makePlayer('c1', PlayerRole.civilian),
      ];

      expect(winCondition.impostersOutnumberCivilians(active), isTrue);
    });

    test('civilians outnumber imposters detected', () {
      final active = [
        _makePlayer('imp1', PlayerRole.imposter),
        _makePlayer('c1', PlayerRole.civilian),
        _makePlayer('c2', PlayerRole.civilian),
        _makePlayer('c3', PlayerRole.civilian),
      ];

      expect(winCondition.impostersOutnumberCivilians(active), isFalse);
    });

    test('all imposters eliminated detected', () {
      final players = [
        _makePlayer('imp', PlayerRole.imposter)..eliminate(),
        _makePlayer('c1', PlayerRole.civilian),
        _makePlayer('c2', PlayerRole.civilian),
      ];

      expect(winCondition.allImpostersEliminated(players), isTrue);
    });

    test('not all imposters eliminated detected', () {
      final players = [
        _makePlayer('imp1', PlayerRole.imposter)..eliminate(),
        _makePlayer('imp2', PlayerRole.imposter),
        _makePlayer('c1', PlayerRole.civilian),
      ];

      expect(winCondition.allImpostersEliminated(players), isFalse);
    });

    test('final guess correct (case-insensitive)', () {
      expect(
        winCondition.checkFinalGuess(guess: 'pizza', secretWord: 'Pizza'),
        isTrue,
      );
    });

    test('final guess correct with whitespace', () {
      expect(
        winCondition.checkFinalGuess(guess: '  Pizza  ', secretWord: 'Pizza'),
        isTrue,
      );
    });

    test('final guess incorrect', () {
      expect(
        winCondition.checkFinalGuess(guess: 'Burger', secretWord: 'Pizza'),
        isFalse,
      );
    });
  });
}
