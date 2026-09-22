/// A generic reusable word from the Associated Word Database.
///
/// Can be either built-in or user-added. Does not store any player names.
class AssociatedWord {
  final String id;
  final String text;
  final bool isBuiltIn;
  final DateTime createdAt;

  const AssociatedWord({
    required this.id,
    required this.text,
    this.isBuiltIn = false,
    required this.createdAt,
  });

  AssociatedWord copyWith({
    String? id,
    String? text,
    bool? isBuiltIn,
    DateTime? createdAt,
  }) {
    return AssociatedWord(
      id: id ?? this.id,
      text: text ?? this.text,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isBuiltIn': isBuiltIn,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AssociatedWord.fromJson(Map<String, dynamic> json) => AssociatedWord(
        id: json['id'] as String,
        text: json['text'] as String,
        isBuiltIn: json['isBuiltIn'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssociatedWord && id == other.id && text == other.text;

  @override
  int get hashCode => Object.hash(id, text);

  @override
  String toString() => 'AssociatedWord($id, $text, builtIn: $isBuiltIn)';
}
