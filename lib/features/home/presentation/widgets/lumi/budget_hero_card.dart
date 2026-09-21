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

    final progressRatio = hasBudget
        ? (totalExpenseSatang / totalBudgetSatang).clamp(0.0, 1.0)
        : 0.0;

    final isWarning = hasBudget && remainingSatang < (totalBudgetSatang * 0.2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          constraints: const BoxConstraints(minHeight: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF0F5), Color(0xFFFFF7EA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFFF3DCE5), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14FF5B9A),
                blurRadius: 18,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Stack(
            children: [
              // Content column (left)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: VaultTheme.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildSubMetric(
                          label: l10n?.usedSoFar ?? 'ใช้ไปแล้ว',
                          value: Money(totalExpenseSatang).format(symbol: '฿'),
                          color: const Color(0xFFFF5B9A),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
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
                    Text(
                      Money(remainingSatang).format(symbol: '฿'),
                      style: VaultTheme.tabular(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: isWarning ? const Color(0xFFE64A63) : const Color(0xFF332B32),
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Metrics: Spent vs Budget
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
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

              // Lumi mascot character on the right
              Positioned(
                right: 0,
                top: 0,
                bottom: 10,
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/images/lumi_budget_character.png',
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
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
            fontWeight: FontWeight.w500,
            color: Color(0xFF87767F),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: VaultTheme.tabular(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
