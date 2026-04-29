import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // KINETIC CONDUIT PALETTE
  // ═══════════════════════════════════════════════════════════════

  // ── The Void Base (Background) ─────────────────────────────────
  static const Color voidBase = Color(0xFF0A0E12);
  static const Color surface = voidBase;
  static const Color background = voidBase;

  // ── Surface Hierarchy (Tonal Layering) ──────────────────────────
  static const Color surfaceContainerLowest = Color(0xFF0D1117);
  static const Color surfaceContainerLow = Color(0xFF111921);
  static const Color surfaceContainer = Color(0xFF151D26);
  static const Color surfaceContainerHigh = Color(0xFF1A222C);
  static const Color surfaceContainerHighest = Color(0xFF1F2832);

  // ── Electric Volt (Primary) ─────────────────────────────────────
  static const Color primary = Color(0xFF39FF14);
  static const Color primaryDim = Color(0xFF1A9922);
  static const Color primaryContainer = Color(0xFF228B22);
  static const Color onPrimary = Color(0xFF0A0E12);
  static const Color onPrimaryContainer = primary;

  // ── Pulse Cyan (Secondary) ─────────────────────────────────────
  static const Color secondary = Color(0xFF00F5FF);
  static const Color secondaryDim = Color(0xFF008B94);
  static const Color secondaryContainer = Color(0xFF005F66);
  static const Color onSecondary = voidBase;
  static const Color onSecondaryContainer = secondary;

  // ── Tertiary ────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFFB388FF);
  static const Color onTertiary = voidBase;

  // ── Error ───────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF5252);
  static const Color onError = voidBase;
  static const Color errorContainer = Color(0xFF4A1515);
  static const Color onErrorContainer = error;

  // ── On-Surface (Text Hierarchy) ─────────────────────────────────
  static const Color onSurface = Color(0xFFE6EBF0);
  static const Color onSurfaceVariant = Color(0xFF8B949E);
  static const Color outline = Color(0xFF30363D);
  static const Color outlineVariant = Color(0xFF21262D);

  // ── Ghost Border (15% opacity for accessibility) ───────────────
  static const Color ghostBorder = Color(0x26FFFFFF);
  static const Color ghostBorderSecondary = Color(0x3300F5FF);

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════

  // Primary CTA Gradient (Electric Volt → Green)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary Gradient (Cyan to Electric)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent Glow Gradient
  static const LinearGradient accentGlowGradient = LinearGradient(
    colors: [Color(0x0039FF14), Color(0x0000F5FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Vehicle Card Gradient
  static const LinearGradient vehicleCardGradient = LinearGradient(
    colors: [Color(0xFF1A222C), Color(0xFF0D1117)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════
  // SHADOWS & GLOWS
  // ═══════════════════════════════════════════════════════════════

  // Ambient Glow (Primary tinted)
  static Color primaryGlow = primary.withValues(alpha: 0.10);
  static Color primaryGlowStrong = primary.withValues(alpha: 0.20);

  // Secondary Glow
  static Color secondaryGlow = secondary.withValues(alpha: 0.10);
  static Color secondaryGlowStrong = secondary.withValues(alpha: 0.20);

  // Card Shadow (tinted, not black)
  static Color cardShadow = primary.withValues(alpha: 0.08);
  static Color cardShadowStrong = primary.withValues(alpha: 0.15);

  // ═══════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════

  // navBackground is defined above with glass effect for legacy compatibility
  static const Color navSelected = primary;
  static const Color navUnselected = onSurfaceVariant;

  // ═══════════════════════════════════════════════════════════════
  // INPUTS & FIELDS
  // ═══════════════════════════════════════════════════════════════

  static const Color inputFill = surfaceContainerHighest;
  static const Color inputBorder = Colors.transparent;
  static const Color inputFocusedBorder = secondary;
  static const Color inputFocusedGlow = Color(0x4000F5FF); // secondary 25%

  // ═══════════════════════════════════════════════════════════════
  // STATUS COLORS
  // ═══════════════════════════════════════════════════════════════

  static const Color success = primary;
  static const Color warning = Color(0xFFFFA726);
  static const Color info = secondary;

  // Battery Status
  static const Color batteryLow = error;
  static const Color batteryMedium = warning;
  static const Color batteryHigh = primary;

  // Charging Status
  static const Color charging = primary;
  static const Color chargingComplete = secondary;

  // ═══════════════════════════════════════════════════════════════
  // MISC
  // ═══════════════════════════════════════════════════════════════

  static const Color divider = Color(0xFF21262D);
  static const Color shimmerBase = surfaceContainerLow;
  static const Color shimmerHighlight = surfaceContainerHigh;

  // OTP
  static const Color otpBoxFill = surfaceContainerHighest;
  static const Color otpBoxFocused = secondary;

  // Cards
  static const Color cardBackground = surfaceContainerLow;
  static const BorderRadius cardBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(24),
  );

  // ═══════════════════════════════════════════════════════════════
  // LEGACY ALIASES (for compatibility)
  // ═══════════════════════════════════════════════════════════════

  static const Color accent = primary;
  static const Color electricBlue = secondary;
  static const Color emeraldGreen = primary;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textHint = onSurfaceVariant;
  static const Color cardBorder = outlineVariant;
  static const Color backgroundTop = voidBase;
  static const Color backgroundBottom = surfaceContainerLow;
  static const Color cardBackgroundElevated = surfaceContainerHigh;
  static const Color navBackground = Color(
    0xE6151D26,
  ); // glass effect for legacy
  static const Color navInactive = onSurfaceVariant;
  static const Color star = Color(0xFFFFC107);
  static const Color weatherCard = surfaceContainerHigh;

  // Button Colors
  static const Color buttonTextColor = onPrimary;
  static const Color buttonDisabled = surfaceContainerHigh;

  // Step Indicator
  static const Color stepActive = secondary;
  static const Color stepDone = primary;
  static const Color stepInactive = outline;

  // Snackbar
  static const Color snackBarError = error;
  static const Color snackBarSuccess = primary;
  static const Color snackBarInfo = secondary;

  // Language Selection
  static const Color langSelectedBg = Color(0x3300F5FF);
  static const Color langUnselectedBg = surfaceContainerHigh;
  static const Color langSelectedBorder = secondary;

  // Dropdown
  static const Color dropdownSelected = secondary;
  static const Color dropdownUnselected = surfaceContainerHigh;
}
