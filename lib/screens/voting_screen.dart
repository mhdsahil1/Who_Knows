import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/vote_player_tile.dart';

/// Screen 8 — Group Vote:
/// Only ONE player is chosen representing the group's collective decision.
class VotingScreen extends StatelessWidget {
  const VotingScreen({super.key});

  void _onConfirmVote(BuildContext context, GameEngine engine) async {
    final selectedPlayer = engine.state.selectedAccusedPlayer;
    if (selectedPlayer == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: WKColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: WKColors.blackMedium),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: WKColors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.gavel_rounded,
                color: WKColors.red,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'ACCUSE',
              style: WKTypography.label.copyWith(
                color: WKColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              selectedPlayer.name.toUpperCase(),
              style: WKTypography.headingLarge.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure? This will eliminate them and reveal their role.',
              style: WKTypography.bodyMedium.copyWith(
                color: WKColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'CONFIRM ELIMINATION',
              color: WKColors.red,
              textColor: WKColors.offWhite,
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              text: 'GO BACK',
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      HapticFeedback.heavyImpact();
      engine.confirmGroupVote();
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final activePlayers = engine.state.activePlayers;
    final selectedId = engine.state.selectedAccusedPlayerId;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) engine.startDiscussion();
      },
      child: ResponsiveScaffold(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => engine.startDiscussion(),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: WKColors.textMuted,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'GROUP ACCUSATION',
                      style: WKTypography.label.copyWith(
                        color: WKColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 24),
                  ],
                ),
                const SizedBox(height: 28),

                // Title
                Text(
                  "WHO'S THE\nIMPOSTER?",
                  style: WKTypography.displayMedium.copyWith(
                    height: 0.95,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the player your group agreed on.',
                  style: WKTypography.bodyMedium.copyWith(
                    color: WKColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Active Players List
                Expanded(
                  child: ListView.builder(
                    itemCount: activePlayers.length,
                    itemBuilder: (context, index) {
                      final player = activePlayers[index];
                      final isSelected = selectedId == player.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: VotePlayerTile(
                          name: player.name,
                          number: index + 1,
                          isSelected: isSelected,
                          onTap: () {
                            engine.selectAccusedPlayer(player.id);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // CTA: Confirm Vote
                PrimaryButton(
                  text: 'CONFIRM',
                  color: selectedId != null ? WKColors.red : null,
                  textColor: selectedId != null ? WKColors.offWhite : null,
                  onPressed: selectedId != null
                      ? () => _onConfirmVote(context, engine)
                      : null,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
