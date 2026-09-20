import '../models/vote.dart';

/// Result of a vote tally.
class VoteResult {
  /// Player ID → number of votes received.
  final Map<String, int> tally;

  /// The player(s) with the most votes.
  final List<String> topVotedPlayerIds;

  /// Whether the result is a tie between 2+ players.
  final bool isTie;

  const VoteResult({
    required this.tally,
    required this.topVotedPlayerIds,
    required this.isTie,
  });
}

/// Tallies votes and detects ties.
/// Pure calculator — does not mutate any state.
class VoteManager {
  const VoteManager();

  /// Count votes and determine the result.
  VoteResult tallyVotes(List<Vote> votes) {
    final tally = <String, int>{};

    for (final vote in votes) {
      tally[vote.targetId] = (tally[vote.targetId] ?? 0) + 1;
    }

    if (tally.isEmpty) {
      return const VoteResult(
        tally: {},
        topVotedPlayerIds: [],
        isTie: false,
      );
    }

    final maxVotes = tally.values.reduce((a, b) => a > b ? a : b);
    final topPlayers = tally.entries
        .where((e) => e.value == maxVotes)
        .map((e) => e.key)
        .toList();

    return VoteResult(
      tally: tally,
      topVotedPlayerIds: topPlayers,
      isTie: topPlayers.length > 1,
    );
  }
}
