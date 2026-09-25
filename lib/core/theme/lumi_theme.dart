import 'package:flutter/material.dart';
import 'app_theme_colors.dart';

/// Lumi Design System — Sunny Bloom Theme Engine
///
/// Inspired by cozy anime aesthetics and pastel palettes:
/// - Primary Accent: Bubblegum Rose / Coral Pink (#FF5C9D)
/// - Soft Pastels: Peach Pink (#FFE5F2), Warm Cream (#FFF7D6), Mint (#D5F7C4), Sky (#BFE9FF)
/// - Card radius: 22px, Button radius: 24px (Capsule/Pill shaped)
/// - Friendly, supportive, cozy mood
class LumiTheme {
  static const String fontFamily = 'Noto Sans Thai';

  // --- Pastel Palette from Design System ---
  static const Color pastelPink = Color(0xFFFFF0F5);
  static const Color pastelYellow = Color(0xFFFFF7D6);
  static const Color pastelSky = Color(0xFFEEF8FF);
  static const Color pastelMint = Color(0xFFF0FAF2);
  static const Color pastelPeach = Color(0xFFFFF4E3);
  static const Color pastelLavender = Color(0xFFF5F1FF);
  static const Color vibrantRose = Color(0xFFFF5B9A);

  // --- Light Mode (Sunny Bloom) ---
  static const Color lightBackground = Color(0xFFFFF9F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFFFF4E3);
  static const Color lightPrimaryText = Color(0xFF332B32);
  static const Color lightSecondaryText = Color(0xFF66575E);
  static const Color lightMutedText = Color(0xFF72636C);
  static const Color lightAccent = Color(0xFFFF5B9A);
  static const Color lightAccentLight = Color(0xFFFFA4C8);
  static const Color lightPositive = Color(0xFF2E8B57); // SeaGreen / Sage
  static const Color lightNegative = Color(0xFFE64A63); // Coral Rose
  static const Color lightBorder = Color(0xFFF3DCE5);

  // --- Dark Mode (Twilight Bloom) ---
  static const Color darkBackground = Color(0xFF120E18);
  static const Color darkSurface = Color(0xFF1B1522);
  static const Color darkSurfaceSubtle = Color(0xFF251C30);
  static const Color darkPrimaryText = Color(0xFFFFF5F8);
  static const Color darkSecondaryText = Color(0xFFD8CEE0);
  static const Color darkMutedText = Color(0xFFBDB2C4);
  static const Color darkAccent = Color(0xFFFF75A9);
  static const Color darkAccentLight = Color(0xFFFFA8C8);
  static const Color darkPositive = Color(0xFF5ABF80);
  static const Color darkNegative = Color(0xFFFF6E82);
  static const Color darkBorder = Color(0xFF32253F);

  // --- Light Theme Definition ---
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightAccent,
      onPrimary: Colors.white,
      primaryContainer: pastelPink,
      onPrimaryContainer: Color(0xFF801444),
      secondary: Color(0xFFFF8AB5),
      onSecondary: Colors.white,
      secondaryContainer: pastelYellow,
      onSecondaryContainer: Color(0xFF573E00),
      surface: lightSurface,
      onSurface: lightPrimaryText,
      surfaceContainer: lightSurface,
      surfaceContainerLow: lightBackground,
      surfaceContainerHigh: lightSurfaceSubtle,
      surfaceContainerHighest: Color(0xFFF6EDE4),
      onSurfaceVariant: lightSecondaryText,
      outline: lightBorder,
      outlineVariant: Color(0xFFFAF2EB),
      error: lightNegative,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: lightPrimaryText,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: lightPrimaryText,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: lightSurface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: lightBorder, width: 1.0),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lightAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightAccent,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightAccent,
          side: const BorderSide(color: lightAccent, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 4,
        dismissDirection: DismissDirection.horizontal,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightAccent,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightAccent, width: 1.5),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: lightAccent,
        labelColor: lightAccent,
        unselectedLabelColor: lightSecondaryText,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontFamily: fontFamily),
      ),
      extensions: const [
        AppThemeColors(
          isLumi: true,
          accent: lightAccent,
          accentLight: lightAccentLight,
          positive: lightPositive,
          negative: lightNegative,
          border: lightBorder,
          background: lightBackground,
          surface: lightSurface,
          surfaceSubtle: lightSurfaceSubtle,
          primaryText: lightPrimaryText,
          secondaryText: lightSecondaryText,
          mutedText: lightMutedText,
          cardRadius: 24.0,
          controlRadius: 24.0,
          masterBudgetGradient: LinearGradient(
            colors: [Color(0xFFFFF0F5), Color(0xFFFFF7D6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          primaryButtonGradient: LinearGradient(
            colors: [Color(0xFFFF5B9A), Color(0xFFFF7EAE)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          cardShadowColor: Color(0x14FF5B9A),
          badgeBackgroundPositive: Color(0xFFE8F5EE),
          badgeBackgroundNegative: Color(0xFFFFECF0),
          surfacePeach: Color(0xFFFFF4E3),
          surfaceBlue: Color(0xFFEEF8FF),
          surfaceMint: Color(0xFFF0FAF2),
          surfaceLavender: Color(0xFFF5F1FF),
          surfacePink: Color(0xFFFFF0F5),
        ),
      ],
    );
  }

  // --- Dark Theme Definition ---
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: darkAccent,
      onPrimary: Color(0xFF120E18),
      primaryContainer: Color(0xFF3F192B),
      onPrimaryContainer: Color(0xFFFFB3D0),
      secondary: darkAccentLight,
      onSecondary: Color(0xFF120E18),
      secondaryContainer: Color(0xFF382A18),
      onSecondaryContainer: Color(0xFFFFE5A3),
      surface: darkSurface,
      onSurface: darkPrimaryText,
      surfaceContainer: darkSurface,
      surfaceContainerLow: darkBackground,
      surfaceContainerHigh: darkSurfaceSubtle,
      surfaceContainerHighest: Color(0xFF2E223B),
      onSurfaceVariant: darkSecondaryText,
      outline: darkBorder,
      outlineVariant: Color(0xFF22192C),
      error: darkNegative,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: darkPrimaryText,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkPrimaryText,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: darkBorder, width: 0.75),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        elevation: 4,
        dismissDirection: DismissDirection.horizontal,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkAccent,
        foregroundColor: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkAccent, width: 1.5),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: darkAccent,
        labelColor: darkAccent,
        unselectedLabelColor: darkSecondaryText,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontFamily: fontFamily),
      ),
      extensions: const [
        AppThemeColors(
          isLumi: true,
          accent: darkAccent,
          accentLight: darkAccentLight,
          positive: darkPositive,
          negative: darkNegative,
          border: darkBorder,
          background: darkBackground,
          surface: darkSurface,
          surfaceSubtle: darkSurfaceSubtle,
          primaryText: darkPrimaryText,
          secondaryText: darkSecondaryText,
          mutedText: darkMutedText,
          cardRadius: 22.0,
          controlRadius: 24.0,
          masterBudgetGradient: LinearGradient(
            colors: [Color(0xFF381F30), Color(0xFF3B2F1F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          primaryButtonGradient: LinearGradient(
            colors: [Color(0xFFFF75A9), Color(0xFFFF94BC)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          cardShadowColor: Color(0x0CFF75A9),
          badgeBackgroundPositive: Color(0xFF1E3526),
          badgeBackgroundNegative: Color(0xFF3C1F25),
        ),
      ],
    );
  }
}
