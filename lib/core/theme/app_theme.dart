import 'package:flutter/material.dart';
import 'vault_theme.dart';

/// Legacy AppTheme shim that delegates to VaultTheme
class AppTheme {
  static const String fontFamily = VaultTheme.fontFamily;

  // Semantic Financial Colors
  static Color incomeColor(BuildContext context) => VaultTheme.positive(context);
  static Color expenseColor(BuildContext context) => VaultTheme.negative(context);
  static Color transferColor(BuildContext context) => VaultTheme.accent(context);
  static Color subtleTextColor(BuildContext context) => VaultTheme.secondaryText(context);

  static ThemeData get lightTheme => VaultTheme.lightTheme;
  static ThemeData get darkTheme => VaultTheme.darkTheme;
}
