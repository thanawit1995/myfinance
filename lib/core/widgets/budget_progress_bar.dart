import 'package:flutter/material.dart';
import '../theme/vault_theme.dart';

/// Reusable Budget Progress Bar with Trailing Percentage Badge
///
/// Highlights budget consumption with high contrast, smooth rounded corners,
/// and an explicit trailing percentage badge that remains readable in all states
/// (normal, warning >= 80%, exceeded >= 100%).
class BudgetProgressBar extends StatelessWidget {
  final int spentSatang;
  final int limitSatang;
  final double height;
  final Color? customColor;
  final bool showTrailingBadge;
  final double badgeFontSize;
  final EdgeInsetsGeometry? padding;

  const BudgetProgressBar({
    super.key,
    required this.spentSatang,
    required this.limitSatang,
    this.height = 10.0,
    this.customColor,
    this.showTrailingBadge = true,
    this.badgeFontSize = 11.5,
    this.padding,
  });

  int get percent {
    if (limitSatang <= 0) return 0;
    return ((spentSatang / limitSatang) * 100).round();
  }

  double get ratio {
    if (limitSatang <= 0) return 0.0;
    return (spentSatang / limitSatang).clamp(0.0, 1.0);
  }

  bool get isExceeded => limitSatang > 0 && spentSatang > limitSatang;
  bool get isWarning => limitSatang > 0 && !isExceeded && percent >= 80;

  Color resolveProgressColor(BuildContext context) {
    if (customColor != null) return customColor!;
    final isLumi = VaultTheme.isLumi(context);
    final isDark = VaultTheme.isDark(context);

    if (isExceeded) {
      return VaultTheme.negative(context);
    } else if (isWarning) {
      return isDark ? const Color(0xFFFBBF24) : Colors.orange.shade700;
    } else if (isLumi) {
      return const Color(0xFFFF5C9D);
    } else {
      return isDark ? const Color(0xFF6CA68A) : Colors.green.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = VaultTheme.isDark(context);
    final progressColor = resolveProgressColor(context);

    final barWidget = Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: ratio,
            heightFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
        ),
      ),
    );

    final badgeWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: progressColor.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: progressColor.withValues(alpha: isDark ? 0.45 : 0.28),
          width: 0.8,
        ),
      ),
      child: Text(
        '$percent%',
        style: VaultTheme.tabular(
          fontSize: badgeFontSize,
          fontWeight: FontWeight.w800,
          color: progressColor,
        ),
      ),
    );

    Widget content;
    if (showTrailingBadge) {
      content = Row(
        children: [
          Expanded(child: barWidget),
          const SizedBox(width: 8),
          badgeWidget,
        ],
      );
    } else {
      content = barWidget;
    }

    if (padding != null) {
      return Padding(padding: padding!, child: content);
    }
    return content;
  }
}
