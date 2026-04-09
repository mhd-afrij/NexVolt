import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme textTheme = GoogleFonts.poppinsTextTheme().copyWith(
    bodyLarge: GoogleFonts.poppins(color: AppColors.textPrimary),
    bodyMedium: GoogleFonts.poppins(color: AppColors.textSecondary),
    bodySmall: GoogleFonts.poppins(color: AppColors.textSecondary),
    titleLarge: GoogleFonts.poppins(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    ),
    displayLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
    displayMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
    headlineLarge: GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.playfairDisplay(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.playfairDisplay(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );
}
