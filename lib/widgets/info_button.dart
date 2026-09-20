import 'package:flutter/material.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';

/// Small ? circle that opens a bottom sheet with an explanation.
class InfoButton extends StatelessWidget {
  final String title;
  final String explanation;

  const InfoButton({
    super.key,
    required this.title,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfo(context),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: WKColors.textMuted, width: 1.5),
        ),
        child: Center(
          child: Text(
            '?',
            style: WKTypography.label.copyWith(
              fontSize: 12,
              color: WKColors.textMuted,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: WKColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: WKTypography.headingMedium.copyWith(
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              explanation,
              style: WKTypography.bodyMedium.copyWith(
                color: WKColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: WKColors.offWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'GOT IT',
                  style: WKTypography.button.copyWith(
                    color: WKColors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
