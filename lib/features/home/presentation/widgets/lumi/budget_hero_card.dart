import 'package:flutter/material.dart';
import '../../../../../core/money/money.dart';
import '../../../../../core/theme/vault_theme.dart';
import '../../../../../l10n/app_localizations.dart';

class BudgetHeroCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasBudget = totalBudgetSatang > 0;

    final percentUsed = hasBudget
        ? ((totalExpenseSatang / totalBudgetSatang) * 100).clamp(0, 100).toInt()
        : 0;

    final percentRemaining = hasBudget
        ? ((remainingSatang / totalBudgetSatang) * 100).clamp(0, 100).toInt()
        : 100;

    final isWarning = hasBudget && percentRemaining < 20;

    final progressRatio = hasBudget
        ? (totalExpenseSatang / totalBudgetSatang).clamp(0.0, 1.0)
        : 0.0;

    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Semantics(
      button: true,
      label: isThai ? 'งบประมาณคงเหลือ' : 'Remaining Budget',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF7F2), Color(0xFFFFECEF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isWarning
                  ? const Color(0xFFFF6E82).withValues(alpha: 0.5)
                  : const Color(0xFFFFDDE5),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14FF5B9A),
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF3DCE5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                l10n?.availableToSpendLumi ?? 'เงินที่ใช้ได้ในเดือนนี้ 🌸',
                                style: const TextStyle(
                                  fontFamily: VaultTheme.fontFamily,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF87767F),
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
                                color: isWarning ? const Color(0xFFE64A63) : const Color(0xFF332B32),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Metrics: Spent vs Budget
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              _buildSubMetric(
                                label: l10n?.usedSoFar ?? 'ใช้ไปแล้ว',
                                value: Money(totalExpenseSatang).format(symbol: '฿'),
                                color: const Color(0xFFFF5B9A),
                              ),
                              _buildSubMetric(
                                label: l10n?.fromTotalBudget ?? 'จากงบรวม',
                                value: Money(totalBudgetSatang).format(symbol: '฿'),
                                color: const Color(0xFF87767F),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Lumi mascot character alongside without overlapping
                  Image.asset(
                    'assets/images/lumi_budget_character.png',
                    width: 95,
                    height: 105,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ],
              ),

              if (hasBudget) ...[
                const SizedBox(height: 14),
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5B9A).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n?.percentUsed(percentUsed) ?? 'ใช้ไป $percentUsed%',
                            style: VaultTheme.tabular(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF5B9A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            height: 9,
                            width: double.infinity,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          FractionallySizedBox(
                            widthFactor: progressRatio,
                            child: Container(
                              height: 9,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isWarning
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
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF87767F),
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
