import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game/game_engine.dart';
import 'models/enums.dart';
import 'screens/countdown_screen.dart';
import 'screens/discussion_screen.dart';
import 'screens/final_guess_screen.dart';
import 'screens/game_over_screen.dart';
import 'screens/home_screen.dart';
import 'screens/how_to_play_screen.dart';
import 'screens/player_setup_screen.dart';
import 'screens/role_reveal_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/vote_result_screen.dart';
import 'screens/voting_screen.dart';
import 'theme/app_theme.dart';

/// Root app widget. Provides GameEngine via Provider and routes by game phase.
class WhoKnowsApp extends StatelessWidget {
  const WhoKnowsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Who Knows!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const _GameRouter(),
    );
  }
}

/// Routes to the correct screen based on the current game phase.
class _GameRouter extends StatelessWidget {
  const _GameRouter();

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final phase = engine.state.phase;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _screenForPhase(context, engine, phase),
    );
  }

  Widget _screenForPhase(
    BuildContext context,
    GameEngine engine,
    GamePhase phase,
  ) {
    switch (phase) {
      case GamePhase.lobby:
        return HomeScreen(
          key: const ValueKey('home'),
          onPlay: () => engine.startNewGame(),
          onHowToPlay: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
          ),
          onSettings: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: engine,
                child: const SettingsScreen(),
              ),
            ),
          ),
        );
      case GamePhase.playerSetup:
        return const PlayerSetupScreen(key: ValueKey('setup'));
      case GamePhase.roleReveal:
        return const RoleRevealScreen(key: ValueKey('reveal'));
      case GamePhase.countdown:
        return const CountdownScreen(key: ValueKey('countdown'));
      case GamePhase.discussion:
        return const DiscussionScreen(key: ValueKey('discussion'));
      case GamePhase.voting:
        return const VotingScreen(key: ValueKey('voting'));
      case GamePhase.voteResult:
        return const VoteResultScreen(key: ValueKey('voteResult'));
      case GamePhase.finalGuess:
        return const FinalGuessScreen(key: ValueKey('finalGuess'));
      case GamePhase.gameOver:
        return const GameOverScreen(key: ValueKey('gameOver'));
    }
  }
}
