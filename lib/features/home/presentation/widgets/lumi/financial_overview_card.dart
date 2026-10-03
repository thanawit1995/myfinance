import 'package:flutter/material.dart';
import '../../../../../core/money/money.dart';
import '../../../../../core/theme/vault_theme.dart';
import '../../../../../l10n/app_localizations.dart';

class FinancialOverviewCard extends StatelessWidget {
  final int netWorthSatang;
  final double momChangePercent;
  final int cashFlowMonthSatang;
  final int totalIncomeSatang;
  final int totalExpenseSatang;
  final int totalCashSatang;
  final int portfolioValueSatang;
  final int accruedIncomeSatang;
  final int accruedIncomeCount;
  final int insuranceSavingsSatang;
  final VoidCallback onViewMonthlySummary;
  final VoidCallback? onNavigateToMoney;
  final VoidCallback? onNavigateToInvest;
  final VoidCallback? onNavigateToAccruedIncome;
  final VoidCallback? onNavigateToInsurance;

  const FinancialOverviewCard({
    super.key,
    required this.netWorthSatang,
    required this.momChangePercent,
    required this.cashFlowMonthSatang,
    required this.totalIncomeSatang,
    required this.totalExpenseSatang,
    this.totalCashSatang = 0,
    this.portfolioValueSatang = 0,
    this.accruedIncomeSatang = 0,
    this.accruedIncomeCount = 0,
    this.insuranceSavingsSatang = 0,
    required this.onViewMonthlySummary,
    this.onNavigateToMoney,
    this.onNavigateToInvest,
    this.onNavigateToAccruedIncome,
    this.onNavigateToInsurance,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final isNetWorthPositive = netWorthSatang >= 0;
    final isMoMPositive = momChangePercent >= 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? VaultTheme.surface(context) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? VaultTheme.border(context) : const Color(0xFFF3DCE5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0x0CFF5B9A),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with "Monthly Report ›"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n?.financialOverview ?? 'ภาพรวมสถานะการเงิน',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? VaultTheme.primaryText(context) : const Color(0xFF332B32),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onViewMonthlySummary,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n?.viewMonthlyReport ?? 'ดูรายงานรายเดือน',
                        style: const TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF5C9D),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color(0xFFFF5C9D),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Primary Net Worth
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Money(netWorthSatang).format(symbol: '฿'),
                    style: VaultTheme.tabular(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isNetWorthPositive
                          ? (isDark ? VaultTheme.primaryText(context) : const Color(0xFF332B32))
                          : const Color(0xFFE64A63),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isMoMPositive
                      ? (isDark ? const Color(0xFF1E3A2B) : const Color(0xFFE8F5EE))
                      : (isDark ? const Color(0xFF3F1D24) : const Color(0xFFFFECF0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMoMPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                      color: isMoMPositive ? const Color(0xFF4CAF50) : const Color(0xFFFF6B81),
                      size: 16,
                    ),
                    Text(
                      '${isMoMPositive ? '+' : ''}${momChangePercent.toStringAsFixed(1)}%',
                      style: VaultTheme.tabular(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isMoMPositive ? const Color(0xFF4CAF50) : const Color(0xFFFF6B81),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),
          Text(
            l10n?.netWorthDesc ?? 'ความมั่งคั่งสุทธิ (สินทรัพย์ - หนี้สิน)',
            style: TextStyle(
              fontFamily: VaultTheme.fontFamily,
              fontSize: 12,
              color: isDark ? const Color(0xFFA594A1) : const Color(0xFF87767F),
            ),
          ),

          const SizedBox(height: 14),

          // 2x2 Clickable Breakdown Tiles (Cash, Portfolio, Accrued Income, Insurance)
          Row(
            children: [
              Expanded(
                child: _buildBreakdownTile(
                  context: context,
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF42A5F5),
                  label: isThai ? 'เงินสด/เงินฝาก' : 'Cash & Bank',
                  amountSatang: totalCashSatang,
                  badge: null,
                  onTap: onNavigateToMoney,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBreakdownTile(
                  context: context,
                  icon: Icons.trending_up_rounded,
                  iconColor: const Color(0xFFAB47BC),
                  label: isThai ? 'พอร์ตลงทุน' : 'Portfolio',
                  amountSatang: portfolioValueSatang,
                  badge: null,
                  onTap: onNavigateToInvest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildBreakdownTile(
                  context: context,
                  icon: Icons.pending_actions_rounded,
                  iconColor: const Color(0xFFFF9800),
                  label: isThai ? 'เงินค้างรับ' : 'Accrued Income',
                  amountSatang: accruedIncomeSatang,
                  badge: accruedIncomeCount > 0 ? '$accruedIncomeCount' : null,
                  onTap: onNavigateToAccruedIncome,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBreakdownTile(
                  context: context,
                  icon: Icons.health_and_safety_outlined,
                  iconColor: const Color(0xFF26A69A),
                  label: isThai ? 'สะสมประกัน' : 'Insurance',
                  amountSatang: insuranceSavingsSatang,
                  badge: null,
                  onTap: onNavigateToInsurance,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(
            color: isDark ? VaultTheme.border(context) : const Color(0xFFF3DCE5),
            height: 1,
          ),
          const SizedBox(height: 14),

          // Sub metrics: Month Income vs Month Expense vs Cash Flow
          Row(
            children: [
              Expanded(
                child: _buildMiniMetric(
                  context: context,
                  label: l10n?.monthIncome ?? 'รายรับเดือนนี้',
                  amountSatang: totalIncomeSatang,
                  color: isDark ? const Color(0xFF81C784) : const Color(0xFF2E8B57),
                  bgColor: isDark ? const Color(0xFF1B2E23) : const Color(0xFFF0FAF2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniMetric(
                  context: context,
                  label: l10n?.monthExpense ?? 'รายจ่ายเดือนนี้',
                  amountSatang: totalExpenseSatang,
                  color: isDark ? const Color(0xFFFF8A9E) : const Color(0xFFE64A63),
                  bgColor: isDark ? const Color(0xFF381924) : const Color(0xFFFFF0F5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniMetric(
                  context: context,
                  label: l10n?.cashFlow ?? 'กระแสเงินสด',
                  amountSatang: cashFlowMonthSatang,
                  color: cashFlowMonthSatang >= 0
                      ? (isDark ? const Color(0xFF81C784) : const Color(0xFF2E8B57))
                      : (isDark ? const Color(0xFFFF8A9E) : const Color(0xFFE64A63)),
                  bgColor: isDark ? const Color(0xFF2B202D) : const Color(0xFFFFF9F5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required int amountSatang,
    required String? badge,
    required VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A1F2C) : const Color(0xFFFAF5F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF3E2C41) : const Color(0xFFF0DDE5),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: iconColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFD4C2D0) : const Color(0xFF6B5865),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFF9800),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: isDark ? const Color(0xFF755B70) : const Color(0xFFB5A1AF),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Money(amountSatang).format(symbol: '฿'),
                style: VaultTheme.tabular(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? VaultTheme.primaryText(context) : const Color(0xFF332B32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric({
    required BuildContext context,
    required String label,
    required int amountSatang,
    required Color color,
    required Color bgColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: VaultTheme.fontFamily,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFA594A1) : const Color(0xFF87767F),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Money(amountSatang).format(symbol: '฿'),
              style: VaultTheme.tabular(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
