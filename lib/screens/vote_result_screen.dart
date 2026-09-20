import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';

/// Screen 10 — Elimination Result: High-stakes dramatic role reveal of the eliminated player.
class VoteResultScreen extends StatefulWidget {
  const VoteResultScreen({super.key});

  @override
  State<VoteResultScreen> createState() => _VoteResultScreenState();
}

class _VoteResultScreenState extends State<VoteResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final eliminated = engine.getLastEliminatedPlayer();

    if (eliminated == null) {
      return const SizedBox.shrink();
    }

    final isImposter = eliminated.isImposter;
    final accentColor = isImposter ? WKColors.red : WKColors.green;

    return PopScope(
      canPop: false,
      child: ResponsiveScaffold(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'ELIMINATION REVEAL',
                  style: WKTypography.label.copyWith(
                    letterSpacing: 3,
                    color: WKColors.textMuted,
                  ),
                ),
                const Spacer(flex: 1),

                // Eliminated player name
                Text(
                  eliminated.name.toUpperCase(),
                  style: WKTypography.displayLarge.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  'WAS THE...',
                  style: WKTypography.label.copyWith(
                    color: WKColors.textSecondary,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 20),

                // Dramatic Role Reveal with Scale & Fade
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        isImposter ? 'IMPOSTER! 😈' : 'CIVILIAN! 😇',
                        style: WKTypography.displayMedium.copyWith(
                          color: isImposter ? WKColors.offWhite : WKColors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Reaction Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: WKColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: WKColors.blackMedium),
                  ),
                  child: Text(
                    isImposter
                        ? (engine.state.finalGuessEnabled
                            ? "The group caught the Imposter!\nOne last chance for them to guess the secret word..."
                            : "The group caught the Imposter!\nFinal Guess is OFF: Civilians win!")
                        : "Oops! You eliminated an innocent civilian.\nThe real Imposter is still among you!",
                    style: WKTypography.bodyMedium.copyWith(
                      color: WKColors.offWhite,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(flex: 2),

                // Primary CTA
                PrimaryButton(
                  text: isImposter
                      ? (engine.state.finalGuessEnabled
                          ? 'FINAL GUESS'
                          : 'VIEW RESULTS')
                      : 'CONTINUE DISCUSSION',
                  color: isImposter ? WKColors.red : WKColors.green,
                  textColor: isImposter ? WKColors.offWhite : WKColors.black,
                  icon: isImposter
                      ? (engine.state.finalGuessEnabled
                          ? Icons.psychology_rounded
                          : Icons.emoji_events_rounded)
                      : Icons.forum_rounded,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    engine.proceedFromVoteResult();
                  },
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
