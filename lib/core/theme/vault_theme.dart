import 'package:flutter/material.dart';
import 'app_theme_colors.dart';

/// VAULT Design System — Quiet Luxury Theme Engine
///
/// Features:
/// - Single accent: Warm Amber (#C99A52 in Dark, #A9782E in Light)
/// - Midnight Slate (#111315) & Warm Ivory (#F7F4EE)
/// - Tabular Figures for aligned financial figures
/// - Hairline dividers (0.75px) without heavy drop-shadows
/// - Clean card radius 16px, control radius 12px
class VaultTheme {
  static const String fontFamily = 'Noto Sans Thai';

  // --- Dark Mode (Midnight Slate) ---
  static const Color darkBackground = Color(0xFF111315);
  static const Color darkSurface = Color(0xFF1A1E21);
  static const Color darkSurfaceSubtle = Color(0xFF22272B);
  static const Color darkPrimaryText = Color(0xFFF3F0E9);
  static const Color darkSecondaryText = Color(0xFFD2D5D0);
  static const Color darkMutedText = Color(0xFF9EA39D);
  static const Color darkAccent = Color(0xFFC99A52); // Warm Amber
  static const Color darkAccentLight = Color(0xFFDAB274);
  static const Color darkPositive = Color(0xFF6CA68A); // Muted Sage
  static const Color darkNegative = Color(0xFFD27A72); // Muted Rose
  static const Color darkBorder = Color(0xFF262A2E);

  // --- Light Mode (Warm Ivory) ---
  static const Color lightBackground = Color(0xFFF7F4EE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFEFEBE3);
  static const Color lightPrimaryText = Color(0xFF181816);
  static const Color lightSecondaryText = Color(0xFF555752);
  static const Color lightMutedText = Color(0xFF6E706B);
  static const Color lightAccent = Color(0xFFA9782E); // Warm Amber Deep
  static const Color lightAccentLight = Color(0xFFC99A52);
  static const Color lightPositive = Color(0xFF3D8063);
  static const Color lightNegative = Color(0xFFB9524B);
  static const Color lightBorder = Color(0xFFE5E0D6);

  // --- Tabular Number Font Style Generator ---
  static TextStyle tabular({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  // --- Context Helpers (Supports both VAULT and Lumi themes via ThemeExtension) ---
  static AppThemeColors? extension(BuildContext context) =>
      Theme.of(context).extension<AppThemeColors>();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static bool isLumi(BuildContext context) =>
      extension(context)?.isLumi ?? false;

  static Color background(BuildContext context) =>
      extension(context)?.background ?? (isDark(context) ? darkBackground : lightBackground);

  static Color surface(BuildContext context) =>
      extension(context)?.surface ?? (isDark(context) ? darkSurface : lightSurface);

  static Color surfaceSubtle(BuildContext context) =>
      extension(context)?.surfaceSubtle ?? (isDark(context) ? darkSurfaceSubtle : lightSurfaceSubtle);

  static Color primaryText(BuildContext context) =>
      extension(context)?.primaryText ?? (isDark(context) ? darkPrimaryText : lightPrimaryText);

  static Color secondaryText(BuildContext context) =>
      extension(context)?.secondaryText ?? (isDark(context) ? darkSecondaryText : lightSecondaryText);

  static Color mutedText(BuildContext context) =>
      extension(context)?.mutedText ?? (isDark(context) ? darkMutedText : lightMutedText);

  static Color accent(BuildContext context) =>
      extension(context)?.accent ?? (isDark(context) ? darkAccent : lightAccent);

  static Color positive(BuildContext context) =>
      extension(context)?.positive ?? (isDark(context) ? darkPositive : lightPositive);

  static Color negative(BuildContext context) =>
      extension(context)?.negative ?? (isDark(context) ? darkNegative : lightNegative);

  static Color border(BuildContext context) =>
      extension(context)?.border ?? (isDark(context) ? darkBorder : lightBorder);

  static Color surfacePeach(BuildContext context) =>
      extension(context)?.surfacePeach ?? surfaceSubtle(context);

  static Color surfaceBlue(BuildContext context) =>
      extension(context)?.surfaceBlue ?? surfaceSubtle(context);

  static Color surfaceMint(BuildContext context) =>
      extension(context)?.surfaceMint ?? surfaceSubtle(context);

  static Color surfaceLavender(BuildContext context) =>
      extension(context)?.surfaceLavender ?? surfaceSubtle(context);

  static Color surfacePink(BuildContext context) =>
      extension(context)?.surfacePink ?? surfaceSubtle(context);

  static double cardRadius(BuildContext context) =>
      extension(context)?.cardRadius ?? (isLumi(context) ? 24.0 : 16.0);

  // --- Backward Compatibility for semantic methods ---
  static Color incomeColor(BuildContext context) => positive(context);
  static Color expenseColor(BuildContext context) => negative(context);
  static Color transferColor(BuildContext context) => accent(context);
  static Color subtleTextColor(BuildContext context) => secondaryText(context);

  // --- Dark Theme Definition (Midnight Slate) ---
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: darkAccent,
      onPrimary: Color(0xFF111315),
      primaryContainer: darkSurfaceSubtle,
      onPrimaryContainer: darkAccentLight,
      secondary: darkAccent,
      onSecondary: Color(0xFF111315),
      secondaryContainer: darkSurfaceSubtle,
      onSecondaryContainer: darkPrimaryText,
      surface: darkSurface,
      onSurface: darkPrimaryText,
      surfaceContainer: darkSurface,
      surfaceContainerLow: darkBackground,
      surfaceContainerHigh: darkSurfaceSubtle,
      surfaceContainerHighest: Color(0xFF2E343A),
      onSurfaceVariant: darkSecondaryText,
      outline: darkBorder,
      outlineVariant: Color(0xFF1F2327),
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
          fontWeight: FontWeight.w600,
          color: darkPrimaryText,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkSurface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 0.75),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 0.75,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: darkBorder, width: 0.75),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkAccent,
        foregroundColor: Color(0xFF111315),
        elevation: 2,
      ),
      extensions: const [
        AppThemeColors(
          isLumi: false,
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
          cardRadius: 16.0,
          controlRadius: 12.0,
          masterBudgetGradient: null,
          primaryButtonGradient: null,
          cardShadowColor: null,
          badgeBackgroundPositive: Color(0xFF1E2822),
          badgeBackgroundNegative: Color(0xFF2E1F1E),
        ),
      ],
    );
  }

  // --- Light Theme Definition (Warm Ivory) ---
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: lightAccent,
      onPrimary: Colors.white,
      primaryContainer: lightSurfaceSubtle,
      onPrimaryContainer: lightAccent,
      secondary: lightAccent,
      onSecondary: Colors.white,
      secondaryContainer: lightSurfaceSubtle,
      onSecondaryContainer: lightPrimaryText,
      surface: lightSurface,
      onSurface: lightPrimaryText,
      surfaceContainer: lightSurface,
      surfaceContainerLow: lightBackground,
      surfaceContainerHigh: lightSurfaceSubtle,
      surfaceContainerHighest: Color(0xFFE2DDD3),
      onSurfaceVariant: lightSecondaryText,
      outline: lightBorder,
      outlineVariant: Color(0xFFECE7DE),
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
          fontWeight: FontWeight.w600,
          color: lightPrimaryText,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: lightSurface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 0.75),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 0.75,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: lightBorder, width: 0.75),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightAccent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      extensions: const [
        AppThemeColors(
          isLumi: false,
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
          cardRadius: 16.0,
          controlRadius: 12.0,
          masterBudgetGradient: null,
          primaryButtonGradient: null,
          cardShadowColor: null,
          badgeBackgroundPositive: Color(0xFFE8F2EC),
          badgeBackgroundNegative: Color(0xFFF9EAE9),
        ),
      ],
    );
  }
}
