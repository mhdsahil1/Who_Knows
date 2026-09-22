import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';

/// Labeled ON/OFF toggle with optional subtitle and ? info button.
class ToggleOption extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onInfo;
  final String trueText;
  final String falseText;

  const ToggleOption({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.onInfo,
    this.trueText = 'ON',
    this.falseText = 'OFF',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: WKColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WKColors.blackMedium),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: WKTypography.headingSmall.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    if (onInfo != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onInfo,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: WKColors.textMuted,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '?',
                              style: WKTypography.label.copyWith(
                                fontSize: 11,
                                color: WKColors.textMuted,
                                letterSpacing: 0,
                              ),
                            ),
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
                      color: WKColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Toggle selector
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleChip(trueText, value, true),
              const SizedBox(width: 6),
              _buildToggleChip(falseText, !value, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip(String text, bool isActive, bool targetValue) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(targetValue);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? WKColors.offWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? WKColors.offWhite : WKColors.blackMedium,
          ),
        ),
        child: Text(
          text,
          style: WKTypography.label.copyWith(
            fontSize: 11,
            color: isActive ? WKColors.black : WKColors.textMuted,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
