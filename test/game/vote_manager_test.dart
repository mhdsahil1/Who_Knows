import 'package:flutter_test/flutter_test.dart';
import 'package:who_knows/game/vote_manager.dart';
import 'package:who_knows/models/vote.dart';

void main() {
  const voteManager = VoteManager();

  group('VoteManager', () {
    test('tallies votes correctly', () {
      final votes = [
        const Vote(voterId: 'p1', targetId: 'p3'),
        const Vote(voterId: 'p2', targetId: 'p3'),
        const Vote(voterId: 'p3', targetId: 'p1'),
      ];

      final result = voteManager.tallyVotes(votes);

      expect(result.tally['p3'], equals(2));
      expect(result.tally['p1'], equals(1));
      expect(result.isTie, isFalse);
      expect(result.topVotedPlayerIds, equals(['p3']));
    });

    test('detects a tie', () {
      final votes = [
        const Vote(voterId: 'p1', targetId: 'p2'),
        const Vote(voterId: 'p2', targetId: 'p1'),
        const Vote(voterId: 'p3', targetId: 'p2'),
        const Vote(voterId: 'p4', targetId: 'p1'),
      ];

      final result = voteManager.tallyVotes(votes);

      expect(result.isTie, isTrue);
      expect(result.topVotedPlayerIds.length, equals(2));
      expect(result.topVotedPlayerIds, containsAll(['p1', 'p2']));
    });

    test('handles empty votes', () {
      final result = voteManager.tallyVotes([]);

      expect(result.tally, isEmpty);
      expect(result.topVotedPlayerIds, isEmpty);
      expect(result.isTie, isFalse);
    });

    test('handles single vote', () {
      final votes = [const Vote(voterId: 'p1', targetId: 'p2')];

      final result = voteManager.tallyVotes(votes);

      expect(result.tally['p2'], equals(1));
      expect(result.isTie, isFalse);
      expect(result.topVotedPlayerIds, equals(['p2']));
    });

    test('handles unanimous vote', () {
      final votes = [
        const Vote(voterId: 'p1', targetId: 'p3'),
        const Vote(voterId: 'p2', targetId: 'p3'),
        const Vote(voterId: 'p4', targetId: 'p3'),
        const Vote(voterId: 'p5', targetId: 'p3'),
      ];

      final result = voteManager.tallyVotes(votes);

      expect(result.isTie, isFalse);
      expect(result.topVotedPlayerIds, equals(['p3']));
      expect(result.tally['p3'], equals(4));
    });

    test('handles three-way tie', () {
      final votes = [
        const Vote(voterId: 'p1', targetId: 'p2'),
        const Vote(voterId: 'p2', targetId: 'p3'),
        const Vote(voterId: 'p3', targetId: 'p1'),
      ];

      final result = voteManager.tallyVotes(votes);

      expect(result.isTie, isTrue);
      expect(result.topVotedPlayerIds.length, equals(3));
    });
  });
}
