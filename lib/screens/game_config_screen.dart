import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../models/enums.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/info_button.dart';
import '../widgets/leave_game_dialog.dart';
import '../widgets/option_tile.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/setup_progress.dart';
import '../widgets/toggle_option.dart';
import 'category_selection_screen.dart';

/// Setup Step 3/5 — WHO DOESN'T KNOW?
/// Configures imposter count, chaos mode, chaos words, and final guess rule.
class GameConfigScreen extends StatefulWidget {
  const GameConfigScreen({super.key});

  @override
  State<GameConfigScreen> createState() => _GameConfigScreenState();
}

class _GameConfigScreenState extends State<GameConfigScreen> {
  Future<void> _onLeave(GameEngine engine) async {
    final confirmed = await LeaveGameDialog.show(context);
    if (confirmed && mounted) {
      engine.leaveGame();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final settings = engine.state.settings;
    final playerCount = engine.state.players.length;
    final isChaos = settings.imposterMode == ImposterMode.chaos;
    final isCustom = settings.imposterMode == ImposterMode.custom && !isChaos;
    final isFixed1 = settings.imposterMode == ImposterMode.fixed &&
        settings.imposterCount == 1 &&
        !isChaos;
    final isFixed2 = settings.imposterMode == ImposterMode.fixed &&
        settings.imposterCount == 2 &&
        !isChaos;

    final maxImposters = (playerCount - 1).clamp(1, playerCount);

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
                    const SetupProgress(step: 3, total: 5),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _onLeave(engine),
                      child: const Icon(
                        Icons.close_rounded,
                        color: WKColors.textMuted,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Title
                    Text(
                      "WHO DOESN'T\nKNOW?",
                      style: WKTypography.displayMedium.copyWith(
                        height: 0.95,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set the stakes and game rules.',
                      style: WKTypography.bodyMedium.copyWith(
                        color: WKColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Section: Imposters
                    Row(
                      children: [
                        Text(
                          'IMPOSTER COUNT',
                          style: WKTypography.label.copyWith(
                            color: WKColors.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const InfoButton(
                          title: 'IMPOSTER COUNT',
                          explanation:
                              'Imposters do not know the secret word. In a standard party group, 1 Imposter creates high tension, while 2 Imposters add chaotic deception.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 1 Imposter option
                    OptionTile(
                      title: '1 IMPOSTER',
                      subtitle: 'Recommended for 3-6 players',
                      badge: 'RECOMMENDED',
                      isSelected: isFixed1,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        engine.setImposterMode(ImposterMode.fixed);
                        engine.setImposterCount(1);
                      },
                    ),
                    const SizedBox(height: 10),

                    // 2 Imposters option
                    OptionTile(
                      title: '2 IMPOSTERS',
                      subtitle: 'Recommended for 7+ players',
                      isSelected: isFixed2,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        engine.setImposterMode(ImposterMode.fixed);
                        engine.setImposterCount(2);
                      },
                    ),
                    const SizedBox(height: 10),

                    // Custom count option
                    OptionTile(
                      title: 'CUSTOM COUNT',
                      subtitle: '${settings.customImposterCount} of $playerCount players',
                      isSelected: isCustom,
                      trailing: isCustom
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline_rounded),
                                  color: WKColors.yellow,
                                  onPressed: settings.customImposterCount > 1
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          engine.setCustomImposterCount(
                                              settings.customImposterCount - 1);
                                        }
                                      : null,
                                ),
                                Text(
                                  '${settings.customImposterCount}',
                                  style: WKTypography.number.copyWith(
                                    fontSize: 18,
                                    color: WKColors.offWhite,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline_rounded),
                                  color: WKColors.yellow,
                                  onPressed: settings.customImposterCount < maxImposters
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          engine.setCustomImposterCount(
                                              settings.customImposterCount + 1);
                                        }
                                      : null,
                                ),
                              ],
                            )
                          : null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        engine.setImposterMode(ImposterMode.custom);
                      },
                    ),
                    const SizedBox(height: 10),

                    // Chaos Mode option
                    OptionTile(
                      title: 'CHAOS MODE',
                      subtitle: 'Unknown number of imposters (0 to all!)',
                      badge: 'CHAOS',
                      badgeColor: WKColors.yellow,
                      badgeTextColor: WKColors.black,
                      isSelected: isChaos,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        engine.setImposterMode(ImposterMode.chaos);
                      },
                    ),
                    const SizedBox(height: 28),

                    // Section: Chaos Words (only visible if Chaos Mode is selected)
                    if (isChaos) ...[
                      Row(
                        children: [
                          Text(
                            'CHAOS WORDS',
                            style: WKTypography.label.copyWith(
                              color: WKColors.yellow,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const InfoButton(
                            title: 'CHAOS WORDS',
                            explanation:
                                'SHARED: All civilians get the exact same secret word.\n\nEVERYONE DIFFERENT: Each player gets a completely different secret word from the category!',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ToggleOption(
                        label: 'EVERYONE DIFFERENT',
                        subtitle: settings.wordDistribution == WordDistribution.unique
                            ? 'Each player has a different secret word'
                            : 'All civilians share one secret word',
                        value: settings.wordDistribution == WordDistribution.unique,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          engine.setWordDistribution(
                            val ? WordDistribution.unique : WordDistribution.shared,
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Section: Rules
                    Row(
                      children: [
                        Text(
                          'GAME RULES',
                          style: WKTypography.label.copyWith(
                            color: WKColors.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const InfoButton(
                          title: 'GAME RULES',
                          explanation:
                              'Configure clue-giving, teamwork, and win condition rules.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ToggleOption(
                      label: 'FINAL GUESS',
                      subtitle: 'Caught Imposter can guess word to steal win',
                      value: settings.finalGuessEnabled,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        engine.setFinalGuessEnabled(val);
                      },
                    ),
                    const SizedBox(height: 12),
                    ToggleOption(
                      label: 'IMPOSTER START',
                      subtitle: 'Can the Imposter give the first clue?',
                      value: settings.canImposterStart,
                      trueText: 'YES',
                      falseText: 'NO',
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        engine.setCanImposterStart(val);
                      },
                    ),
                    if (isChaos ||
                        isFixed2 ||
                        (isCustom && settings.customImposterCount >= 2)) ...[
                      const SizedBox(height: 12),
                      ToggleOption(
                        label: 'IMPOSTERS KNOW EACH OTHER?',
                        subtitle:
                            'Imposters see teammate names during role reveal',
                        value: settings.impostersKnowEachOther,
                        trueText: 'YES',
                        falseText: 'NO',
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          engine.setImpostersKnowEachOther(val);
                        },
                      ),
                    ],
                    const SizedBox(height: 32),
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
                          child: const CategorySelectionScreen(),
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
}
