import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finme/core/theme/app_colors.dart';
import 'package:finme/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AppTheme', () {
    test('dark theme uses correct background color', () {
      late ThemeData theme;
      runZonedGuarded(() {
        theme = AppTheme.dark();
      }, (error, stack) {
        // Expected: GoogleFonts cannot load fonts in test environment
      });
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });

    test('background color is near-black', () {
      expect(AppColors.background, const Color(0xFF0D0D0F));
    });

    test('primary accent is electric indigo', () {
      expect(AppColors.primary, const Color(0xFF7C6EFA));
    });
  });
}
