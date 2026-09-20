import 'package:flutter/material.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';

/// Minimal setup step indicator: SETUP 01 / 04
class SetupProgress extends StatelessWidget {
  final int step;
  final int total;

  const SetupProgress({
    super.key,
    required this.step,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final stepStr = step.toString().padLeft(2, '0');
    final totalStr = total.toString().padLeft(2, '0');

    return Text(
      'SETUP $stepStr / $totalStr',
      style: WKTypography.label.copyWith(
        color: WKColors.textMuted,
        letterSpacing: 3,
      ),
    );
  }
}
