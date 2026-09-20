import 'enums.dart';
import 'player.dart';
import 'word.dart';
import 'game_settings.dart';

/// The complete snapshot of the game at any point in time.
class GameState {
  GamePhase phase;
  List<Player> players;
  GameSettings settings;
  Word? currentWord;
  int roundNumber;
  Winner winner;

  /// Index of the player currently being revealed (during roleReveal phase).
  int currentRevealIndex;

  /// The player selected by the group to accuse (during voting phase).
  String? selectedAccusedPlayerId;

  /// The player eliminated in the most recent group vote.
  Player? eliminatedPlayer;

  /// The imposter who was just caught (for finalGuess phase).
  Player? caughtImposter;

  /// The imposter's final guess text.
  String? finalGuessText;

  /// Unique words assigned in Chaos Words mode.
  List<Word> assignedChaosWords;

  GameState({
    this.phase = GamePhase.lobby,
    List<Player>? players,
    GameSettings? settings,
    this.currentWord,
    this.roundNumber = 1,
    this.winner = Winner.none,
    this.currentRevealIndex = 0,
    this.selectedAccusedPlayerId,
    this.eliminatedPlayer,
    this.caughtImposter,
    this.finalGuessText,
    List<Word>? assignedChaosWords,
  })  : players = players ?? [],
        settings = settings ?? GameSettings(),
        assignedChaosWords = assignedChaosWords ?? [];

  /// Current phase of the game (alias for [phase]).
  GamePhase get currentPhase => phase;
  set currentPhase(GamePhase newPhase) => phase = newPhase;

  /// Convenience getters for active configuration.
  bool get finalGuessEnabled => settings.finalGuessEnabled;
  GameMode get gameMode => settings.gameMode;
  WordDistribution get wordDistribution => settings.wordDistribution;
  Set<String> get selectedCategories => settings.selectedCategories;

  /// All players who are still in the game.
  List<Player> get activePlayers =>
      players.where((p) => p.isActive).toList();

  /// All players who have been eliminated.
  List<Player> get eliminatedPlayers =>
      players.where((p) => p.isEliminated).toList();

  /// Active imposters.
  List<Player> get activeImposters =>
      activePlayers.where((p) => p.isImposter).toList();

  /// Active civilians.
  List<Player> get activeCivilians =>
      activePlayers.where((p) => p.isCivilian).toList();

  /// IDs of all imposters.
  List<String> get imposterIds =>
      players.where((p) => p.isImposter).map((p) => p.id).toList();

  /// The secret word.
  String? get secretWord => currentWord?.word;

  /// The category.
  String? get category => currentWord?.category;

  /// The currently selected accused player, if any.
  Player? get selectedAccusedPlayer {
    if (selectedAccusedPlayerId == null) return null;
    final matches = players.where((p) => p.id == selectedAccusedPlayerId);
    return matches.isNotEmpty ? matches.first : null;
  }

  /// The player whose turn it is during reveal.
  Player? get currentRevealPlayer {
    if (currentRevealIndex < activePlayers.length) {
      return activePlayers[currentRevealIndex];
    }
    return null;
  }

  /// Reset state for a new game while preserving player names and settings.
  void resetForNewGame() {
    phase = GamePhase.playerSetup;
    currentWord = null;
    roundNumber = 1;
    winner = Winner.none;
    currentRevealIndex = 0;
    selectedAccusedPlayerId = null;
    eliminatedPlayer = null;
    caughtImposter = null;
    finalGuessText = null;
    assignedChaosWords.clear();
    for (final player in players) {
      player.status = PlayerStatus.active;
      player.resetRole();
    }
  }

  /// Reset state for a new round (after a civilian is eliminated).
  void resetForNewRound() {
    selectedAccusedPlayerId = null;
    eliminatedPlayer = null;
    roundNumber++;
  }
}
