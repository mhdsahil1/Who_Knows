import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';

/// A dramatic, themed confirmation dialog for group votes and high-stakes choices.
class ConfirmVoteDialog extends StatelessWidget {
  final String playerName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmVoteDialog({
    super.key,
    required this.playerName,
    required this.onConfirm,
    required this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String playerName,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => ConfirmVoteDialog(
        playerName: playerName,
        onConfirm: () => Navigator.of(dialogCtx).pop(true),
        onCancel: () => Navigator.of(dialogCtx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        side: const BorderSide(color: AppTheme.cardBorder, width: 1.5),
      ),
      contentPadding: const EdgeInsets.all(AppTheme.spacingXl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.danger.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.gavel_rounded,
              color: AppTheme.danger,
              size: 32,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'YOU CHOSE',
            style: AppTheme.label.copyWith(
              letterSpacing: 2,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            playerName.toUpperCase(),
            style: AppTheme.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Is your group completely sure?\nThis decision cannot be undone.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXl),
          PrimaryButton(
            text: 'CONFIRM ELIMINATION',
            icon: Icons.check_circle_rounded,
            gradient: AppTheme.dangerGradient,
            onPressed: onConfirm,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          SecondaryButton(
            text: 'CHANGE SUSPECT',
            icon: Icons.arrow_back_rounded,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
