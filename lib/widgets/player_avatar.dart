import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A circular avatar with the player's initial, a colorful gradient, and an active glow.
class PlayerAvatar extends StatelessWidget {
  final String name;
  final bool isEliminated;
  final bool isSelected;
  final double size;
  final int? playerIndex;

  const PlayerAvatar({
    super.key,
    required this.name,
    this.isEliminated = false,
    this.isSelected = false,
    this.size = 48,
    this.playerIndex,
  });

  List<Color> _gradientForName(String name, int? index) {
    const palettes = [
      [Color(0xFF8B5CF6), Color(0xFF6D28D9)], // Violet
      [Color(0xFF06B6D4), Color(0xFF0284C7)], // Cyan
      [Color(0xFFF43F5E), Color(0xFFBE123C)], // Crimson
      [Color(0xFF10B981), Color(0xFF059669)], // Emerald
      [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
      [Color(0xFFEC4899), Color(0xFFBE185D)], // Pink
      [Color(0xFF3B82F6), Color(0xFF1D4ED8)], // Blue
      [Color(0xFF14B8A6), Color(0xFF0F766E)], // Teal
      [Color(0xFF84CC16), Color(0xFF4D7C0F)], // Lime
      [Color(0xFFA855F7), Color(0xFF7E22CE)], // Purple
      [Color(0xFFE11D48), Color(0xFF9F1239)], // Rose
      [Color(0xFF6366F1), Color(0xFF4338CA)], // Indigo
    ];
    final selectedIndex = index != null
        ? index % palettes.length
        : name.codeUnits.fold<int>(0, (sum, c) => sum + c) % palettes.length;
    return palettes[selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradientForName(name, playerIndex);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isEliminated
            ? null
            : LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isEliminated ? AppTheme.surfaceHighlight : null,
        boxShadow: isSelected && !isEliminated
            ? [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.6),
                  blurRadius: 14,
                  spreadRadius: 2,
                )
              ]
            : null,
        border: Border.all(
          color: isSelected
              ? Colors.white
              : isEliminated
                  ? AppTheme.textMuted
                  : Colors.white.withValues(alpha: 0.25),
          width: isSelected ? 2.5 : 1.5,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppTheme.headingSmall.copyWith(
            fontSize: size * 0.45,
            fontWeight: FontWeight.w800,
            color: isEliminated ? AppTheme.textMuted : Colors.white,
          ),
        ),
      ),
    );
  }
}
