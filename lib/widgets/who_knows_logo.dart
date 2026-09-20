import 'package:flutter/material.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';

/// Oversized WHO KNOWS! wordmark. Pure typography, no gradients.
class WhoKnowsLogo extends StatelessWidget {
  final double fontSize;
  final Color color;

  const WhoKnowsLogo({
    super.key,
    this.fontSize = 48,
    this.color = WKColors.offWhite,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'WHO\nKNOWS!',
      style: WKTypography.displayLarge.copyWith(
        fontSize: fontSize,
        color: color,
        height: 0.95,
        letterSpacing: 3,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }
}
