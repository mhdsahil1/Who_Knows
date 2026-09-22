import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../models/enums.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';

/// Screen 11 — Final Guess: Caught Imposter's dramatic last chance to steal victory.
class FinalGuessScreen extends StatefulWidget {
  const FinalGuessScreen({super.key});

  @override
  State<FinalGuessScreen> createState() => _FinalGuessScreenState();
}

class _FinalGuessScreenState extends State<FinalGuessScreen> {
  final _guessController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  void _submitGuess(GameEngine engine) {
    final guess = _guessController.text.trim();
    if (guess.isEmpty) {
      setState(() => _errorText = 'Please enter your guess');
      return;
    }
    HapticFeedback.heavyImpact();
    engine.submitFinalGuess(guess);
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final caughtImposter = engine.state.caughtImposter;

    if (caughtImposter == null) {
      return const SizedBox.shrink();
    }

    final isOneShot = engine.state.settings.gameMode == GameMode.oneShotVote;
    final caughtImposters = isOneShot && engine.state.selectedAccusedPlayers.length > 1
        ? engine.state.selectedAccusedPlayers
        : [caughtImposter];
    final isMulti = caughtImposters.length > 1;

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
                  'FINAL GUESS',
                  style: WKTypography.label.copyWith(
                    letterSpacing: 3,
                    color: WKColors.red,
                  ),
                ),
                const Spacer(flex: 1),

                Text(
                  caughtImposters.map((p) => p.name.toUpperCase()).join(' & '),
                  style: WKTypography.displayLarge.copyWith(
                    fontSize: isMulti ? 32 : 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  isMulti
                      ? 'You were caught. But you can still steal the win together.'
                      : 'You were caught. But you can still steal the win.',
                  style: WKTypography.bodyMedium.copyWith(
                    color: WKColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                if (caughtImposter.categoryHint != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: WKColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: WKColors.blackMedium),
                    ),
                    child: Text(
                      'CATEGORY: ${caughtImposter.categoryHint!.toUpperCase()}',
                      style: WKTypography.label.copyWith(
                        color: WKColors.yellow,
                        letterSpacing: 2,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                Text(
                  'WHAT WAS THE SECRET WORD?',
                  style: WKTypography.label.copyWith(
                    color: WKColors.textMuted,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _guessController,
                  textCapitalization: TextCapitalization.words,
                  textAlign: TextAlign.center,
                  style: WKTypography.headingMedium.copyWith(
                    color: WKColors.offWhite,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type secret word...',
                    hintStyle: WKTypography.bodyLarge.copyWith(
                      color: WKColors.textMuted,
                    ),
                    errorText: _errorText,
                    filled: true,
                    fillColor: WKColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: WKColors.blackMedium),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: WKColors.blackMedium),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: WKColors.red, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  onSubmitted: (_) => _submitGuess(engine),
                ),
                const Spacer(flex: 2),

                DangerButton(
                  text: 'SUBMIT GUESS',
                  icon: Icons.send_rounded,
                  onPressed: () => _submitGuess(engine),
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
