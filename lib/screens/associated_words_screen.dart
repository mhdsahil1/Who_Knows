import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../models/associated_word.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';

/// Screen for managing the Associated Word Database.
///
/// Shows protected built-in words and user-created custom words.
class AssociatedWordsScreen extends StatefulWidget {
  const AssociatedWordsScreen({super.key});

  @override
  State<AssociatedWordsScreen> createState() => _AssociatedWordsScreenState();
}

class _AssociatedWordsScreenState extends State<AssociatedWordsScreen> {
  @override
  void initState() {
    super.initState();
    final service = context.read<GameEngine>().associatedWordsService;
    service.loadWords();
  }

  void _showAddEditDialog({AssociatedWord? existingWord}) {
    HapticFeedback.lightImpact();
    final isEditing = existingWord != null;
    final controller = TextEditingController(text: existingWord?.text ?? '');
    String? errorMessage;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: WKColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: WKColors.blackMedium),
              ),
              title: Text(
                isEditing ? 'EDIT ASSOCIATED WORD' : 'ADD ASSOCIATED WORD',
                style: WKTypography.headingSmall.copyWith(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter a generic word that can be attached to any player (e.g. "Bike", "That Weird Teacher").',
                    style: WKTypography.bodySmall.copyWith(
                      color: WKColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: WKTypography.bodyLarge.copyWith(
                      color: WKColors.offWhite,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Bike',
                      hintStyle: WKTypography.bodyMedium.copyWith(
                        color: WKColors.textMuted,
                      ),
                      errorText: errorMessage,
                      filled: true,
                      fillColor: WKColors.blackLight,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: WKColors.blackMedium),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: WKColors.yellow),
                      ),
                    ),
                    onSubmitted: (_) async {
                      final service =
                          dialogContext.read<GameEngine>().associatedWordsService;
                      final text = controller.text;
                      final error = isEditing
                          ? await service.editUserWord(existingWord.id, text)
                          : await service.addUserWord(text);
                      if (!dialogContext.mounted) return;
                      if (error != null) {
                        setDialogState(() => errorMessage = error);
                      } else {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'CANCEL',
                    style: WKTypography.label.copyWith(
                      color: WKColors.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final service =
                        dialogContext.read<GameEngine>().associatedWordsService;
                    final text = controller.text;
                    final error = isEditing
                        ? await service.editUserWord(existingWord.id, text)
                        : await service.addUserWord(text);
                    if (!dialogContext.mounted) return;
                    if (error != null) {
                      setDialogState(() => errorMessage = error);
                    } else {
                      HapticFeedback.selectionClick();
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: Text(
                    isEditing ? 'SAVE' : 'ADD',
                    style: WKTypography.label.copyWith(
                      color: WKColors.yellow,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(AssociatedWord word) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: WKColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: WKColors.blackMedium),
          ),
          title: Text(
            'DELETE WORD',
            style: WKTypography.headingSmall.copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to remove "${word.text}" from Associated Words?',
            style: WKTypography.bodyMedium.copyWith(
              color: WKColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'CANCEL',
                style: WKTypography.label.copyWith(
                  color: WKColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'DELETE',
                style: WKTypography.label.copyWith(
                  color: WKColors.red,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final service = context.read<GameEngine>().associatedWordsService;
      await service.deleteUserWord(word.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final service = engine.associatedWordsService;

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final userWords = service.userWords;
        final builtInWords = service.builtInWords;
        final totalCount = service.totalCount;

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
                        'ASSOCIATED WORDS',
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
                const SizedBox(height: 24),

                // Title and subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ASSOCIATED\nWORDS',
                          style: WKTypography.displayMedium.copyWith(
                            height: 0.95,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Words that can be attached to any player during a game (e.g. "Asheel\'s Bike").',
                          style: WKTypography.bodyMedium.copyWith(
                            color: WKColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Counter
                        Text(
                          '$totalCount TOTAL WORDS (${userWords.length} CUSTOM • ${builtInWords.length} BUILT-IN)',
                          style: WKTypography.label.copyWith(
                            color: WKColors.textMuted,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Words list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      if (userWords.isNotEmpty) ...[
                        _buildSectionHeader('YOUR WORDS (${userWords.length})'),
                        ...userWords.map((w) => _buildWordTile(w)),
                        const SizedBox(height: 20),
                      ],
                      _buildSectionHeader('BUILT-IN WORDS (${builtInWords.length})'),
                      ...builtInWords.map((w) => _buildWordTile(w)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Bottom Add Word Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: PrimaryButton(
                    text: '+ ADD WORD',
                    onPressed: () => _showAddEditDialog(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: WKTypography.label.copyWith(
          color: WKColors.textMuted,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildWordTile(AssociatedWord word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: WKColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WKColors.blackMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              word.text,
              style: WKTypography.bodyLarge.copyWith(
                color: WKColors.offWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (word.isBuiltIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: WKColors.blackLight,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: WKColors.blackMedium),
              ),
              child: Text(
                'BUILT-IN',
                style: WKTypography.label.copyWith(
                  fontSize: 10,
                  color: WKColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
            )
          else ...[
            // Edit
            GestureDetector(
              onTap: () => _showAddEditDialog(existingWord: word),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.edit_rounded,
                  color: WKColors.textMuted,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Delete
            GestureDetector(
              onTap: () => _confirmDelete(word),
              child: Container(
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: WKColors.red,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
