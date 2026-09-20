import 'dart:math';

import 'package:flutter/foundation.dart';

import '../constants/game_constants.dart';
import '../models/enums.dart';
import '../models/game_settings.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import 'role_manager.dart';
import 'win_condition.dart';
import 'word_manager.dart';

/// The central game state machine for Who knows!
///
/// Only this class mutates [GameState].
/// UI calls explicit methods on this class.
class GameEngine extends ChangeNotifier {
  GameState _state;
  final WordManager _wordManager;
  final RoleManager _roleManager;
  final WinCondition _winCondition;

  GameEngine({
    GameState? initialState,
    WordManager? wordManager,
    RoleManager? roleManager,
    WinCondition? winCondition,
  })  : _state = initialState ?? GameState(),
        _wordManager = wordManager ?? WordManager(),
        _roleManager = roleManager ?? RoleManager(),
        _winCondition = winCondition ?? const WinCondition();

  /// Read-only access to current state.
  GameState get state => _state;

  // ── Phase: LOBBY → PLAYER_SETUP ─────────────────────

  /// Start a new game from the lobby.
  void startNewGame() {
    _state = GameState(
      phase: GamePhase.playerSetup,
      settings: _state.settings,
    );
    _wordManager.reset();
    notifyListeners();
  }

  // ── Phase: PLAYER_SETUP ─────────────────────────────

  /// Add a player with the given name. Returns false if invalid.
  bool addPlayer(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > GameConstants.maxNameLength) {
      return false;
    }
    if (_state.players.length >= GameConstants.maxPlayers) {
      return false;
    }
    // Check for duplicate names (case-insensitive).
    if (isNameTaken(trimmed)) {
      return false;
    }

    final id =
        'player_${_state.players.length}_${DateTime.now().millisecondsSinceEpoch}';
    _state.players.add(Player(id: id, name: trimmed));
    notifyListeners();
    return true;
  }

  /// Edit an existing player's name. Returns false if invalid or duplicate.
  bool editPlayerName(String playerId, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed.length > GameConstants.maxNameLength) {
      return false;
    }
    if (isNameTaken(trimmed, excludePlayerId: playerId)) {
      return false;
    }

    final playerIndex = _state.players.indexWhere((p) => p.id == playerId);
    if (playerIndex == -1) return false;

    _state.players[playerIndex].editName(trimmed);
    notifyListeners();
    return true;
  }

  /// Remove a player by ID.
  bool removePlayer(String playerId) {
    final lengthBefore = _state.players.length;
    _state.players.removeWhere((p) => p.id == playerId);
    notifyListeners();
    return _state.players.length < lengthBefore;
  }

  /// Reorder a player from oldIndex to newIndex.
  void reorderPlayer(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _state.players.length) return;
    var adjustedNew = newIndex;
    if (adjustedNew > oldIndex) adjustedNew--;
    if (adjustedNew < 0 || adjustedNew >= _state.players.length) return;

    final player = _state.players.removeAt(oldIndex);
    _state.players.insert(adjustedNew, player);
    notifyListeners();
  }

  /// Shuffle the player order randomly.
  void shufflePlayers() {
    _state.players.shuffle(Random());
    notifyListeners();
  }

  /// Update game settings.
  void updateSettings(GameSettings newSettings) {
    _state.settings = newSettings;
    notifyListeners();
  }

  /// Set the number of imposters.
  void setImposterCount(int count) {
    final safeCount = count.clamp(0, GameConstants.maxPlayers);
    _state.settings = _state.settings.copyWith(
      imposterCount: safeCount,
      customImposterCount: safeCount,
      imposterMode: ImposterMode.fixed,
    );
    notifyListeners();
  }

  /// Set the imposter mode (recommended, fixed, custom, chaos).
  void setImposterMode(ImposterMode mode) {
    _state.settings = _state.settings.copyWith(imposterMode: mode);
    notifyListeners();
  }

  /// Set custom imposter count.
  void setCustomImposterCount(int count) {
    final safeCount = count.clamp(0, _state.players.length);
    _state.settings = _state.settings.copyWith(
      customImposterCount: safeCount,
      imposterCount: safeCount,
    );
    notifyListeners();
  }

  /// Set game mode (normal, chaos).
  void setGameMode(GameMode mode) {
    _state.settings = _state.settings.copyWith(gameMode: mode);
    notifyListeners();
  }

  /// Set word distribution (shared, unique).
  void setWordDistribution(WordDistribution dist) {
    _state.settings = _state.settings.copyWith(wordDistribution: dist);
    notifyListeners();
  }

  /// Toggle final guess rule.
  void setFinalGuessEnabled(bool enabled) {
    _state.settings = _state.settings.copyWith(finalGuessEnabled: enabled);
    notifyListeners();
  }

  /// Toggle show hint to imposter.
  void setShowHintToImposter(bool enabled) {
    _state.settings = _state.settings.copyWith(showHintToImposter: enabled);
    notifyListeners();
  }

  /// Update selected categories.
  void setSelectedCategories(Set<String> categories) {
    _state.settings = _state.settings.copyWith(selectedCategories: categories);
    notifyListeners();
  }

  /// Helper to determine weighted random imposter count for Chaos Mode.
  int determineChaosImposterCount(int playerCount, [Random? random]) {
    final rng = random ?? Random();
    final weights = <int>[];
    for (var k = 0; k <= playerCount; k++) {
      if (k == 0) {
        weights.add(6); // rare 0 imposters
      } else if (k == 1) {
        weights.add(45); // common 1 imposter
      } else if (k == 2) {
        weights.add(35); // common 2 imposters
      } else if (k == 3) {
        weights.add(playerCount >= 5 ? 15 : 8);
      } else if (k == 4) {
        weights.add(playerCount >= 6 ? 8 : 4);
      } else if (k == playerCount) {
        weights.add(1); // all imposters: extremely rare
      } else {
        weights.add(max(1, 6 - (k - 4)));
      }
    }

    final totalWeight = weights.fold<int>(0, (sum, w) => sum + w);
    var roll = rng.nextInt(totalWeight);
    for (var i = 0; i < weights.length; i++) {
      if (roll < weights[i]) {
        return i;
      }
      roll -= weights[i];
    }
    return 1;
  }

  /// Validate player setup and transition to role reveal.
  /// Returns an error message if invalid, or null on success.
  String? startGame([GameSettings? overrideSettings]) {
    if (overrideSettings != null) {
      _state.settings = overrideSettings;
    }

    if (_state.phase != GamePhase.playerSetup) {
      return 'Cannot start game from current phase';
    }
    if (_state.players.isEmpty) {
      return 'No players added. Please add players first.';
    }
    if (_state.players.length < GameConstants.minPlayers) {
      return 'Need at least ${GameConstants.minPlayers} players';
    }
    if (_state.players.length > GameConstants.maxPlayers) {
      return 'Maximum ${GameConstants.maxPlayers} players allowed';
    }

    // Validate categories
    if (_state.settings.selectedCategories.isEmpty) {
      return 'Choose at least one category.';
    }

    // Determine Imposter count
    int effectiveImposters;
    final isChaos = _state.settings.gameMode == GameMode.chaos ||
        _state.settings.imposterMode == ImposterMode.chaos;

    if (isChaos) {
      effectiveImposters = determineChaosImposterCount(_state.players.length);
    } else {
      switch (_state.settings.imposterMode) {
        case ImposterMode.recommended:
          effectiveImposters = _state.players.length < 6 ? 1 : 2;
          break;
        case ImposterMode.fixed:
          effectiveImposters = _state.settings.imposterCount;
          break;
        case ImposterMode.custom:
          effectiveImposters = _state.settings.customImposterCount;
          break;
        case ImposterMode.chaos:
          effectiveImposters =
              determineChaosImposterCount(_state.players.length);
          break;
      }

      // Normal mode validations
      if (effectiveImposters < 0) {
        return 'Must have at least 0 imposters';
      }
      if (effectiveImposters > _state.players.length) {
        return 'Imposter count cannot exceed player count';
      }
      if (effectiveImposters > 0 &&
          effectiveImposters >= _state.players.length) {
        return 'Imposter count must be less than player count';
      }
    }

    // Update settings with effective count and mode
    _state.settings = _state.settings.copyWith(
      imposterCount: effectiveImposters,
      gameMode: isChaos ? GameMode.chaos : GameMode.normal,
    );

    final allowAll =
        isChaos || _state.settings.imposterMode == ImposterMode.custom;

    // Word selection & distribution
    if (_state.settings.wordDistribution == WordDistribution.unique) {
      final uniqueWords = _wordManager.pickUniqueWords(
        _state.players.length,
        categories: _state.settings.selectedCategories,
      );
      if (uniqueWords == null) {
        return 'Not enough unique words for Chaos Words.';
      }
      _state.assignedChaosWords = uniqueWords;
      _state.currentWord = uniqueWords.first;

      final assignment = _roleManager.assignRoles(
        players: _state.players,
        uniqueWords: uniqueWords,
        imposterCount: effectiveImposters,
        allowAllImposters: allowAll,
      );

      for (final player in _state.players) {
        if (assignment.roles.containsKey(player.id)) {
          player.role = assignment.roles[player.id]!;
          player.secretWord = assignment.secretWords[player.id];
          player.categoryHint = _state.settings.showHintToImposter
              ? assignment.categoryHints[player.id]
              : null;
        }
      }
    } else {
      final word = _wordManager.pickWord(
        categories: _state.settings.selectedCategories,
      );
      if (word == null) {
        return 'No words available for the selected categories';
      }
      _state.currentWord = word;
      _state.assignedChaosWords = [word];

      final assignment = _roleManager.assignRoles(
        players: _state.players,
        word: word,
        imposterCount: effectiveImposters,
        allowAllImposters: allowAll,
      );

      for (final player in _state.players) {
        if (assignment.roles.containsKey(player.id)) {
          player.role = assignment.roles[player.id]!;
          player.secretWord = assignment.secretWords[player.id];
          player.categoryHint = _state.settings.showHintToImposter
              ? assignment.categoryHints[player.id]
              : null;
        }
      }
    }

    _state.roundNumber = 1;
    _state.phase = GamePhase.roleReveal;
    _state.currentRevealIndex = 0;
    notifyListeners();
    return null;
  }

  // ── Phase: ROLE_REVEAL ──────────────────────────────

  /// Start or reset the role reveal phase.
  void beginRoleReveal() {
    _state.phase = GamePhase.roleReveal;
    _state.currentRevealIndex = 0;
    notifyListeners();
  }

  /// Advance to the next player's reveal or complete role reveal.
  void nextReveal() {
    if (_state.phase != GamePhase.roleReveal) return;

    _state.currentRevealIndex++;
    if (_state.currentRevealIndex >= _state.activePlayers.length) {
      // All players have seen their roles — transition directly to discussion!
      completeRoleReveal();
    } else {
      notifyListeners();
    }
  }

  /// Complete role reveal and transition to discussion.
  void completeRoleReveal() {
    _state.phase = GamePhase.discussion;
    notifyListeners();
  }

  /// Complete countdown and transition to discussion.
  void completeCountdown() {
    _state.phase = GamePhase.discussion;
    notifyListeners();
  }

  // ── Phase: DISCUSSION ───────────────────────────────

  /// Transition to the discussion screen.
  void startDiscussion() {
    _state.phase = GamePhase.discussion;
    notifyListeners();
  }

  /// End discussion and move to group voting screen.
  void startVoting() {
    if (_state.phase != GamePhase.discussion) return;
    _state.phase = GamePhase.voting;
    _state.selectedAccusedPlayerId = null;
    notifyListeners();
  }

  // ── Phase: GROUP VOTING ─────────────────────────────

  /// Select the player the group agreed upon (cannot be an eliminated player).
  bool selectAccusedPlayer(String playerId) {
    if (_state.phase != GamePhase.voting) return false;

    // Validate target is an active player.
    final isValid = _state.activePlayers.any((p) => p.id == playerId);
    if (!isValid) return false;

    _state.selectedAccusedPlayerId = playerId;
    notifyListeners();
    return true;
  }

  /// Confirm the group's vote for the selected player and process elimination.
  bool confirmGroupVote() {
    if (_state.phase != GamePhase.voting) return false;
    final accusedId = _state.selectedAccusedPlayerId;
    if (accusedId == null) return false;

    final targetIndex = _state.players.indexWhere((p) => p.id == accusedId);
    if (targetIndex == -1) return false;

    final eliminated = _state.players[targetIndex];
    if (!eliminated.isActive) return false;

    // Eliminate the selected player.
    eliminated.eliminate();
    _state.eliminatedPlayer = eliminated;

    final outcome = _winCondition.evaluateAfterElimination(
      eliminatedPlayer: eliminated,
      remainingActivePlayers: _state.activePlayers,
    );

    switch (outcome) {
      case RoundOutcome.imposterCaught:
        _state.caughtImposter = eliminated;
        _state.phase = GamePhase.voteResult;
        break;
      case RoundOutcome.civilianEliminated:
        _state.caughtImposter = null;
        _state.phase = GamePhase.voteResult;
        break;
      case RoundOutcome.impostersWin:
        _state.winner = Winner.imposters;
        _state.phase = GamePhase.gameOver;
        break;
      case RoundOutcome.invalid:
        break;
    }

    notifyListeners();
    return true;
  }

  // ── Phase: VOTE_RESULT ──────────────────────────────

  /// Proceed from vote result screen:
  /// - If Imposter caught:
  ///     - If finalGuessEnabled: moves to Final Guess screen.
  ///     - If !finalGuessEnabled: Civilians win immediately if all imposters eliminated!
  /// - If Civilian eliminated: resets for new round and returns directly to Discussion!
  void proceedFromVoteResult() {
    processVoteResult();
  }

  /// Explicit alias for proceedFromVoteResult.
  void processVoteResult() {
    if (_state.phase != GamePhase.voteResult) return;

    if (_state.caughtImposter != null) {
      if (_state.settings.finalGuessEnabled) {
        startFinalGuess();
      } else {
        // Final guess disabled: Civilians win immediately if all imposters caught
        final remainingImposters = _state.activeImposters;
        if (remainingImposters.isEmpty) {
          _state.winner = Winner.civilians;
          _state.phase = GamePhase.gameOver;
        } else {
          startNextRound();
        }
        notifyListeners();
      }
    } else {
      // Civilian eliminated — return directly to discussion for remaining active players.
      startNextRound();
    }
  }

  // ── Phase: FINAL_GUESS ──────────────────────────────

  /// Move to final guess screen.
  void startFinalGuess() {
    _state.phase = GamePhase.finalGuess;
    notifyListeners();
  }

  /// Submit the imposter's final guess (trimmed and case-insensitive).
  void submitFinalGuess(String guess) {
    if (_state.phase != GamePhase.finalGuess) return;
    if (_state.currentWord == null) return;

    final trimmed = guess.trim();
    _state.finalGuessText = trimmed;

    final correct = _winCondition.checkFinalGuess(
      guess: trimmed,
      secretWord: _state.currentWord!.word,
    );

    if (correct) {
      // Imposter guessed correctly — Imposter wins!
      _state.winner = Winner.imposters;
      _state.phase = GamePhase.gameOver;
    } else {
      // Wrong guess.
      final remainingImposters = _state.activeImposters;
      if (remainingImposters.isEmpty) {
        // All imposters eliminated — Civilians win!
        _state.winner = Winner.civilians;
        _state.phase = GamePhase.gameOver;
      } else {
        // Future multiple imposters branch: continue game.
        startNextRound();
        _state.caughtImposter = null;
        return;
      }
    }

    notifyListeners();
  }

  // ── Phase: NEXT ROUND & RESET ───────────────────────

  /// Reset round state and start next discussion round.
  void startNextRound() {
    _state.resetForNewRound();
    _state.phase = GamePhase.discussion;
    notifyListeners();
  }

  /// Play again with the same players.
  void playAgain() {
    restartGame();
  }

  /// Explicit alias for playAgain: resets game while preserving player names.
  void restartGame() {
    _state.resetForNewGame();
    _state.phase = GamePhase.playerSetup;
    notifyListeners();
  }

  /// Return to lobby screen.
  void returnToLobby() {
    _state = GameState(
      phase: GamePhase.lobby,
      settings: _state.settings,
    );
    _wordManager.reset();
    notifyListeners();
  }

  /// Leave game from any phase — fully resets state and returns to lobby.
  void leaveGame() {
    returnToLobby();
  }

  // ── Helpers ─────────────────────────────────────────

  /// Get the player who was most recently eliminated.
  Player? getLastEliminatedPlayer() {
    if (_state.eliminatedPlayer != null) {
      return _state.eliminatedPlayer;
    }
    final eliminated = _state.players.where((p) => p.isEliminated).toList();
    return eliminated.isNotEmpty ? eliminated.last : null;
  }

  /// Check if a player name already exists (case-insensitive).
  bool isNameTaken(String name, {String? excludePlayerId}) {
    final trimmed = name.trim().toLowerCase();
    return _state.players.any((p) =>
        p.id != excludePlayerId && p.name.trim().toLowerCase() == trimmed);
  }
}
