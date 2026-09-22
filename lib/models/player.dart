import 'enums.dart';

/// A single player in the game.
class Player {
  final String id;
  String name;
  PlayerRole role;
  PlayerStatus status;

  /// The secret word (only meaningful for civilians).
  String? secretWord;

  /// The category hint (only meaningful for imposters).
  String? categoryHint;

  Player({
    required this.id,
    required this.name,
    this.role = PlayerRole.unassigned,
    this.status = PlayerStatus.active,
    this.secretWord,
    this.categoryHint,
  });

  void editName(String newName) {
    name = newName;
  }

  bool get isActive => status == PlayerStatus.active;
  bool get isAlive => isActive;
  bool get isEliminated => status == PlayerStatus.eliminated;
  bool get isImposter => role == PlayerRole.imposter;
  bool get isCivilian => role == PlayerRole.civilian;

  void eliminate() {
    status = PlayerStatus.eliminated;
  }

  void resetRole() {
    role = PlayerRole.unassigned;
    secretWord = null;
    categoryHint = null;
  }

  Player copyWith({
    String? id,
    String? name,
    PlayerRole? role,
    PlayerStatus? status,
    String? secretWord,
    String? categoryHint,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      secretWord: secretWord ?? this.secretWord,
      categoryHint: categoryHint ?? this.categoryHint,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Player && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Player($name, $role, $status)';
}
