import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../models/enums.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/vote_player_tile.dart';

/// Screen 8 — Group Vote:
/// Only ONE player is chosen representing the group's collective decision.
/// Adapts UI and confirmation for Classic Mode vs One-Shot Vote.
class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  bool _isSubmitting = false;

  void _onConfirmVote(BuildContext context, GameEngine engine) async {
    final selectedPlayers = engine.state.selectedAccusedPlayers;
    if (selectedPlayers.isEmpty) return;
    if (_isSubmitting || engine.state.oneShotVoteCompleted) return;

    final isOneShot = engine.state.settings.gameMode == GameMode.oneShotVote;
    final isMulti = selectedPlayers.length > 1;
    final namesText = selectedPlayers.map((p) => p.name.toUpperCase()).join(' & ');

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
              isOneShot ? 'FINAL VOTE' : 'ACCUSE',
              style: WKTypography.label.copyWith(
                color: WKColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              namesText,
              style: WKTypography.headingLarge.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isOneShot
                  ? (isMulti
                      ? 'Everyone agrees? You must catch ALL ${selectedPlayers.length} Imposters to win.'
                      : 'Everyone agrees? This is your only vote.')
                  : 'Are you sure? This will eliminate them and reveal their role.',
              style: WKTypography.bodyMedium.copyWith(
                color: WKColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: isOneShot ? 'CONFIRM VOTE' : 'CONFIRM ELIMINATION',
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

    if (confirmed == true && mounted) {
      if (_isSubmitting || engine.state.oneShotVoteCompleted) return;
      setState(() => _isSubmitting = true);

      HapticFeedback.heavyImpact();
      if (isOneShot) {
        engine.resolveOneShotVote(selectedPlayers.map((p) => p.id).toList());
      } else {
        engine.confirmGroupVote();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final activePlayers = engine.state.activePlayers;
    final selectedIds = engine.state.selectedAccusedPlayerIds;
    final isOneShot = engine.state.settings.gameMode == GameMode.oneShotVote;
    final isChaos = engine.state.settings.imposterMode == ImposterMode.chaos;
    final totalImposters = isChaos
        ? engine.state.activeImposters.length
        : engine.state.settings.imposterCount;
    final requiredCount = totalImposters < 1 ? 1 : totalImposters;
    final isMultiImposter = isOneShot && requiredCount >= 2;
    final isLocked = _isSubmitting || engine.state.oneShotVoteCompleted;

    final isSelectionReady = isMultiImposter
        ? selectedIds.length == requiredCount
        : selectedIds.isNotEmpty;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !isLocked) engine.startDiscussion();
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
                      onTap: isLocked ? null : () => engine.startDiscussion(),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isLocked ? Colors.transparent : WKColors.textMuted,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      isOneShot ? 'ONE SHOT' : 'VOTE',
                      style: WKTypography.label.copyWith(
                        color: isOneShot ? WKColors.red : WKColors.textMuted,
                        letterSpacing: 2,
                        fontWeight: isOneShot ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 24),
                  ],
                ),
                const SizedBox(height: 28),

                // Title
                Text(
                  isMultiImposter ? "WHO ARE THE\nIMPOSTERS?" : "WHO'S THE\nIMPOSTER?",
                  style: WKTypography.displayMedium.copyWith(
                    height: 0.95,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isOneShot
                      ? (isMultiImposter
                          ? "Select all $requiredCount imposters (${selectedIds.length}/$requiredCount selected).\nIf even one choice is wrong, Imposters win!"
                          : "This is your only vote. Choose the imposter.")
                      : "Choose the player your group agreed on.",
                  style: WKTypography.bodyMedium.copyWith(
                    color: isOneShot ? WKColors.offWhite : WKColors.textSecondary,
                    fontWeight: isOneShot ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),

                // Active Players List
                Expanded(
                  child: ListView.builder(
                    itemCount: activePlayers.length,
                    itemBuilder: (context, index) {
                      final player = activePlayers[index];
                      final isSelected = selectedIds.contains(player.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: VotePlayerTile(
                          name: player.name,
                          number: index + 1,
                          isSelected: isSelected,
                          onTap: () {
                            if (isLocked) return;
                            if (isMultiImposter) {
                              engine.toggleAccusedPlayer(
                                player.id,
                                maxSelectable: requiredCount,
                              );
                            } else {
                              engine.selectAccusedPlayer(player.id);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // CTA: Confirm Vote
                PrimaryButton(
                  text: isOneShot
                      ? (isMultiImposter ? 'CONFIRM VOTE ($requiredCount)' : 'CONFIRM VOTE')
                      : 'CONFIRM',
                  color: isSelectionReady ? WKColors.red : null,
                  textColor: isSelectionReady ? WKColors.offWhite : null,
                  onPressed: (isSelectionReady && !isLocked)
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
