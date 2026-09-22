import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/game_constants.dart';
import '../data/word_database.dart';
import '../game/game_engine.dart';
import '../models/game_settings.dart';
import '../services/storage_service.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/toggle_option.dart';
import 'associated_words_screen.dart';
import 'my_words_screen.dart';

/// Settings screen for audio, haptics, and game info.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storageService = StorageService();

  void _updateSettings(GameEngine engine, GameSettings newSettings) {
    engine.updateSettings(newSettings);
    _storageService.saveSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final settings = engine.state.settings;

    return ResponsiveScaffold(
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
                  Text(
                    'SETTINGS',
                    style: WKTypography.label.copyWith(
                      color: WKColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  Text(
                    'PREFERENCES',
                    style: WKTypography.displayMedium.copyWith(
                      height: 0.95,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Audio, haptics, and game configurations.',
                    style: WKTypography.bodyMedium.copyWith(
                      color: WKColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  _sectionHeader('FEEDBACK'),
                  ToggleOption(
                    label: 'SOUND EFFECTS',
                    subtitle: 'Play audio cues during game events',
                    value: settings.soundEnabled,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      _updateSettings(engine, settings.copyWith(soundEnabled: v));
                    },
                  ),
                  const SizedBox(height: 12),
                  ToggleOption(
                    label: 'HAPTIC FEEDBACK',
                    subtitle: 'Vibrate on buttons, reveals, and countdowns',
                    value: settings.vibrationEnabled,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      _updateSettings(engine, settings.copyWith(vibrationEnabled: v));
                    },
                  ),
                  const SizedBox(height: 28),

                  _sectionHeader('WORD MANAGEMENT'),
                  _navigationTile(
                    label: 'My Words',
                    subtitle: '${engine.myWordsService.count} custom words',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: engine,
                            child: const MyWordsScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _navigationTile(
                    label: 'Associated Words',
                    subtitle:
                        '${engine.associatedWordsService.totalCount} generic words',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider.value(
                            value: engine,
                            child: const AssociatedWordsScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  _sectionHeader('ABOUT & INFO'),
                  _infoTile('App Version', '1.0.0 (Release)'),
                  _infoTile('Words in Database', '${WordDatabase.allWords.length} words'),
                  _infoTile('Categories', '${WordDatabase.categories.length} categories'),
                  _infoTile(
                    'Player Range',
                    '${GameConstants.minPlayers} – ${GameConstants.maxPlayers} players',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navigationTile({
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: WKColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: WKColors.blackMedium),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: WKTypography.bodyLarge.copyWith(
                      color: WKColors.offWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: WKTypography.bodySmall.copyWith(
                      color: WKColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: WKColors.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: WKTypography.label.copyWith(
          color: WKColors.textMuted,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: WKColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WKColors.blackMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: WKTypography.bodyMedium.copyWith(
              color: WKColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: WKTypography.bodyMedium.copyWith(
              color: WKColors.offWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
