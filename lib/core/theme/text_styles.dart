import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme get textTheme {
    return TextTheme(
      // ═══════════════════════════════════════════════════════════════
      // TITLES (Manrope - Technical yet humanistic)
      // ═══════════════════════════════════════════════════════════════
      titleLarge: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.onSurface,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: AppColors.onSurface,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: AppColors.onSurface,
      ),

      // ═══════════════════════════════════════════════════════════════
      // BODY COPY (Public Sans - Clean, neutral)
      // ═══════════════════════════════════════════════════════════════
      bodyLarge: GoogleFonts.publicSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
        color: AppColors.onSurface,
      ),
      bodyMedium: GoogleFonts.publicSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
        color: AppColors.onSurface,
      ),
      bodySmall: GoogleFonts.publicSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.5,
        color: AppColors.onSurfaceVariant,
      ),

      // ═══════════════════════════════════════════════════════════════
      // LABELS (Inter - Utility)
      // ═══════════════════════════════════════════════════════════════
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.onSurfaceVariant,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}
