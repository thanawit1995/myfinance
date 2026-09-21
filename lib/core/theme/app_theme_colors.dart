import 'package:flutter/material.dart';

/// Semantic colors and stylistic properties passed down via ThemeExtension.
/// This allows all UI components to adapt dynamically between VAULT and Lumi themes.
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final bool isLumi;
  final Color accent;
  final Color accentLight;
  final Color positive;
  final Color negative;
  final Color border;
  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color primaryText;
  final Color secondaryText;
  final Color mutedText;
  final double cardRadius;
  final double controlRadius;
  final Gradient? masterBudgetGradient;
  final Gradient? primaryButtonGradient;
  final Color? cardShadowColor;
  final Color badgeBackgroundPositive;
  final Color badgeBackgroundNegative;
  final Color surfacePeach;
  final Color surfaceBlue;
  final Color surfaceMint;
  final Color surfaceLavender;
  final Color surfacePink;

  const AppThemeColors({
    required this.isLumi,
    required this.accent,
    required this.accentLight,
    required this.positive,
    required this.negative,
    required this.border,
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.primaryText,
    required this.secondaryText,
    required this.mutedText,
    required this.cardRadius,
    required this.controlRadius,
    this.masterBudgetGradient,
    this.primaryButtonGradient,
    this.cardShadowColor,
    required this.badgeBackgroundPositive,
    required this.badgeBackgroundNegative,
    this.surfacePeach = const Color(0xFFFFF4E3),
    this.surfaceBlue = const Color(0xFFEEF8FF),
    this.surfaceMint = const Color(0xFFF0FAF2),
    this.surfaceLavender = const Color(0xFFF5F1FF),
    this.surfacePink = const Color(0xFFFFF0F5),
  });

  @override
  AppThemeColors copyWith({
    bool? isLumi,
    Color? accent,
    Color? accentLight,
    Color? positive,
    Color? negative,
    Color? border,
    Color? background,
    Color? surface,
    Color? surfaceSubtle,
    Color? primaryText,
    Color? secondaryText,
    Color? mutedText,
    double? cardRadius,
    double? controlRadius,
    Gradient? masterBudgetGradient,
    Gradient? primaryButtonGradient,
    Color? cardShadowColor,
    Color? badgeBackgroundPositive,
    Color? badgeBackgroundNegative,
    Color? surfacePeach,
    Color? surfaceBlue,
    Color? surfaceMint,
    Color? surfaceLavender,
    Color? surfacePink,
  }) {
    return AppThemeColors(
      isLumi: isLumi ?? this.isLumi,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      border: border ?? this.border,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      mutedText: mutedText ?? this.mutedText,
      cardRadius: cardRadius ?? this.cardRadius,
      controlRadius: controlRadius ?? this.controlRadius,
      masterBudgetGradient: masterBudgetGradient ?? this.masterBudgetGradient,
      primaryButtonGradient: primaryButtonGradient ?? this.primaryButtonGradient,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
      badgeBackgroundPositive: badgeBackgroundPositive ?? this.badgeBackgroundPositive,
      badgeBackgroundNegative: badgeBackgroundNegative ?? this.badgeBackgroundNegative,
      surfacePeach: surfacePeach ?? this.surfacePeach,
      surfaceBlue: surfaceBlue ?? this.surfaceBlue,
      surfaceMint: surfaceMint ?? this.surfaceMint,
      surfaceLavender: surfaceLavender ?? this.surfaceLavender,
      surfacePink: surfacePink ?? this.surfacePink,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      isLumi: t < 0.5 ? isLumi : other.isLumi,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentLight: Color.lerp(accentLight, other.accentLight, t) ?? accentLight,
      positive: Color.lerp(positive, other.positive, t) ?? positive,
      negative: Color.lerp(negative, other.negative, t) ?? negative,
      border: Color.lerp(border, other.border, t) ?? border,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t) ?? surfaceSubtle,
      primaryText: Color.lerp(primaryText, other.primaryText, t) ?? primaryText,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t) ?? secondaryText,
      mutedText: Color.lerp(mutedText, other.mutedText, t) ?? mutedText,
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
      controlRadius: controlRadius + (other.controlRadius - controlRadius) * t,
      masterBudgetGradient: t < 0.5 ? masterBudgetGradient : other.masterBudgetGradient,
      primaryButtonGradient: t < 0.5 ? primaryButtonGradient : other.primaryButtonGradient,
      cardShadowColor: Color.lerp(cardShadowColor, other.cardShadowColor, t),
      badgeBackgroundPositive: Color.lerp(badgeBackgroundPositive, other.badgeBackgroundPositive, t) ?? badgeBackgroundPositive,
      badgeBackgroundNegative: Color.lerp(badgeBackgroundNegative, other.badgeBackgroundNegative, t) ?? badgeBackgroundNegative,
      surfacePeach: Color.lerp(surfacePeach, other.surfacePeach, t) ?? surfacePeach,
      surfaceBlue: Color.lerp(surfaceBlue, other.surfaceBlue, t) ?? surfaceBlue,
      surfaceMint: Color.lerp(surfaceMint, other.surfaceMint, t) ?? surfaceMint,
      surfaceLavender: Color.lerp(surfaceLavender, other.surfaceLavender, t) ?? surfaceLavender,
      surfacePink: Color.lerp(surfacePink, other.surfacePink, t) ?? surfacePink,
    );
  }
}
