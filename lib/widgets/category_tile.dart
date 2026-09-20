import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import 'category_icon.dart';

/// Category card with icon, name, and word count.
/// Solid background swap on select.
class CategoryTile extends StatelessWidget {
  final String name;
  final int wordCount;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.name,
    required this.wordCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = CategoryIcon.forCategory(name);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? WKColors.offWhite : WKColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? WKColors.offWhite : WKColors.blackMedium,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? WKColors.black : WKColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name.toUpperCase(),
                style: WKTypography.headingSmall.copyWith(
                  fontSize: 14,
                  color: isSelected ? WKColors.black : WKColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? WKColors.black.withValues(alpha: 0.1)
                    : WKColors.blackMedium,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$wordCount',
                style: WKTypography.label.copyWith(
                  fontSize: 11,
                  color: isSelected ? WKColors.black : WKColors.textMuted,
                  letterSpacing: 0,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 10),
              const Icon(
                Icons.check_rounded,
                color: WKColors.black,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
