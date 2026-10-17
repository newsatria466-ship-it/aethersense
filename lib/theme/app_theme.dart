import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens extracted from the official Smart City Tegal logo
class AppColors {
  // Brand colors from official logo
  static const Color cyan = Color(0xFF28A9DC); // Primary Tech Cyan
  static const Color cyanBlue = cyan;
  static const Color green = Color(0xFF00A859); // Ecological Green
  static const Color ecoGreen = green;
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Background and Surfaces
  static const Color background = Color(0xFFF5F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8EEF2);
  static const Color divider = Color(0xFFE8EEF2);

  // Typography
  static const Color textPrimary = Color(0xFF172B3A);
  static const Color textSecondary = Color(0xFF748391);
  static const Color textMuted = Color(0xFFA0AEC0);

  // Semantics
  static const Color safe = Color(0xFF00A859);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color critical = danger;

  // Dark Theme support
  static const Color backgroundDark = Color(0xFF0B131B);
  static const Color surfaceDark = Color(0xFF141F2B);
  static const Color borderDark = Color(0xFF223142);
  static const Color textPrimaryDark = Color(0xFFF7FAFC);
  static const Color textSecondaryDark = Color(0xFFA0AEC0);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [cyan, green],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppRadii {
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 18.0;
  static const double xl = 24.0;
  static const double card = 20.0;
  static const double pill = 999.0;
}

class AppSpacings {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double m = 16.0;
  static const double lg = 16.0;
  static const double l = 20.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
}

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get h2 => GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyBold => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.cyan,
        secondary: AppColors.green,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: base,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyan,
        secondary: AppColors.green,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
      ),
      textTheme: base,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: const BorderSide(color: AppColors.borderDark),
        ),
      ),
    );
  }
}
