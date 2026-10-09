import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/money/money.dart';
import '../../../../../core/theme/vault_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import 'lumi_mascot_avatar.dart';

class BudgetHeroCard extends ConsumerWidget {
  final int remainingSatang;
  final int totalBudgetSatang;
  final int totalExpenseSatang;
  final VoidCallback onTap;

  const BudgetHeroCard({
    super.key,
    required this.remainingSatang,
    required this.totalBudgetSatang,
    required this.totalExpenseSatang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hasBudget = totalBudgetSatang > 0;

    final percentUsed = hasBudget
        ? ((totalExpenseSatang / totalBudgetSatang) * 100).clamp(0, 100).toInt()
        : 0;

    final percentRemaining = hasBudget
        ? ((remainingSatang / totalBudgetSatang) * 100).clamp(0, 100).toInt()
        : 100;

    final isOverBudget = hasBudget && (remainingSatang < 0 || totalExpenseSatang > totalBudgetSatang);
    final isWarning = hasBudget && !isOverBudget && percentRemaining <= 20;

    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String defaultMascotAsset;
    if (isOverBudget) {
      defaultMascotAsset = isDark
          ? 'assets/images/lumi_mascot_shock_dark.png'
          : 'assets/images/lumi_mascot_shock.png';
    } else if (isWarning) {
      defaultMascotAsset = isDark
          ? 'assets/images/lumi_mascot_warning_dark.png'
          : 'assets/images/lumi_mascot_warning.png';
    } else {
      defaultMascotAsset = isDark
          ? 'assets/images/lumi_mascot_smile_dark.png'
          : 'assets/images/lumi_mascot_smile.png';
    }

    final progressRatio = hasBudget
        ? (totalExpenseSatang / totalBudgetSatang).clamp(0.0, 1.0)
        : 0.0;

    final customBgData = ref.watch(customCardBgProvider);
    final hasCustomBg = customBgData != null && customBgData.isNotEmpty;

    return Semantics(
      button: true,
      label: isThai ? 'งบประมาณคงเหลือ' : 'Remaining Budget',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: (isOverBudget || isWarning)
                  ? const Color(0xFFFF6E82).withValues(alpha: 0.5)
                  : (isDark ? const Color(0xFF4A3448) : const Color(0xFFFFDDE5)),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x14FF5B9A),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: !hasCustomBg
                ? LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF261925), Color(0xFF1E1424)]
                        : const [Color(0xFFFFF7F2), Color(0xFFFFECEF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            image: hasCustomBg
                ? DecorationImage(
                    image: MemoryImage(
                      base64Decode(customBgData.contains(',') ? customBgData.split(',').last : customBgData),
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      isDark
                          ? const Color(0xFF1A121E).withValues(alpha: 0.85)
                          : const Color(0xFFFFF7F2).withValues(alpha: 0.82),
                      BlendMode.srcOver,
                    ),
                  )
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Layer 1: Big Mascot sitting on the right, layered behind the budget progress bar
                Positioned(
                  right: -4,
                  bottom: -6,
                  child: IgnorePointer(
                    child: Builder(
                      builder: (context) {
                        final customData = ref.watch(customMascotProvider);
                        if (customData != null && customData.isNotEmpty) {
                          try {
                            final commaIdx = customData.indexOf(',');
                            final b64 = commaIdx != -1 ? customData.substring(commaIdx + 1) : customData;
                            final bytes = base64Decode(b64);
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.memory(
                                bytes,
                                width: 175,
                                height: 185,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Image.asset(
                                  defaultMascotAsset,
                                  width: 175,
                                  height: 185,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          } catch (_) {}
                        }
                        return Image.asset(
                          defaultMascotAsset,
                          width: 175,
                          height: 185,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                ),

                // Layer 2: Main Card Content in foreground
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Card Header badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? const Color(0xFF4A3448) : const Color(0xFFF3DCE5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  l10n?.availableToSpendLumi ?? 'เงินที่ใช้ได้ในเดือนนี้',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: VaultTheme.fontFamily,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFFD3C5D0) : const Color(0xFF87767F),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (!hasBudget) ...[
                          // No Budget State: friendly prompt to set a budget
                          Text(
                            l10n?.noBudgetSet ?? 'ยังไม่ได้ตั้งงบประมาณเดือนนี้',
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: VaultTheme.primaryText(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildSubMetric(
                                context: context,
                                label: l10n?.usedSoFar ?? 'ใช้ไปแล้ว',
                                value: Money(totalExpenseSatang).format(symbol: '฿'),
                                color: const Color(0xFFFF5B9A),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5C9D),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text(
                              l10n?.setBudgetAction ?? '+ ตั้งงบประมาณ',
                              style: const TextStyle(
                                fontFamily: VaultTheme.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ] else ...[
                          // Has Budget State: Big remaining budget number
                          FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              Money(remainingSatang).format(symbol: '฿'),
                              style: VaultTheme.tabular(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: isWarning
                                    ? const Color(0xFFE64A63)
                                    : (isDark ? Colors.white : const Color(0xFF332B32)),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Metric: Total Budget (simplified)
                          _buildSubMetric(
                            context: context,
                            label: l10n?.fromTotalBudget ?? 'จากงบรวม',
                            value: Money(totalBudgetSatang).format(symbol: '฿'),
                            color: isDark ? const Color(0xFFA594A1) : const Color(0xFF87767F),
                          ),
                        ],

                        if (hasBudget) ...[
                          const SizedBox(height: 14),
                          // Progress bar with inline percent used on the right
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.spendingProgress ?? 'ความคืบหน้าการใช้เงิน',
                                style: const TextStyle(
                                  fontFamily: VaultTheme.fontFamily,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF87767F),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 9,
                                            width: double.infinity,
                                            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.9),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor: progressRatio,
                                            child: Container(
                                              height: 9,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: (isOverBudget || isWarning)
                                                      ? [const Color(0xFFFF6E82), const Color(0xFFE64A63)]
                                                      : [const Color(0xFFFFB86A), const Color(0xFFFF5B9A)],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$percentUsed%',
                                    style: VaultTheme.tabular(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: (isOverBudget || isWarning)
                                          ? const Color(0xFFE64A63)
                                          : const Color(0xFFFF5B9A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildSubMetric({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFA594A1) : const Color(0xFF87767F),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: VaultTheme.tabular(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
