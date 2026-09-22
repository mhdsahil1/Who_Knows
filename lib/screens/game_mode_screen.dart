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
import 'game_config_screen.dart';

/// Setup Step 2/5 — HOW DO YOU WANT TO PLAY?
/// Allows selecting between Classic Mode and One-Shot Vote.
class GameModeScreen extends StatelessWidget {
  const GameModeScreen({super.key});

  Future<void> _onLeave(BuildContext context, GameEngine engine) async {
    final confirmed = await LeaveGameDialog.show(context);
    if (confirmed && context.mounted) {
      engine.leaveGame();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final selectedMode = engine.state.settings.gameMode;

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
                    const SetupProgress(step: 2, total: 5),
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
                        'HOW DO YOU\nWANT TO PLAY?',
                        style: WKTypography.displayMedium.copyWith(
                          height: 0.95,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose how the vote will work.',
                        style: WKTypography.bodyMedium.copyWith(
                          color: WKColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Mode Cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildModeCard(
                      title: 'CLASSIC MODE',
                      subtitle: 'Keep voting until the Imposter is caught.',
                      icon: Icons.replay_rounded,
                      isSelected: selectedMode == GameMode.classic,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        engine.setGameMode(GameMode.classic);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildModeCard(
                      title: 'ONE-SHOT VOTE',
                      subtitle: 'One discussion. One vote. One chance.',
                      icon: Icons.adjust_rounded,
                      isSelected: selectedMode == GameMode.oneShotVote,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        engine.setGameMode(GameMode.oneShotVote);
                      },
                    ),
                  ],
                ),
              ),

              // NEXT CTA
              Padding(
                padding: const EdgeInsets.all(24),
                child: PrimaryButton(
                  text: 'NEXT',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: engine,
                          child: const GameConfigScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? WKColors.surfaceElevated
              : WKColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? WKColors.yellow : WKColors.blackMedium,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? WKColors.yellow.withValues(alpha: 0.15)
                    : WKColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? WKColors.yellow
                      : WKColors.blackMedium,
                ),
              ),
              child: Icon(
                icon,
                color: isSelected ? WKColors.yellow : WKColors.textMuted,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: WKTypography.headingSmall.copyWith(
                      color: isSelected ? WKColors.offWhite : WKColors.textSecondary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: WKTypography.bodyMedium.copyWith(
                      color: isSelected
                          ? WKColors.textPrimary
                          : WKColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? WKColors.yellow : WKColors.textMuted,
                  width: 2,
                ),
                color: isSelected ? WKColors.yellow : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: WKColors.black,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
