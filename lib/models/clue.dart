/// A clue given by a player during the clue phase.
class Clue {
  final String playerId;
  final String text;

  const Clue({
    required this.playerId,
    required this.text,
  });

  @override
  String toString() => 'Clue($playerId: $text)';
}
