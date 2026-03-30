import 'package:flutter/material.dart';

// ─── Beanstalk Brand Colors ────────────────────────────────────
class AppColors {
  // Primary greens
  static const Color primary        = Color(0xFF1B8C4E); // Beanstalk green
  static const Color primaryDark    = Color(0xFF146038); // Deep green
  static const Color primaryLight   = Color(0xFF4CAF7D); // Light green
  static const Color accent         = Color(0xFFF5C842); // Gold/coin accent

  // Backgrounds
  static const Color background     = Color(0xFFF7FBF8); // Near-white green tint
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceAlt     = Color(0xFFEDF7F0); // Soft green surface

  // Text
  static const Color textPrimary    = Color(0xFF1A2E24); // Dark green-black
  static const Color textSecondary  = Color(0xFF5A7A68); // Muted green-grey
  static const Color textHint       = Color(0xFF9AB8A5);

  // Semantic
  static const Color success        = Color(0xFF2ECC71);
  static const Color warning        = Color(0xFFF39C12);
  static const Color error          = Color(0xFFE74C3C);
  static const Color info           = Color(0xFF3498DB);

  // Quiz / gamification
  static const Color correct        = Color(0xFF27AE60);
  static const Color incorrect      = Color(0xFFE74C3C);
  static const Color xpGold         = Color(0xFFF5C842);
  static const Color streakOrange   = Color(0xFFFF6B35);
}

// ─── Typography ───────────────────────────────────────────────
class AppFont {
  static const String primaryFont   = 'Gilmer';
  static const String secondaryFont = 'Matterdi';
}

class AppFontScales {
  static const double lowerScale    = 1.3;
  static const double upperScale    = 0.85;
}

// ─── App Theme ────────────────────────────────────────────────
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    fontFamily: AppFont.secondaryFont,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
