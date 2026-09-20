import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../models/enums.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';

/// Screen 12 & 13 — Final Result & Game Over: Celebration, secret word recap, and player roles.
class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final winner = engine.state.winner;
    final word = engine.state.currentWord;
    final finalGuess = engine.state.finalGuessText;
    final isCivilianWin = winner == Winner.civilians;
    final winColor = isCivilianWin ? WKColors.green : WKColors.red;

    return PopScope(
      canPop: false,
      child: ResponsiveScaffold(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'GAME OVER',
                  style: WKTypography.label.copyWith(
                    letterSpacing: 3,
                    color: WKColors.textMuted,
                  ),
                ),
                const SizedBox(height: 28),

                // Victory title
                Text(
                  isCivilianWin ? 'CIVILIANS\nWIN! 🎉' : 'IMPOSTER\nWINS! 😈',
                  style: WKTypography.displayLarge.copyWith(
                    color: winColor,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isCivilianWin
                      ? 'The Imposter was exposed and failed the final guess!'
                      : (finalGuess != null
                          ? 'Caught... but successfully guessed the secret word!'
                          : 'The Imposter deceived the whole table!'),
                  style: WKTypography.bodyMedium.copyWith(
                    color: WKColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Secret Word Reveal Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: WKColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: WKColors.blackMedium),
                  ),
                  child: Column(
                    children: [
                      Text(
                        engine.state.wordDistribution == WordDistribution.unique
                            ? 'CHAOS WORDS (ALL DIFFERENT)'
                            : 'THE SECRET WORD WAS',
                        style: WKTypography.label.copyWith(
                          color: WKColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        engine.state.wordDistribution == WordDistribution.unique
                            ? 'CHAOS WORDS'
                            : (word?.word.toUpperCase() ?? '???'),
                        style: WKTypography.displayMedium.copyWith(
                          color: WKColors.yellow,
                          fontSize: engine.state.wordDistribution == WordDistribution.unique ? 24 : 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (word != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Category: ${word.category}',
                          style: WKTypography.bodySmall.copyWith(
                            color: WKColors.textSecondary,
                          ),
                        ),
                      ],
                      if (finalGuess != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(color: WKColors.blackMedium, height: 1),
                        ),
                        Text(
                          'IMPOSTER GUESSED',
                          style: WKTypography.label.copyWith(
                            color: WKColors.textMuted,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          finalGuess.toUpperCase(),
                          style: WKTypography.headingSmall.copyWith(
                            color: isCivilianWin ? WKColors.red : WKColors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Player Roles Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: WKColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: WKColors.blackMedium),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLAYER ROLES',
                        style: WKTypography.label.copyWith(
                          color: WKColors.textMuted,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...engine.state.players.map((player) {
                        final isImp = player.isImposter;
                        final roleColor = isImp ? WKColors.red : WKColors.green;
                        final isUnique = engine.state.wordDistribution == WordDistribution.unique;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: roleColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.name,
                                      style: WKTypography.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: player.isEliminated
                                            ? WKColors.textMuted
                                            : WKColors.textPrimary,
                                        decoration: player.isEliminated
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    if (isUnique && player.secretWord != null)
                                      Text(
                                        'Word: ${player.secretWord}',
                                        style: WKTypography.bodySmall.copyWith(
                                          color: WKColors.yellow,
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: roleColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: roleColor.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  isImp
                                      ? 'IMPOSTER'
                                      : (player.isEliminated
                                          ? 'CIVILIAN (OUT)'
                                          : 'CIVILIAN'),
                                  style: WKTypography.label.copyWith(
                                    fontSize: 10,
                                    color: roleColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Play Again Button
                PrimaryButton(
                  text: 'PLAY AGAIN',
                  icon: Icons.replay_rounded,
                  onPressed: () => engine.playAgain(),
                ),
                const SizedBox(height: 12),

                // Home Button
                SecondaryButton(
                  text: 'HOME',
                  icon: Icons.home_rounded,
                  onPressed: () => engine.returnToLobby(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
