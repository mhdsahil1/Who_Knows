import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/word_database.dart';
import '../game/game_engine.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/category_tile.dart';
import '../widgets/info_button.dart';
import '../widgets/leave_game_dialog.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';
import '../widgets/setup_progress.dart';
import '../widgets/toggle_option.dart';
import 'associated_words_screen.dart';
import 'my_words_screen.dart';
import 'ready_screen.dart';

/// Setup Step 4/5 — CHOOSE YOUR WORDS
/// Allows selecting word categories, toggling personal word sources,
/// and toggling imposter category hints.
class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late Set<String> _selectedCategories;
  final List<String> _allCategories = WordDatabase.categories;

  @override
  void initState() {
    super.initState();
    final engine = context.read<GameEngine>();
    engine.myWordsService.loadWords();
    engine.associatedWordsService.loadWords();
    final current = engine.state.settings.selectedCategories;
    if (current.isNotEmpty) {
      _selectedCategories = Set<String>.from(current);
    } else {
      _selectedCategories = Set<String>.from(_allCategories);
    }
  }

  void _toggleCategory(String category) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _selectAll() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategories = Set<String>.from(_allCategories);
    });
  }

  void _clearAll() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategories.clear();
    });
  }

  void _shuffle() {
    HapticFeedback.mediumImpact();
    final rng = Random();
    final targetCount = 3 + rng.nextInt(max(1, min(6, _allCategories.length) - 2));
    final shuffled = List<String>.from(_allCategories)..shuffle(rng);
    setState(() {
      _selectedCategories = shuffled.take(targetCount).toSet();
    });
  }

  Future<void> _onLeave(GameEngine engine) async {
    final confirmed = await LeaveGameDialog.show(context);
    if (confirmed && mounted) {
      engine.leaveGame();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _onNext(GameEngine engine) {
    engine.setSelectedCategories(_selectedCategories);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: engine,
          child: const ReadyScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final settings = engine.state.settings;
    final myWordsCount = engine.myWordsService.count;
    final assocWordsCount = engine.associatedWordsService.totalCount;

    final hasSelection = _selectedCategories.isNotEmpty ||
        (settings.myWordsEnabled && myWordsCount > 0) ||
        (settings.associatedWordsEnabled && assocWordsCount > 0);

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
                    const SetupProgress(step: 4, total: 5),
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
                      'CHOOSE\nYOUR WORDS',
                      style: WKTypography.displayMedium.copyWith(
                        height: 0.95,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pick what can appear in this game.',
                      style: WKTypography.bodyMedium.copyWith(
                        color: WKColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section: PERSONAL WORD SOURCES
                    Text(
                      'PERSONAL WORD SOURCES',
                      style: WKTypography.label.copyWith(
                        color: WKColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // My Words Card
                    _buildPersonalSourceCard(
                      title: 'MY WORDS',
                      subtitle: '$myWordsCount words',
                      description: 'Custom words created for your games.',
                      isEnabled: settings.myWordsEnabled,
                      onToggle: (val) {
                        HapticFeedback.selectionClick();
                        engine.setMyWordsEnabled(val);
                      },
                      onManage: () {
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

                    // Associated Words Card
                    _buildPersonalSourceCard(
                      title: 'ASSOCIATED WORDS',
                      subtitle: '$assocWordsCount words',
                      description:
                          'Generic words dynamically combined with player names.',
                      isEnabled: settings.associatedWordsEnabled,
                      onToggle: (val) {
                        HapticFeedback.selectionClick();
                        engine.setAssociatedWordsEnabled(val);
                      },
                      onManage: () {
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
                    const SizedBox(height: 20),

                    // Section: BUILT-IN CATEGORIES
                    Text(
                      'BUILT-IN CATEGORIES',
                      style: WKTypography.label.copyWith(
                        color: WKColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick action buttons
                    Row(
                      children: [
                        _buildActionButton('SHUFFLE', _shuffle),
                        const SizedBox(width: 8),
                        _buildActionButton('SELECT ALL', _selectAll),
                        const SizedBox(width: 8),
                        _buildActionButton('CLEAR ALL', _clearAll),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Selected count counter
                    Text(
                      '${_selectedCategories.length} / ${_allCategories.length} CATEGORIES SELECTED',
                      style: WKTypography.label.copyWith(
                        color: WKColors.textMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category tiles
                    ..._allCategories.map((cat) {
                      final wordCount =
                          WordDatabase.allWords.where((w) => w.category == cat).length;
                      final isSelected = _selectedCategories.contains(cat);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CategoryTile(
                          name: cat,
                          wordCount: wordCount,
                          isSelected: isSelected,
                          onTap: () => _toggleCategory(cat),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Show hint to imposter option
                    Row(
                      children: [
                        Text(
                          'IMPOSTER HINTS',
                          style: WKTypography.label.copyWith(
                            color: WKColors.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const InfoButton(
                          title: 'SHOW HINT TO IMPOSTER',
                          explanation:
                              'When ON, Imposters see the category name (e.g. "Food") to help them blend in. When OFF, they receive no hint at all.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ToggleOption(
                      label: 'SHOW CATEGORY HINT',
                      subtitle: 'Imposter sees category name as a clue',
                      value: settings.showHintToImposter,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        engine.setShowHintToImposter(val);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // NEXT button
              Padding(
                padding: const EdgeInsets.all(24),
                child: PrimaryButton(
                  text: 'NEXT',
                  onPressed: hasSelection ? () => _onNext(engine) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalSourceCard({
    required String title,
    required String subtitle,
    required String description,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required VoidCallback onManage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled ? WKColors.surface : WKColors.blackLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isEnabled ? WKColors.offWhite : WKColors.blackMedium,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: WKTypography.headingSmall.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: isEnabled
                                  ? WKColors.offWhite
                                  : WKColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: WKColors.blackMedium,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            subtitle,
                            style: WKTypography.label.copyWith(
                              fontSize: 10,
                              color: WKColors.textMuted,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: WKTypography.bodySmall.copyWith(
                        color: WKColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeThumbColor: WKColors.yellow,
                activeTrackColor: WKColors.yellow.withValues(alpha: 0.3),
                inactiveThumbColor: WKColors.textMuted,
                inactiveTrackColor: WKColors.blackMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onManage,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.settings_outlined,
                      size: 14,
                      color: WKColors.yellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'MANAGE',
                      style: WKTypography.label.copyWith(
                        fontSize: 11,
                        color: WKColors.yellow,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: WKColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: WKColors.blackMedium),
          ),
          child: Center(
            child: Text(
              label,
              style: WKTypography.label.copyWith(
                fontSize: 11,
                color: WKColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
