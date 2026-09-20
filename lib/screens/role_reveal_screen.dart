import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../models/enums.dart';
import '../models/player.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/countdown_dial.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/reveal_gesture.dart';

/// Screen 6 — Role Reveal: Pass-and-play secret role distribution
/// using a physical slide-up gesture.
class RoleRevealScreen extends StatefulWidget {
  const RoleRevealScreen({super.key});

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  bool _isRevealed = false;
  bool _showCountdown = false;
  int _currentRevealedPlayerIndex = -1;

  void _onRevealed() {
    setState(() => _isRevealed = true);
  }

  void _hideAndPass(GameEngine engine, bool isLastPlayer) {
    HapticFeedback.lightImpact();
    setState(() => _isRevealed = false);
    if (isLastPlayer) {
      setState(() => _showCountdown = true);
    } else {
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted) {
          engine.nextReveal();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();

    if (_showCountdown) {
      return PopScope(
        canPop: false,
        child: ResponsiveScaffold(
          child: CountdownDial(
            onComplete: () {
              engine.nextReveal();
            },
          ),
        ),
      );
    }

    final player = engine.state.currentRevealPlayer;

    if (player == null) {
      return const SizedBox.shrink();
    }

    final totalPlayers = engine.state.activePlayers.length;
    final currentIndex = engine.state.currentRevealIndex;
    final currentNumber = currentIndex + 1;
    final isLastPlayer = currentNumber >= totalPlayers;
    final playerAccent = WKColors.playerAccent(currentIndex);

    // If player index changed, ensure reveal state is reset
    if (_currentRevealedPlayerIndex != currentIndex) {
      _currentRevealedPlayerIndex = currentIndex;
      _isRevealed = false;
    }

    return PopScope(
      canPop: false, // Prevent accidental back during secret reveal
      child: ResponsiveScaffold(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Top progress row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PLAYER ${currentNumber.toString().padLeft(2, '0')} / ${totalPlayers.toString().padLeft(2, '0')}',
                      style: WKTypography.label.copyWith(
                        color: WKColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: playerAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: playerAccent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'PASS & PLAY',
                        style: WKTypography.label.copyWith(
                          fontSize: 10,
                          color: playerAccent,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: currentNumber / totalPlayers,
                    minHeight: 4,
                    backgroundColor: WKColors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(playerAccent),
                  ),
                ),
                const Spacer(flex: 1),

                // Player name & prompt
                Text(
                  'HAND PHONE TO',
                  style: WKTypography.label.copyWith(
                    color: WKColors.textSecondary,
                    letterSpacing: 3,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  player.name.toUpperCase(),
                  style: WKTypography.displayMedium.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: WKColors.offWhite,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _isRevealed ? 'Keep your screen hidden.' : 'Only this player should look.',
                  style: WKTypography.bodySmall.copyWith(
                    color: WKColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 1),

                // Interactive gesture reveal card
                KeyedSubtree(
                  key: ValueKey('reveal_$currentIndex'),
                  child: RevealGesture(
                    accentColor: playerAccent,
                    onRevealed: _onRevealed,
                    hiddenContent: _buildRoleContent(player),
                  ),
                ),
                const Spacer(flex: 2),

                // Action button: HIDE & PASS / START DISCUSSION
                if (_isRevealed) ...[
                  PrimaryButton(
                    text: isLastPlayer ? 'START DISCUSSION' : 'HIDE & PASS',
                    color: isLastPlayer ? WKColors.yellow : WKColors.offWhite,
                    textColor: WKColors.black,
                    icon: isLastPlayer ? Icons.forum_rounded : Icons.arrow_forward_rounded,
                    onPressed: () => _hideAndPass(engine, isLastPlayer),
                  ),
                ] else ...[
                  Text(
                    'Swipe up or tap to reveal your role',
                    style: WKTypography.bodySmall.copyWith(
                      color: WKColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleContent(Player player) {
    final isImposter = player.role == PlayerRole.imposter;
    final accentColor = isImposter ? WKColors.red : WKColors.green;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor, width: 1.5),
          ),
          child: Text(
            isImposter ? 'IMPOSTER' : 'CIVILIAN',
            style: WKTypography.headingSmall.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (isImposter) ...[
          // Imposter content
          Text(
            "YOU DON'T\nKNOW THE WORD",
            style: WKTypography.headingLarge.copyWith(
              color: WKColors.offWhite,
              height: 1.1,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (player.categoryHint != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: WKColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'CATEGORY: ${player.categoryHint!.toUpperCase()}',
                style: WKTypography.label.copyWith(
                  color: WKColors.yellow,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Blend in. Listen carefully. Do not get caught.',
            style: WKTypography.bodyMedium.copyWith(
              color: WKColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ] else ...[
          // Civilian content
          Text(
            'YOUR SECRET WORD',
            style: WKTypography.label.copyWith(
              color: WKColors.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            (player.secretWord ?? '???').toUpperCase(),
            style: WKTypography.displayLarge.copyWith(
              color: WKColors.green,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            'Give subtle clues. Spot whoever is bluffing.',
            style: WKTypography.bodyMedium.copyWith(
              color: WKColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
