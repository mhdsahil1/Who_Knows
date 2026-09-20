import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wk_colors.dart';

/// Typography scale for WHO KNOWS!
///
/// Headings: Space Grotesk — bold, geometric, oversized.
/// Body: Inter — clean, readable at distance.
class WKTypography {
  WKTypography._();

  // ── Display (oversized, commanding) ────────────────
  static TextStyle get displayHuge => GoogleFonts.spaceGrotesk(
        fontSize: 72,
        fontWeight: FontWeight.w700,
        color: WKColors.textPrimary,
        letterSpacing: -2,
        height: 0.9,
      );

  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: WKColors.textPrimary,
        letterSpacing: -1,
        height: 1.0,
      );

  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: WKColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.1,
      );

  // ── Heading ────────────────────────────────────────
  static TextStyle get headingLarge => GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: WKColors.textPrimary,
        letterSpacing: 0,
        height: 1.15,
      );

  static TextStyle get headingMedium => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: WKColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get headingSmall => GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: WKColors.textPrimary,
        height: 1.25,
      );

  // ── Body ───────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: WKColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: WKColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: WKColors.textMuted,
        height: 1.4,
      );

  // ── Labels & Buttons ───────────────────────────────
  static TextStyle get label => GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: WKColors.textMuted,
        letterSpacing: 2.5,
      );

  static TextStyle get labelLarge => GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: WKColors.textSecondary,
        letterSpacing: 2,
      );

  static TextStyle get button => GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: WKColors.black,
        letterSpacing: 1.5,
      );

  static TextStyle get buttonLarge => GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: WKColors.black,
        letterSpacing: 1.5,
      );

  // ── Numbers (monospaced feel for counters) ─────────
  static TextStyle get number => GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: WKColors.textPrimary,
        letterSpacing: 0,
      );

  static TextStyle get numberLarge => GoogleFonts.spaceGrotesk(
        fontSize: 96,
        fontWeight: FontWeight.w700,
        color: WKColors.textPrimary,
        letterSpacing: -4,
        height: 1.0,
      );
}
