/// Core game configuration constants.
class GameConstants {
  GameConstants._();

  static const int minPlayers = 3;
  static const int maxPlayers = 20;

  /// Player threshold for recommending 2 imposters.
  static const int multiImposterThreshold = 6;

  static const int defaultImposterCount = 1;
  static const int maxImposters = 20;

  static const int minNameLength = 1;
  static const int maxNameLength = 16;

  /// Duration in seconds for the reveal screen auto-hide timer.
  static const int revealTimerSeconds = 30;

  static const String appName = 'Who Knows!';
  static const String tagline = 'Everyone knows. One doesn\'t.';
}
