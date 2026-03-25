import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finme/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle display = GoogleFonts.inter(
    fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static TextStyle heading = GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static TextStyle body = GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
  );
}
