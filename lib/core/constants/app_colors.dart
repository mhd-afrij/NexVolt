import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); 

  // ── Primary Brand Colors ──────────────────────────────
  static const Color emeraldGreen = Color(0xFF50C878);
  static const Color evGreen = Color(0xFF28C741);
  static const Color electricBlue = Color(0xFF0077FF);

  // ── Gradient (used on every screen background) ────────
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
