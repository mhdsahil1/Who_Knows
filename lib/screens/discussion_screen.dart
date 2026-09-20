import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/leave_game_dialog.dart';
import '../widgets/observer_graphic.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';

/// Screen 7 — Discussion: Facilitates physical verbal discussion around the table.
class DiscussionScreen extends StatelessWidget {
  const DiscussionScreen({super.key});

  Future<void> _onLeave(BuildContext context, GameEngine engine) async {
    final confirmed = await LeaveGameDialog.show(context);
    if (confirmed && context.mounted) {
      engine.leaveGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final activeCount = engine.state.activePlayers.length;
    final roundNumber = engine.state.roundNumber;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onLeave(context, engine);
      },
      child: ResponsiveScaffold(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ROUND ${roundNumber.toString().padLeft(2, '0')} • $activeCount ACTIVE PLAYERS',
                      style: WKTypography.label.copyWith(
                        color: WKColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onLeave(context, engine),
                      child: const Icon(
                        Icons.close_rounded,
                        color: WKColors.textMuted,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 1),

                // Observer motif watching the discussion
                const ObserverGraphic(
                  size: 90,
                  color: WKColors.yellow,
                  animate: true,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'DISCUSS',
                  style: WKTypography.displayLarge.copyWith(
                    fontSize: 48,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Someone here doesn\'t know.',
                  style: WKTypography.bodyLarge.copyWith(
                    color: WKColors.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Physical guidance card
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
                      _guidanceItem(
                        icon: Icons.record_voice_over_rounded,
                        text: 'Give your clue aloud. Never type it into the phone.',
                        highlight: true,
                      ),
                      const SizedBox(height: 14),
                      _guidanceItem(
                        icon: Icons.phone_android_rounded,
                        text: 'Put the phone down on the table while you talk.',
                      ),
                      const SizedBox(height: 14),
                      _guidanceItem(
                        icon: Icons.groups_rounded,
                        text: 'Figure out who is bluffing and agree on ONE suspect.',
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),

                Text(
                  'Once your group has agreed on who to accuse:',
                  style: WKTypography.bodySmall.copyWith(
                    color: WKColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // VOTE button (solid red)
                DangerButton(
                  text: 'VOTE',
                  icon: Icons.gavel_rounded,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    engine.startVoting();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _guidanceItem({
    required IconData icon,
    required String text,
    bool highlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: highlight ? WKColors.yellow : WKColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: WKTypography.bodyMedium.copyWith(
              color: highlight ? WKColors.offWhite : WKColors.textSecondary,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
