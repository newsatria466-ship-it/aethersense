import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for "Urban Eco-Tech" Smart City Tegal Identity
class AppColors {
  // Brand Primary & Accent
  static const Color cyanBlue = Color(0xFF28A9DC); // Primary Urban Tech Cyan
  static const Color ecoGreen = Color(0xFF00A859); // Primary Ecological Green
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Friendly Brand Aliases
  static const Color cyan = cyanBlue;
  static const Color green = ecoGreen;
  static const Color danger = critical;
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color border = borderLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;

  // Light Theme Palette (Default)
  static const Color backgroundLight = Color(0xFFF3F8FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE4EDF2);
  static const Color dividerLight = Color(0xFFEEF4F7);
  static const Color textPrimaryLight = Color(0xFF172B3A);
  static const Color textSecondaryLight = Color(0xFF718096);
  static const Color textMutedLight = Color(0xFFA0AEC0);

  // Dark Theme Palette
  static const Color backgroundDark = Color(0xFF0B131B);
  static const Color surfaceDark = Color(0xFF141F2B);
  static const Color cardDark = Color(0xFF141F2B);
  static const Color borderDark = Color(0xFF223142);
  static const Color dividerDark = Color(0xFF1C2A39);
  static const Color textPrimaryDark = Color(0xFFF7FAFC);
  static const Color textSecondaryDark = Color(0xFFA0AEC0);
  static const Color textMutedDark = Color(0xFF718096);

  // Status & Safety Semantics
  static const Color safe = Color(0xFF00A859);
  static const Color safeBgLight = Color(0xFFE8F7F0);
  static const Color safeBgDark = Color(0x2500A859);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBgLight = Color(0xFFFFFBEB);
  static const Color warningBgDark = Color(0x25F59E0B);

  static const Color critical = Color(0xFFEF4444);
  static const Color criticalBgLight = Color(0xFFFEF2F2);
  static const Color criticalBgDark = Color(0x25EF4444);

  static const Color info = Color(0xFF28A9DC);
  static const Color infoBgLight = Color(0xFFE9F6FC);
  static const Color infoBgDark = Color(0x2528A9DC);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [cyanBlue, ecoGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softCyanGradient = LinearGradient(
    colors: [Color(0xFFE8F6FC), Color(0xFFF3F8FB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppRadii {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double card = 16.0;
  static const double pill = 999.0;

  static final BorderRadius rSm = BorderRadius.circular(sm);
  static final BorderRadius rMd = BorderRadius.circular(md);
  static final BorderRadius rLg = BorderRadius.circular(lg);
  static final BorderRadius rXl = BorderRadius.circular(xl);
  static final BorderRadius rCard = BorderRadius.circular(card);
  static final BorderRadius rPill = BorderRadius.circular(pill);
}

class AppSpacings {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double s = sm;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double m = lg;
  static const double xl = 20.0;
  static const double l = xl;
  static const double xxl = 24.0;
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration splash = Duration(milliseconds: 950);
}

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimaryLight,
  );

  static TextStyle get h2 => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimaryLight,
  );

  static TextStyle get bodyBold => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryLight,
  );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryLight,
  );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondaryLight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.cyanBlue,
        secondary: AppColors.ecoGreen,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.critical,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textMutedLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLg,
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      dividerColor: AppColors.dividerLight,
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyanBlue,
        secondary: AppColors.ecoGreen,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.critical,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondaryDark,
          fontWeight: FontWeight.w500,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: AppColors.textMutedDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.rLg,
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      dividerColor: AppColors.dividerDark,
    );
  }
}
