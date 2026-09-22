import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';

/// Large selectable area for game configuration options.
/// Solid background fill on selection — no radio buttons.
class OptionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? badge;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const OptionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    this.badgeColor,
    this.badgeTextColor,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? WKColors.offWhite : WKColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? WKColors.offWhite : WKColors.blackMedium,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? WKColors.black : WKColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 14),
            ],
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
                            color: isSelected
                                ? WKColors.black
                                : WKColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (badgeColor ?? WKColors.green)
                                : (badgeColor ?? WKColors.green)
                                    .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: WKTypography.label.copyWith(
                              fontSize: 9,
                              color: isSelected
                                  ? (badgeTextColor ?? WKColors.black)
                                  : (badgeColor ?? WKColors.green),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: WKTypography.bodySmall.copyWith(
                        color: isSelected
                            ? WKColors.black.withValues(alpha: 0.6)
                            : WKColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
