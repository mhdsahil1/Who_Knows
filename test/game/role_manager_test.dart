import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:who_knows/game/role_manager.dart';
import 'package:who_knows/models/enums.dart';
import 'package:who_knows/models/player.dart';
import 'package:who_knows/models/word.dart';

List<Player> _makePlayers(int count) {
  return List.generate(
    count,
    (i) => Player(id: 'p$i', name: 'Player $i'),
  );
}

const _testWord = Word(
  word: 'Pizza',
  category: 'Food',
);

void main() {
  group('RoleManager', () {
    test('assigns exactly 1 imposter by default', () {
      final manager = RoleManager(random: Random(42));
      final players = _makePlayers(6);

      final result = manager.assignRoles(
        players: players,
        word: _testWord,
        imposterCount: 1,
      );

      final imposters =
          result.roles.values.where((r) => r == PlayerRole.imposter);
      final civilians =
          result.roles.values.where((r) => r == PlayerRole.civilian);

      expect(imposters.length, equals(1));
      expect(civilians.length, equals(5));
    });

    test('assigns 2 imposters when requested', () {
      final manager = RoleManager(random: Random(42));
      final players = _makePlayers(8);

      final result = manager.assignRoles(
        players: players,
        word: _testWord,
        imposterCount: 2,
      );

      final imposters =
          result.roles.values.where((r) => r == PlayerRole.imposter);
      expect(imposters.length, equals(2));
    });

    test('civilians receive the secret word', () {
      final manager = RoleManager(random: Random(42));
      final players = _makePlayers(6);

      final result = manager.assignRoles(
        players: players,
        word: _testWord,
        imposterCount: 1,
      );

      for (final entry in result.roles.entries) {
        if (entry.value == PlayerRole.civilian) {
          expect(result.secretWords[entry.key], equals('Pizza'));
          expect(result.categoryHints[entry.key], isNull);
        }
      }
    });

    test('imposter does NOT receive the secret word', () {
      final manager = RoleManager(random: Random(42));
      final players = _makePlayers(6);

      final result = manager.assignRoles(
        players: players,
        word: _testWord,
        imposterCount: 1,
      );

      for (final entry in result.roles.entries) {
        if (entry.value == PlayerRole.imposter) {
          expect(result.secretWords[entry.key], isNull);
        }
      }
    });

    test('imposter receives the category hint', () {
      final manager = RoleManager(random: Random(42));
      final players = _makePlayers(6);

      final result = manager.assignRoles(
        players: players,
        word: _testWord,
        imposterCount: 1,
      );

      for (final entry in result.roles.entries) {
        if (entry.value == PlayerRole.imposter) {
          expect(result.categoryHints[entry.key], equals('Food'));
        }
      }
    });

    test('clamps imposter count if too high', () {
      final manager = RoleManager(random: Random(42));
      final players = _makePlayers(4);

      // Requesting 3 imposters with 4 players → clamped to 2 (length - 2).
      final result = manager.assignRoles(
        players: players,
        word: _testWord,
        imposterCount: 3,
      );

      final imposters =
          result.roles.values.where((r) => r == PlayerRole.imposter);
      expect(imposters.length, equals(2));
    });

    test('throws for fewer than 3 players', () {
      final manager = RoleManager(random: Random(42));
      final players = _makePlayers(2);

      expect(
        () => manager.assignRoles(
          players: players,
          word: _testWord,
          imposterCount: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('assigns roles to minimum 3 players', () {
      final manager = RoleManager(random: Random(42));
      final players = _makePlayers(3);

      final result = manager.assignRoles(
        players: players,
        word: _testWord,
        imposterCount: 1,
      );

      expect(result.roles.length, equals(3));
      expect(
        result.roles.values.where((r) => r == PlayerRole.imposter).length,
        equals(1),
      );
    });

    test('assigns roles to maximum 20 players', () {
      final manager = RoleManager(random: Random(42));
      final players = _makePlayers(20);

      final result = manager.assignRoles(
        players: players,
        word: _testWord,
        imposterCount: 2,
      );

      expect(result.roles.length, equals(20));
      expect(
        result.roles.values.where((r) => r == PlayerRole.imposter).length,
        equals(2),
      );
    });

    test('only assigns roles to active players', () {
      final manager = RoleManager(random: Random(42));
      final players = _makePlayers(6);
      players[2].eliminate();

      final result = manager.assignRoles(
        players: players,
        word: _testWord,
        imposterCount: 1,
      );

      expect(result.roles.length, equals(5));
      expect(result.roles.containsKey('p2'), isFalse);
    });
  });
}
