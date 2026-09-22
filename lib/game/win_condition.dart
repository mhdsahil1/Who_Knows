import '../models/player.dart';

/// Outcome after evaluating a round.
enum RoundOutcome {
  /// A civilian was eliminated — game continues.
  civilianEliminated,

  /// An imposter was caught — proceed to final guess.
  imposterCaught,

  /// Imposters outnumber or equal civilians — imposters win.
  impostersWin,

  /// No valid outcome (shouldn't happen in normal play).
  invalid,
}

/// Evaluates win/loss conditions.
/// Pure calculator — does not mutate any state.
class WinCondition {
  const WinCondition();

  /// Determine what happens after a player is eliminated.
  RoundOutcome evaluateAfterElimination({
    required Player eliminatedPlayer,
    required List<Player> remainingActivePlayers,
  }) {
    if (eliminatedPlayer.isImposter) {
      return RoundOutcome.imposterCaught;
    }

    // Civilian was eliminated — check if imposters now dominate.
    final activeImposters =
        remainingActivePlayers.where((p) => p.isImposter).length;
    final activeCivilians =
        remainingActivePlayers.where((p) => p.isCivilian).length;

    if (activeImposters > 0 && activeImposters >= activeCivilians) {
      return RoundOutcome.impostersWin;
    }

    return RoundOutcome.civilianEliminated;
  }

  /// Check if imposters have won due to numbers (called at various points).
  bool impostersOutnumberCivilians(List<Player> activePlayers) {
    final imposters = activePlayers.where((p) => p.isImposter).length;
    final civilians = activePlayers.where((p) => p.isCivilian).length;
    return imposters > 0 && imposters >= civilians;
  }

  /// Check if all imposters have been eliminated.
  bool allImpostersEliminated(List<Player> allPlayers) {
    return allPlayers
        .where((p) => p.isImposter && p.isActive)
        .isEmpty;
  }

  /// Compare the imposter's final guess to the secret word.
  ///
  /// For standard words, requires an exact (case-insensitive) match.
  /// For associated words (e.g. "Asheel's Bike"), accepts either the full phrase
  /// or the base generic word (e.g. "Bike"), but rejects player-only or other variants.
  bool checkFinalGuess({
    required String guess,
    required String secretWord,
  }) {
    final g = guess.trim().toLowerCase();
    final s = secretWord.trim().toLowerCase();
    if (g.isEmpty) return false;
    if (g == s) return true;

    // If secretWord is an associated word phrase (e.g. "Asheel's Bike"),
    // also accept the base generic word (e.g. "Bike").
    if (s.contains("'s ")) {
      final baseWord = s.split("'s ").sublist(1).join("'s ").trim();
      if (g == baseWord) return true;
    }

    return false;
  }
}
