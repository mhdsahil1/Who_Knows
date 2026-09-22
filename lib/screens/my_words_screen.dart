import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../game/game_engine.dart';
import '../models/my_word.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';

/// Screen for managing custom user-added words ("My Words").
class MyWordsScreen extends StatefulWidget {
  const MyWordsScreen({super.key});

  @override
  State<MyWordsScreen> createState() => _MyWordsScreenState();
}

class _MyWordsScreenState extends State<MyWordsScreen> {
  @override
  void initState() {
    super.initState();
    final service = context.read<GameEngine>().myWordsService;
    service.loadWords();
  }

  void _showAddEditDialog({MyWord? existingWord}) {
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
                isEditing ? 'EDIT MY WORD' : 'ADD MY WORD',
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
                    'Enter a custom word or phrase for your games.',
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
                      hintText: 'e.g. That Restaurant',
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
                          dialogContext.read<GameEngine>().myWordsService;
                      final text = controller.text;
                      final error = isEditing
                          ? await service.editWord(existingWord.id, text)
                          : await service.addWord(text);
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
                        dialogContext.read<GameEngine>().myWordsService;
                    final text = controller.text;
                    final error = isEditing
                        ? await service.editWord(existingWord.id, text)
                        : await service.addWord(text);
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

  Future<void> _confirmDelete(MyWord word) async {
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
            'Are you sure you want to remove "${word.text}" from My Words?',
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
      final service = context.read<GameEngine>().myWordsService;
      await service.deleteWord(word.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final myWordsService = engine.myWordsService;

    return ListenableBuilder(
      listenable: myWordsService,
      builder: (context, _) {
        final words = myWordsService.words;

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
                        'MY WORDS',
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
                          'MY WORDS',
                          style: WKTypography.displayMedium.copyWith(
                            height: 0.95,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Custom words for your games. Words survive app restarts.',
                          style: WKTypography.bodyMedium.copyWith(
                            color: WKColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Counter
                        Text(
                          '${words.length} CUSTOM WORD${words.length == 1 ? '' : 'S'}',
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

                // Words list or empty state
                Expanded(
                  child: words.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: words.length,
                          itemBuilder: (context, index) {
                            final word = words[index];
                            return _buildWordTile(word);
                          },
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: WKColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: WKColors.blackMedium),
              ),
              child: const Icon(
                Icons.text_fields_rounded,
                color: WKColors.textMuted,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'NO CUSTOM WORDS YET',
              style: WKTypography.headingSmall.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your group\'s inside jokes, local spots, or custom words to use during games.',
              style: WKTypography.bodyMedium.copyWith(
                color: WKColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordTile(MyWord word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          // Edit
          GestureDetector(
            onTap: () => _showAddEditDialog(existingWord: word),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.edit_rounded,
                color: WKColors.textMuted,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Delete
          GestureDetector(
            onTap: () => _confirmDelete(word),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: WKColors.red,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
