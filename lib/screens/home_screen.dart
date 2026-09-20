import 'package:flutter/material.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/observer_graphic.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';

/// Home landing screen with Observer motif, oversized title, and GET STARTED CTA.
class HomeScreen extends StatelessWidget {
  final VoidCallback onPlay;
  final VoidCallback onHowToPlay;
  final VoidCallback onSettings;

  const HomeScreen({
    super.key,
    required this.onPlay,
    required this.onHowToPlay,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Observer motif — the eye watches
              const ObserverGraphic(
                size: 180,
                color: WKColors.offWhite,
                animate: true,
              ),
              const SizedBox(height: 32),
              // Oversized title
              Text(
                'WHO\nKNOWS!',
                style: WKTypography.displayLarge.copyWith(
                  fontSize: 52,
                  height: 0.92,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              // Tagline
              Text(
                'Everyone knows.\nOne doesn\'t.',
                style: WKTypography.bodyLarge.copyWith(
                  color: WKColors.textSecondary,
                  fontSize: 17,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              // GET STARTED
              PrimaryButton(
                text: 'GET STARTED',
                onPressed: onPlay,
              ),
              const SizedBox(height: 14),
              // HOW TO PLAY
              SecondaryButton(
                text: 'HOW TO PLAY',
                onPressed: onHowToPlay,
              ),
              const SizedBox(height: 8),
              // Settings text button
              TextButton(
                onPressed: onSettings,
                child: Text(
                  'SETTINGS',
                  style: WKTypography.label.copyWith(
                    color: WKColors.textMuted,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
