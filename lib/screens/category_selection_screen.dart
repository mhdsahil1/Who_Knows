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
import 'ready_screen.dart';

/// Setup Step 3/4 — CHOOSE YOUR WORDS
/// Allows selecting word categories and toggling imposter category hints.
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
    if (_selectedCategories.isEmpty) return;
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
    final hasSelection = _selectedCategories.isNotEmpty;

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
                    const SetupProgress(step: 3, total: 4),
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
                    const SizedBox(height: 20),

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
