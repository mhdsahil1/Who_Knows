import 'package:flutter/material.dart';
import 'wk_colors.dart';
import 'wk_typography.dart';

/// The visual identity for WHO KNOWS! — editorial, minimal, bold.
///
/// This class re-exports the WKColors and WKTypography tokens for
/// backward compatibility while all screens are being migrated.
class AppTheme {
  AppTheme._();

  // ── Re-exported colors (backward compat) ───────────
  static const Color background = WKColors.background;
  static const Color surface = WKColors.surface;
  static const Color surfaceLight = WKColors.surfaceElevated;
  static const Color surfaceHighlight = WKColors.surfaceElevated;
  static const Color cardBorder = WKColors.blackMedium;
  static const Color cardBorderGlow = WKColors.blackMedium;

  static const Color primary = WKColors.yellow;
  static const Color primaryLight = WKColors.yellow;
  static const Color primaryDark = WKColors.yellow;

  static const Color secondary = WKColors.blue;
  static const Color secondaryLight = WKColors.blue;
  static const Color accent = WKColors.blue;

  static const Color danger = WKColors.red;
  static const Color dangerDark = WKColors.redDark;

  static const Color success = WKColors.green;
  static const Color successDark = WKColors.greenDark;

  static const Color warning = WKColors.yellow;
  static const Color warningLight = WKColors.yellow;

  static const Color textPrimary = WKColors.textPrimary;
  static const Color textSecondary = WKColors.textSecondary;
  static const Color textMuted = WKColors.textMuted;

  // ── Flat backgrounds (no gradients) ────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [WKColors.black, WKColors.black],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [WKColors.yellow, WKColors.yellow],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [WKColors.red, WKColors.red],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [WKColors.green, WKColors.green],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [WKColors.blue, WKColors.blue],
  );

  static const LinearGradient titleGradient = LinearGradient(
    colors: [WKColors.offWhite, WKColors.offWhite],
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [WKColors.blackLight, WKColors.blackLight],
  );

  // ── No glows, no heavy shadows ─────────────────────
  static const BoxShadow primaryGlow = BoxShadow(
    color: Colors.transparent,
    blurRadius: 0,
  );

  static const BoxShadow dangerGlow = BoxShadow(
    color: Colors.transparent,
    blurRadius: 0,
  );

  static const BoxShadow successGlow = BoxShadow(
    color: Colors.transparent,
    blurRadius: 0,
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Colors.transparent,
    blurRadius: 0,
  );

  // ── Border Radius ──────────────────────────────────
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 20.0;

  // ── Spacing ────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ── Typography (delegating to WKTypography) ────────
  static TextStyle get headingLarge => WKTypography.headingLarge;
  static TextStyle get headingMedium => WKTypography.headingMedium;
  static TextStyle get headingSmall => WKTypography.headingSmall;
  static TextStyle get bodyLarge => WKTypography.bodyLarge;
  static TextStyle get bodyMedium => WKTypography.bodyMedium;
  static TextStyle get bodySmall => WKTypography.bodySmall;
  static TextStyle get label => WKTypography.label;
  static TextStyle get buttonText => WKTypography.button;

  // ── ThemeData ──────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: WKColors.black,
        colorScheme: const ColorScheme.dark(
          primary: WKColors.yellow,
          secondary: WKColors.blue,
          surface: WKColors.surface,
          error: WKColors.red,
        ),
        textTheme: TextTheme(
          headlineLarge: headingLarge,
          headlineMedium: headingMedium,
          headlineSmall: headingSmall,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelSmall: label,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: headingSmall,
          iconTheme: const IconThemeData(color: WKColors.textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: WKColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: WKColors.blackMedium),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: WKColors.blackMedium),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: WKColors.yellow, width: 2),
          ),
          hintStyle: bodyMedium.copyWith(color: WKColors.textMuted),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingMd,
          ),
        ),
      );
}
