/// A custom word added by the user to "My Words".
class MyWord {
  final String id;
  final String text;
  final DateTime createdAt;

  const MyWord({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  MyWord copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
  }) {
    return MyWord(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MyWord.fromJson(Map<String, dynamic> json) => MyWord(
        id: json['id'] as String,
        text: json['text'] as String,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyWord && id == other.id && text == other.text;

  @override
  int get hashCode => Object.hash(id, text);

  @override
  String toString() => 'MyWord($id, $text)';
}
