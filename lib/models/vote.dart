/// A single vote: who voted for whom.
class Vote {
  final String voterId;
  final String targetId;

  const Vote({
    required this.voterId,
    required this.targetId,
  });

  @override
  String toString() => 'Vote($voterId -> $targetId)';
}
