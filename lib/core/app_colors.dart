import 'package:flutter/material.dart';

/// ╔══════════════════════════════════════════════════════╗
/// ║              NexVolt — App Colors                   ║
/// ║  All colors in ONE place. Change here → changes     ║
/// ║  everywhere across the entire app automatically.    ║
/// ╚══════════════════════════════════════════════════════╝

class AppColors {
  AppColors._(); // prevent instantiation

  // ── Primary Brand Colors ──────────────────────────────
  static const Color emeraldGreen = Color(0xFF50C878);
  static const Color electricBlue = Color(0xFF0077FF);

  // ── Gradient (used on every screen background) ────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [emeraldGreen, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Reversed gradient (for some buttons/accents)
  static const LinearGradient reversedGradient = LinearGradient(
    colors: [electricBlue, emeraldGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── White Card (bottom sheet style on all screens) ────
  static const Color cardBackground = Colors.white;
  static const BorderRadius cardBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(50),
    topRight: Radius.circular(50),
  );

  // ── Text Colors ───────────────────────────────────────
  static const Color textOnGradient       = Colors.white;
  static const Color textOnGradientMuted  = Colors.white70;
  static const Color textPrimary          = Color(0xFF1A1A1A);
  static const Color textSecondary        = Color(0xFF6B6B6B);
  static const Color textHint            = Color(0xFF9E9E9E);

  // ── Input Field ───────────────────────────────────────
  static const Color inputFill           = Color(0xFFF5F5F5); // grey.shade100
  static const Color inputBorder         = Colors.transparent;

  // ── Button Colors ─────────────────────────────────────
  // animated button uses primaryGradient lerp — see AppAnimations
  static const Color buttonTextColor     = Colors.white;
  static const Color buttonDisabled      = Color(0xFFB0B0B0);

  // ── Status / Feedback Colors ──────────────────────────
  static const Color success             = Color(0xFF50C878); // same as emerald
  static const Color error              = Color(0xFFE53935);
  static const Color errorLight         = Color(0xFFFFEBEE);
  static const Color errorBorder        = Color(0xFFEF9A9A);
  static const Color warning            = Color(0xFFFFA726);
  static const Color info               = Color(0xFF0077FF); // same as electric blue

  // ── SnackBar ──────────────────────────────────────────
  static const Color snackBarError      = Color(0xFFD32F2F);
  static const Color snackBarSuccess    = Color(0xFF388E3C);
  static const Color snackBarInfo       = Color(0xFF1565C0);

  // ── Vehicle Card (home screen) ────────────────────────
  static const LinearGradient vehicleCardGradient = LinearGradient(
    colors: [emeraldGreen, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color vehicleCardOverlay  = Color(0x33FFFFFF); // white 20%

  // ── Bottom Nav Bar ────────────────────────────────────
  static const Color navBarBackground   = Colors.white;
  static const Color navBarSelected     = electricBlue;
  static const Color navBarUnselected   = Color(0xFF9E9E9E);

  // ── Dropdown / Selector ───────────────────────────────
  static const Color dropdownFill        = Color(0xFFF5F5F5);
  static const Color dropdownSelected    = electricBlue;
  static const Color dropdownSelectedBg  = Color(0x1A0077FF); // blue 10%
  static const Color dropdownUnselected  = Color(0xFFF5F5F5);

  // ── Step Indicator (vehicle screen) ──────────────────
  static const Color stepActive          = electricBlue;
  static const Color stepDone           = emeraldGreen;
  static const Color stepInactive        = Color(0xFFDDDDDD);

  // ── Divider ───────────────────────────────────────────
  static const Color divider            = Color(0xFFEEEEEE);

  // ── Shimmer / Loading ─────────────────────────────────
  static const Color shimmerBase        = Color(0xFFE0E0E0);
  static const Color shimmerHighlight   = Color(0xFFF5F5F5);

  // ── OTP Box ───────────────────────────────────────────
  static const Color otpBoxFill         = Color(0xFFF5F5F5);
  static const Color otpBoxFocused      = electricBlue;
  static const Color otpBoxBorderFocused = electricBlue;

  // ── Language Selection ────────────────────────────────
  static const Color langSelectedBorder  = electricBlue;
  static const Color langSelectedBg     = Color(0x1A0077FF); // blue 10%
  static const Color langUnselectedBg   = Color(0xFFF5F5F5);

  // ── Home Screen stats card ───────────────────────────
  static const Color statCardBg         = Colors.white;

  // ── Shadow ───────────────────────────────────────────
  static Color shadowColor              = Colors.black.withOpacity(0.08);
  static Color gradientShadow           = electricBlue.withOpacity(0.30);
}
