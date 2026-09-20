import 'package:flutter/material.dart';
import '../theme/wk_colors.dart';
import '../theme/wk_typography.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_scaffold.dart';

/// Screen 3 — How to Play: 5 illustrated steps with explicit verbal clue guidance.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: WKColors.textMuted,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'HOW TO PLAY',
                    style: WKTypography.label.copyWith(
                      color: WKColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  Text(
                    'RULES OF\nENGAGEMENT',
                    style: WKTypography.displayMedium.copyWith(
                      height: 0.95,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A party game of deception and bluffing.',
                    style: WKTypography.bodyMedium.copyWith(
                      color: WKColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildStep(
                    number: '01',
                    title: 'PASS THE PHONE',
                    description:
                        'Everyone secretly slides up to receive their role. Civilians see the secret word. The Imposter does not know the word.',
                    icon: Icons.phone_android_rounded,
                  ),
                  _buildStep(
                    number: '02',
                    title: 'GIVE YOUR CLUE',
                    description:
                        'Give your clue aloud. Never type it into the phone.',
                    icon: Icons.record_voice_over_rounded,
                    highlight: true,
                  ),
                  _buildStep(
                    number: '03',
                    title: 'DISCUSS',
                    description:
                        'Put the phone down and talk it out. Figure out who doesn\'t know the secret word.',
                    icon: Icons.forum_rounded,
                  ),
                  _buildStep(
                    number: '04',
                    title: 'VOTE',
                    description:
                        'The group picks up the phone and chooses ONE suspect. No individual secret voting.',
                    icon: Icons.gavel_rounded,
                  ),
                  _buildStep(
                    number: '05',
                    title: 'FINAL GUESS',
                    description:
                        'Caught Imposter gets one last chance to guess the secret word and snatch victory.',
                    icon: Icons.psychology_rounded,
                  ),
                  const SizedBox(height: 20),

                  // Win conditions
                  _buildWinCard(
                    title: 'CIVILIANS WIN',
                    subtitle: 'Catch the Imposter AND they fail the final guess.',
                    color: WKColors.green,
                    icon: Icons.shield_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildWinCard(
                    title: 'IMPOSTER WINS',
                    subtitle: 'Avoid getting caught, OR guess the secret word when caught.',
                    color: WKColors.red,
                    icon: Icons.whatshot_rounded,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: PrimaryButton(
                text: 'GOT IT',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    bool highlight = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? WKColors.yellow.withValues(alpha: 0.1)
            : WKColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? WKColors.yellow : WKColors.blackMedium,
          width: highlight ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: highlight ? WKColors.yellow : WKColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: WKTypography.number.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: highlight ? WKColors.black : WKColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: highlight ? WKColors.yellow : WKColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: WKTypography.headingSmall.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: highlight ? WKColors.yellow : WKColors.offWhite,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: WKTypography.bodyMedium.copyWith(
                    color: highlight ? WKColors.offWhite : WKColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: WKColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WKTypography.headingSmall.copyWith(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: WKTypography.bodySmall.copyWith(
                    color: WKColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
