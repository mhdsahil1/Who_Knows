import 'package:flutter/material.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';

/// Leave game confirmation dialog.
///
/// "LEAVE GAME?"
/// "Your current game will be lost."
/// [KEEP PLAYING] [LEAVE GAME]
class LeaveGameDialog extends StatelessWidget {
  const LeaveGameDialog({super.key});

  /// Show the dialog and return true if the user confirmed leaving.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: WKColors.black.withValues(alpha: 0.85),
      builder: (_) => const LeaveGameDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: WKColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LEAVE GAME?',
              style: WKTypography.headingLarge.copyWith(
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your current game will be lost.',
              style: WKTypography.bodyMedium.copyWith(
                color: WKColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            // Keep Playing
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  backgroundColor: WKColors.offWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'KEEP PLAYING',
                  style: WKTypography.button.copyWith(color: WKColors.black),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Leave Game
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  backgroundColor: WKColors.red.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: WKColors.red.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                child: Text(
                  'LEAVE GAME',
                  style: WKTypography.button.copyWith(color: WKColors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
