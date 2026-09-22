import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../models/enums.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/leave_game_dialog.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/setup_progress.dart';

/// Setup Step 4/4 — READY?
/// Final summary of game configuration before starting the game.
class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key});

  Future<void> _onLeave(BuildContext context, GameEngine engine) async {
    final confirmed = await LeaveGameDialog.show(context);
    if (confirmed && context.mounted) {
      engine.leaveGame();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _startGame(BuildContext context, GameEngine engine) {
    HapticFeedback.heavyImpact();
    final error = engine.startGame();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: WKColors.red,
        ),
      );
    } else {
      // Pop all setup routes back to the root router, which will display roleReveal phase
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final settings = engine.state.settings;
    final players = engine.state.players;
    final isChaos = settings.imposterMode == ImposterMode.chaos;

    String imposterSummary;
    if (isChaos) {
      imposterSummary = 'CHAOS MODE (??? Imposters)';
    } else if (settings.imposterMode == ImposterMode.custom) {
      imposterSummary = '${settings.customImposterCount} Imposters';
    } else {
      imposterSummary = '${settings.imposterCount} Imposter${settings.imposterCount > 1 ? 's' : ''}';
    }

    return PopScope(
      canPop: true,
      child: ResponsiveScaffold(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: WKColors.textMuted,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    const SetupProgress(step: 5, total: 5),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _onLeave(context, engine),
                      child: const Icon(
                        Icons.close_rounded,
                        color: WKColors.textMuted,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'READY?',
                        style: WKTypography.displayLarge.copyWith(
                          fontSize: 48,
                          height: 0.95,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pass the phone. Keep it secret.',
                        style: WKTypography.bodyMedium.copyWith(
                          color: WKColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Configuration summary cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildSummaryCard(
                      label: 'GAME MODE',
                      value: settings.gameMode == GameMode.oneShotVote
                          ? 'ONE-SHOT VOTE'
                          : 'CLASSIC MODE',
                      detail: settings.gameMode == GameMode.oneShotVote
                          ? 'One discussion. One vote. One chance.'
                          : 'Keep voting until the Imposter is caught.',
                      accentColor: settings.gameMode == GameMode.oneShotVote
                          ? WKColors.red
                          : WKColors.yellow,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      label: 'PLAYERS',
                      value: '${players.length}',
                      detail: players.map((p) => p.name).join(', '),
                      accentColor: WKColors.yellow,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      label: 'IMPOSTERS',
                      value: imposterSummary,
                      detail: isChaos
                          ? 'Zero, one, or all players could be imposters!'
                          : null,
                      accentColor: isChaos ? WKColors.red : WKColors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      label: 'CATEGORIES',
                      value: '${settings.selectedCategories.length} Categories',
                      detail: settings.selectedCategories.join(', '),
                      accentColor: WKColors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      label: 'FINAL GUESS',
                      value: settings.finalGuessEnabled ? 'ON' : 'OFF',
                      accentColor: settings.finalGuessEnabled
                          ? WKColors.green
                          : WKColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      label: 'MY WORDS',
                      value: settings.myWordsEnabled ? 'ON' : 'OFF',
                      detail: settings.myWordsEnabled
                          ? '${engine.myWordsService.count} custom words'
                          : null,
                      accentColor: settings.myWordsEnabled
                          ? WKColors.yellow
                          : WKColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      label: 'ASSOCIATED WORDS',
                      value: settings.associatedWordsEnabled ? 'ON' : 'OFF',
                      detail: settings.associatedWordsEnabled
                          ? '${engine.associatedWordsService.totalCount} generic words'
                          : null,
                      accentColor: settings.associatedWordsEnabled
                          ? WKColors.yellow
                          : WKColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCard(
                      label: 'IMPOSTER START',
                      value: settings.canImposterStart ? 'YES' : 'NO',
                      detail: settings.canImposterStart
                          ? 'Imposter can be selected as starting player'
                          : 'Civilians only give the first clue',
                      accentColor: WKColors.offWhite,
                    ),
                    if (isChaos ||
                        settings.imposterCount >= 2 ||
                        (settings.imposterMode == ImposterMode.custom &&
                            settings.customImposterCount >= 2)) ...[
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        label: 'IMPOSTER TEAMWORK',
                        value: settings.impostersKnowEachOther ? 'YES' : 'NO',
                        detail: settings.impostersKnowEachOther
                            ? 'Imposters see teammate names during role reveal'
                            : 'Imposters do not know other imposters',
                        accentColor: settings.impostersKnowEachOther
                            ? WKColors.red
                            : WKColors.textMuted,
                      ),
                    ],
                  ],
                ),
              ),

              // START GAME button
              Padding(
                padding: const EdgeInsets.all(24),
                child: PrimaryButton(
                  text: 'START GAME',
                  onPressed: () => _startGame(context, engine),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    String? detail,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: WKColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WKColors.blackMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: WKTypography.label.copyWith(
                  color: WKColors.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: WKTypography.headingMedium.copyWith(
              color: WKColors.offWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(
              detail,
              style: WKTypography.bodySmall.copyWith(
                color: WKColors.textSecondary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
