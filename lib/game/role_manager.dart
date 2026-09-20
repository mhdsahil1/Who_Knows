import 'dart:math';

import '../models/player.dart';
import '../models/enums.dart';
import '../models/word.dart';

/// Result of role assignment — returned to GameEngine to apply.
class RoleAssignment {
  final Map<String, PlayerRole> roles;
  final Map<String, String?> secretWords;
  final Map<String, String?> categoryHints;

  const RoleAssignment({
    required this.roles,
    required this.secretWords,
    required this.categoryHints,
  });
}

/// Assigns roles and secret information to players.
/// Does NOT mutate players — returns a result for GameEngine to apply.
class RoleManager {
  final Random _random;

  RoleManager({Random? random}) : _random = random ?? Random();

  /// Assign roles for the given players and word(s).
  /// If [uniqueWords] is provided, each player gets their respective unique word (for Chaos Words mode).
  RoleAssignment assignRoles({
    required List<Player> players,
    Word? word,
    List<Word>? uniqueWords,
    required int imposterCount,
    bool allowAllImposters = false,
  }) {
    final activePlayers = players.where((p) => p.isActive).toList();

    if (activePlayers.length < 3) {
      throw ArgumentError('Need at least 3 active players');
    }

    final maxAllowed = allowAllImposters
        ? activePlayers.length
        : (activePlayers.length - 2).clamp(0, activePlayers.length);
    final clampedCount = imposterCount.clamp(0, maxAllowed);

    // Shuffle a copy of the active player indices to pick imposters randomly.
    final indices = List<int>.generate(activePlayers.length, (i) => i);
    indices.shuffle(_random);
    final imposterIndices = indices.take(clampedCount).toSet();

    final roles = <String, PlayerRole>{};
    final secretWords = <String, String?>{};
    final categoryHints = <String, String?>{};

    for (var i = 0; i < activePlayers.length; i++) {
      final player = activePlayers[i];
      final playerWord = uniqueWords != null && i < uniqueWords.length
          ? uniqueWords[i]
          : word;

      if (imposterIndices.contains(i)) {
        roles[player.id] = PlayerRole.imposter;
        secretWords[player.id] = uniqueWords != null ? playerWord?.word : null;
        categoryHints[player.id] = playerWord?.category;
      } else {
        roles[player.id] = PlayerRole.civilian;
        secretWords[player.id] = playerWord?.word;
        categoryHints[player.id] = null;
      }
    }

    return RoleAssignment(
      roles: roles,
      secretWords: secretWords,
      categoryHints: categoryHints,
    );
  }
}
