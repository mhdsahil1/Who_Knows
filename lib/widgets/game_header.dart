import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A reusable top header for game screens.
class GameHeader extends StatelessWidget {
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;

  const GameHeader({
    super.key,
    this.subtitle,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppTheme.textPrimary,
              iconSize: 20,
              tooltip: 'Back',
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.titleGradient.createShader(bounds),
                  child: Text(
                    'WHO KNOWS!',
                    style: AppTheme.label.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing ?? const SizedBox(width: 48),
        ],
      ),
    );
  }
}
