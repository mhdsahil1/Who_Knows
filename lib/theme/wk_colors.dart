import 'package:flutter/material.dart';

/// The 6-color editorial palette for WHO KNOWS!
///
/// Rules:
/// - Most screens use BLACK + OFF_WHITE + ONE ACCENT
/// - Civilian reveal uses GREEN
/// - Imposter reveal uses RED
/// - Never use all six on one screen
class WKColors {
  WKColors._();

  // ── Core 6 ─────────────────────────────────────────
  static const Color black = Color(0xFF0D0D0D);
  static const Color offWhite = Color(0xFFF5F0EB);
  static const Color yellow = Color(0xFFFFD60A);
  static const Color blue = Color(0xFF4CC9F0);
  static const Color green = Color(0xFF06D6A0);
  static const Color red = Color(0xFFEF476F);

  // ── Derived shades ─────────────────────────────────
  static const Color blackLight = Color(0xFF1A1A1A);
  static const Color blackMedium = Color(0xFF2A2A2A);
  static const Color offWhiteDim = Color(0xFFBFB8AE);
  static const Color offWhiteMuted = Color(0xFF8A847C);
  static const Color yellowDim = Color(0xFFFFD60A);
  static const Color redDark = Color(0xFFD63A5E);
  static const Color greenDark = Color(0xFF05B88A);

  // ── Semantic aliases ───────────────────────────────
  static const Color background = black;
  static const Color surface = blackLight;
  static const Color surfaceElevated = blackMedium;
  static const Color textPrimary = offWhite;
  static const Color textSecondary = offWhiteDim;
  static const Color textMuted = offWhiteMuted;
  static const Color civilian = green;
  static const Color imposter = red;
  static const Color energy = yellow;
  static const Color accent = blue;

  // ── Player accent color cycle ──────────────────────
  /// Cycles through 4 accent colors for per-player theming.
  static const List<Color> playerAccents = [
    yellow,
    blue,
    green,
    red,
  ];

  /// Get the accent color for a player by index (wraps around).
  static Color playerAccent(int index) =>
      playerAccents[index % playerAccents.length];
}
