import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';

/// Large player card for voting: number + name + initial avatar.
/// Selected state: solid red background.
class VotePlayerTile extends StatelessWidget {
  final String name;
  final int number;
  final bool isSelected;
  final VoidCallback onTap;

  const VotePlayerTile({
    super.key,
    required this.name,
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? WKColors.red : WKColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? WKColors.red : WKColors.blackMedium,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Number
            SizedBox(
              width: 32,
              child: Text(
                number.toString().padLeft(2, '0'),
                style: WKTypography.number.copyWith(
                  fontSize: 16,
                  color: isSelected
                      ? WKColors.offWhite.withValues(alpha: 0.5)
                      : WKColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Initial avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? WKColors.offWhite.withValues(alpha: 0.2)
                    : WKColors.blackMedium,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: WKTypography.headingSmall.copyWith(
                    fontSize: 16,
                    color: isSelected ? WKColors.offWhite : WKColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Name
            Expanded(
              child: Text(
                name.toUpperCase(),
                style: WKTypography.headingSmall.copyWith(
                  fontSize: 16,
                  color: isSelected ? WKColors.offWhite : WKColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: WKColors.offWhite,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
