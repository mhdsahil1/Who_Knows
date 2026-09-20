/// A word from the game database.
class Word {
  final String word;
  final String category;

  const Word({
    required this.word,
    required this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Word &&
          word == other.word &&
          category == other.category;

  @override
  int get hashCode => Object.hash(word, category);

  @override
  String toString() => 'Word($word, $category)';
}
