// All game-related enumerations.

/// Phases of the game state machine.
enum GamePhase {
  lobby,
  playerSetup,
  roleReveal,
  countdown,
  discussion,
  voting,
  voteResult,
  finalGuess,
  gameOver,
}

/// A player's secret role.
enum PlayerRole {
  civilian,
  imposter,
  unassigned,
}

/// Whether a player is still in the game.
enum PlayerStatus {
  active,
  eliminated,
}


/// Who won the game.
enum Winner {
  civilians,
  imposters,
  none,
}

/// Imposter selection mode.
enum ImposterMode {
  recommended,
  fixed,
  custom,
  chaos,
}

/// Word distribution strategy.
enum WordDistribution {
  shared,
  unique,
}

/// Game mode.
enum GameMode {
  classic,
  oneShotVote,
}
