import 'package:flutter/material.dart';

class QuickServeColors {
  // Primary Orange Brand Identity
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color primaryOrangeDark = Color(0xFFE64A19);
  static const Color primaryOrangeLight = Color(0xFFFFF3E0);
  static const Color primaryOrangeBorder = Color(0xFFFFCCBC);

  // Dark Foundations (for Splash & Admin Web Sidebar)
  static const Color darkBg = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color adminSidebar = Color(0xFF0F172A);
  static const Color adminSidebarActive = Color(0xFF1E293B);

  // White Mobile Surfaces
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceSecondary = Color(0xFFF3F4F6);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderSubtle = Color(0xFFF0F0F0);
  static const Color inputBg = Color(0xFFF9FAFB);

  // Status & Actions
  static const Color statusGreen = Color(0xFF00C853);
  static const Color statusGreenLight = Color(0xFFE8F5E9);
  static const Color statusRed = Color(0xFFEF4444);
  static const Color statusRedLight = Color(0xFFFFEBEE);
  static const Color statusAmber = Color(0xFFF59E0B);
  static const Color statusAmberLight = Color(0xFFFFFBEB);
  static const Color routeBlue = Color(0xFF2563EB);

  // Typography
  static const Color textDark = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);
}

// Backward-compatibility alias so existing screens work seamlessly while adopting QuickServe's palette
class GoRushColors {
  static const Color background = QuickServeColors.white;
  static const Color surface = QuickServeColors.white;
  static const Color surfaceCard = QuickServeColors.white;
  static const Color surfaceElevated = QuickServeColors.surfaceLight;
  static const Color surfaceBorder = QuickServeColors.borderLight;
  static const Color surfaceInput = QuickServeColors.inputBg;

  static const Color primaryGreen = QuickServeColors.primaryOrange;
  static const Color accentGreen = QuickServeColors.statusGreen;
  static const Color darkGreen = QuickServeColors.statusGreen;
  static const Color greenTint = QuickServeColors.primaryOrangeLight;
  static const Color greenBorder = QuickServeColors.primaryOrangeBorder;

  static const Color gold = QuickServeColors.statusAmber;
  static const Color goldDark = Color(0xFFD97706);
  static const Color goldTint = QuickServeColors.statusAmberLight;

  static const Color sosRed = QuickServeColors.statusRed;
  static const Color sosRedDark = Color(0xFFDC2626);
  static const Color sosRedTint = QuickServeColors.statusRedLight;

  static const Color blueAccent = QuickServeColors.routeBlue;
  static const Color blueDark = Color(0xFF1D4ED8);
  static const Color blueTint = Color(0x152563EB);

  static const Color orangeAccent = QuickServeColors.primaryOrange;
  static const Color orangeTint = QuickServeColors.primaryOrangeLight;

  static const Color textWhite = QuickServeColors.textDark;
  static const Color textPrimary = QuickServeColors.textDark;
  static const Color textSecondary = QuickServeColors.textSecondary;
  static const Color textMuted = QuickServeColors.textMuted;
  static const Color textOnPrimary = QuickServeColors.textWhite;
}

class QuickServeTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: QuickServeColors.surfaceLight,
      colorScheme: const ColorScheme.light(
        primary: QuickServeColors.primaryOrange,
        secondary: QuickServeColors.statusGreen,
        surface: QuickServeColors.white,
        error: QuickServeColors.statusRed,
      ),
      cardTheme: CardThemeData(
        color: QuickServeColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: QuickServeColors.borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: QuickServeColors.primaryOrange,
          foregroundColor: QuickServeColors.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: QuickServeColors.textDark,
          side: const BorderSide(color: QuickServeColors.borderLight, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: QuickServeColors.inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: QuickServeColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: QuickServeColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: QuickServeColors.primaryOrange, width: 1.5),
        ),
      ),
    );
  }
}

class GoRushTheme {
  static ThemeData get darkTheme => QuickServeTheme.lightTheme;
}
