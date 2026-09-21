import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/daos/transactions_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../financial_health/domain/models/health_metric_result.dart';
import '../../financial_health/domain/run_rate_calculator.dart';
import '../../financial_health/presentation/financial_health_screen.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onQuickAddPressed;

  const DashboardScreen({super.key, required this.onQuickAddPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.appTitle ?? 'MyFinance'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onQuickAddPressed,
        icon: const Icon(Icons.add),
        label: Text(l10n?.quickAdd ?? 'บันทึกด่วน'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger rebuild
          ref.invalidate(accountsDaoProvider);
        },
        child: FutureBuilder(
          future: _loadDashboardData(ref, now),
          builder: (context, AsyncSnapshot<_DashboardData> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
            }

            final data = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // 1. Hero Card: เงินที่ใช้ได้เหลือเดือนนี้ (ตัวใหญ่สุด)
                _buildHeroRemainingCard(context, data),
                const SizedBox(height: 16),

                // 2. 4 Mini Stat Cards
                _buildSummaryGrid(context, data),
                const SizedBox(height: 16),

                // 2.5 Financial Health & Run-rate Teaser Card
                if (data.healthSummary != null && data.runRateForecast != null) ...[
                  _buildFinancialHealthTeaserCard(context, data.healthSummary!, data.runRateForecast!),
                  const SizedBox(height: 16),
                ],

                // 3. Donut Chart: กราฟรายจ่ายแยกหมวดหมู่
                _buildDonutChartCard(context, data.categoryExpenses),
                const SizedBox(height: 24),

                // 4. Bar Chart: เทรนด์ 6 เดือน
                _buildBarChartCard(context, data.monthlyTrends),
                const SizedBox(height: 80), // Padding for FAB
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroRemainingCard(BuildContext context, _DashboardData data) {
    final theme = Theme.of(context);
    final remainingMoney = Money(data.remainingBudgetSatang);
    final spentMoney = Money(data.totalExpenseMonthSatang);
    final budgetMoney = Money(data.totalBudgetMonthSatang);

    final progress = data.totalBudgetMonthSatang > 0
        ? (data.totalExpenseMonthSatang / data.totalBudgetMonthSatang).clamp(0.0, 1.0)
        : 0.0;

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF064E3B), const Color(0xFF1E293B)]
              : [const Color(0xFFD1FAE5), const Color(0xFFECFDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark ? const Color(0x3334D399) : const Color(0xFF6EE7B7),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)?.remainingBudget ?? 'เงินที่ใช้ได้เหลือเดือนนี้',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ตัวใหญ่สุดตาม requirement
            Text(
              remainingMoney.format(symbol: '฿'),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : const Color(0xFF064E3B),
              ),
            ),
            const SizedBox(height: 14),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.9
                      ? AppTheme.expenseColor(context)
                      : (progress > 0.75 ? theme.colorScheme.tertiary : (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ใช้ไป: ${spentMoney.format(symbol: '฿')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'งบ: ${budgetMoney.format(symbol: '฿')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid(BuildContext context, _DashboardData data) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final netSavingsSatang = data.totalIncomeMonthSatang - data.totalExpenseMonthSatang;
    final isPositiveSavings = netSavingsSatang >= 0;
    final savingsColor = isPositiveSavings ? AppTheme.incomeColor(context) : AppTheme.expenseColor(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatTile(
                context,
                title: l10n?.netWorth ?? 'ความมั่งคั่งสุทธิ',
                amount: Money(data.netWorthSatang).format(symbol: '฿'),
                color: theme.colorScheme.primary,
                icon: Icons.pie_chart_outline,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatTile(
                context,
                title: l10n?.monthlyIncome ?? 'รายรับเดือนนี้',
                amount: Money(data.totalIncomeMonthSatang).format(symbol: '฿'),
                color: AppTheme.incomeColor(context),
                icon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatTile(
                context,
                title: l10n?.netSavings ?? 'เงินออมสุทธิ',
                amount: '${isPositiveSavings ? '+' : ''}${Money(netSavingsSatang).format(symbol: '฿')}',
                color: savingsColor,
                icon: Icons.savings_outlined,
              ),
            ),
          ],
        ),
        if (data.creditCardCurrentCycleSatang > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.credit_card_outlined, size: 18, color: theme.colorScheme.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ยอดรอตัดรอบบัตรเครดิต',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
                Text(
                  Money(data.creditCardCurrentCycleSatang).format(symbol: '฿'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.brightness == Brightness.dark ? const Color(0x22FFFFFF) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChartCard(BuildContext context, List<CategoryExpenseSummary> items) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.donut_large_rounded,
                  size: 44,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 8),
                Text(
                  'ยังไม่มีข้อมูลรายจ่ายในเดือนนี้',
                  style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final colors = [
      const Color(0xFFF87171), // Coral red
      const Color(0xFF60A5FA), // Blue
      const Color(0xFF34D399), // Mint green
      const Color(0xFFFBBF24), // Amber
      const Color(0xFFA78BFA), // Purple
      const Color(0xFF2DD4BF), // Teal
      const Color(0xFFFB923C), // Orange
      const Color(0xFF818CF8), // Indigo
    ];

    int totalSatang = items.fold(0, (sum, i) => sum + i.totalSatang);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart_rounded, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)?.spendingByCategory ?? 'สัดส่วนรายจ่ายเดือนนี้', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 44,
                  sections: items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final percent = totalSatang > 0 ? (item.totalSatang / totalSatang * 100) : 0.0;
                    return PieChartSectionData(
                      value: item.totalSatang.toDouble(),
                      title: '${percent.toStringAsFixed(0)}%',
                      radius: 40,
                      titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      color: colors[idx % colors.length],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[idx % colors.length], shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(
                      '${item.categoryNameTh} (${Money(item.totalSatang).format(symbol: '฿')})',
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard(BuildContext context, List<MonthTrendSummary> trends) {
    final theme = Theme.of(context);

    if (trends.isEmpty) {
      return const SizedBox.shrink();
    }

    final monthNames = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
    final incColor = AppTheme.incomeColor(context);
    final expColor = AppTheme.expenseColor(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)?.incomeExpenseTrends ?? 'เทรนด์รายรับ-รายจ่าย 6 เดือน', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  barGroups: trends.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final t = entry.value;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: t.incomeSatang / 100.0,
                          color: incColor,
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: t.expenseSatang / 100.0,
                          color: expColor,
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          final i = val.toInt();
                          if (i >= 0 && i < trends.length) {
                            return Text(
                              monthNames[trends[i].month - 1],
                              style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: incColor, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('รายรับ', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(width: 16),
                Container(width: 8, height: 8, decoration: BoxDecoration(color: expColor, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text('รายจ่าย', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialHealthTeaserCard(
    BuildContext context,
    FinancialHealthSummary summary,
    RunRateForecast forecast,
  ) {
    final theme = Theme.of(context);
    final score = summary.totalScore;
    final scoreColor = score >= 80 ? AppTheme.incomeColor(context) : (score >= 60 ? theme.colorScheme.secondary : (score >= 40 ? theme.colorScheme.tertiary : AppTheme.expenseColor(context)));
    final gradeLabel = score >= 80 ? 'ดีเยี่ยม' : (score >= 60 ? 'ดี' : (score >= 40 ? 'ปานกลาง' : 'ควรปรับปรุง'));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FinancialHealthScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.health_and_safety_rounded, size: 16, color: scoreColor),
                        const SizedBox(width: 4),
                        Text(
                          'สุขภาพการเงิน $score/100 • $gradeLabel',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: scoreColor),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ดูรายงานฉบับเต็ม',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 12, color: theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('คาดการณ์สิ้นเดือน', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                      Text(
                        Money(forecast.projectedMonthEndSatang).format(symbol: '฿'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('งบประมาณ', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                      Text(
                        Money(forecast.monthlyBudgetLimitSatang).format(symbol: '฿'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ใช้ได้อีกวันละ', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                      Text(
                        '${Money(forecast.recommendedDailySpendSatang).format(symbol: '฿')}/วัน',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: forecast.recommendedDailySpendSatang <= 0 ? AppTheme.expenseColor(context) : AppTheme.incomeColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<_DashboardData> _loadDashboardData(WidgetRef ref, DateTime now) async {
    final txDao = ref.read(transactionsDaoProvider);
    final accDao = ref.read(accountsDaoProvider);
    final ccDao = ref.read(creditCardDaoProvider);
    final bgDao = ref.read(budgetsDaoProvider);
    final healthDao = ref.read(financialHealthDaoProvider);

    final netWorth = await accDao.getTotalNetWorthSatang();

    // Monthly transactions
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.month == 12 ? now.year + 1 : now.year, now.month == 12 ? 1 : now.month + 1, 1);

    final monthTx = await txDao.searchTransactions(startDate: startOfMonth, endDate: endOfMonth);
    int totalIncome = 0;
    int totalExpense = 0;

    for (final t in monthTx) {
      if (t.transactionType == 'income') {
        totalIncome += t.amountThbSatang;
      } else if (t.transactionType == 'expense') {
        totalExpense += (t.amountThbSatang + t.feeThbSatang);
      }
    }

    // Budgets
    final budgets = await bgDao.getBudgetStatusForMonth(now.year, now.month);
    int totalBudget = 0;
    for (final b in budgets) {
      totalBudget += b.limitSatang;
    }
    // Default budget if none set
    if (totalBudget == 0) totalBudget = 3000000; // 30,000 THB default overall limit
    final remainingBudget = (totalBudget - totalExpense).clamp(0, totalBudget);

    // Credit Card current cycle
    final activeAccounts = await accDao.getActiveAccounts();
    int ccCurrentDebt = 0;
    for (final a in activeAccounts) {
      if (a.accountType == 'credit_card') {
        final summary = await ccDao.getSummary(a.id, now);
        if (summary != null) {
          ccCurrentDebt += summary.currentCycleDebtSatang;
        }
      }
    }

    final categoryExpenses = await txDao.getMonthlyExpensesByCategory(now.year, now.month);
    final monthlyTrends = await txDao.getMonthlyTrend(6);

    FinancialHealthSummary? healthSummary;
    RunRateForecast? runRateForecast;
    try {
      healthSummary = await healthDao.getFinancialHealthSummary();
      runRateForecast = await healthDao.getRunRateForecast();
    } catch (_) {
      // Graceful fallback if empty
    }

    return _DashboardData(
      netWorthSatang: netWorth,
      totalIncomeMonthSatang: totalIncome,
      totalExpenseMonthSatang: totalExpense,
      totalBudgetMonthSatang: totalBudget,
      remainingBudgetSatang: remainingBudget,
      creditCardCurrentCycleSatang: ccCurrentDebt,
      categoryExpenses: categoryExpenses,
      monthlyTrends: monthlyTrends,
      healthSummary: healthSummary,
      runRateForecast: runRateForecast,
    );
  }
}

class _DashboardData {
  final int netWorthSatang;
  final int totalIncomeMonthSatang;
  final int totalExpenseMonthSatang;
  final int totalBudgetMonthSatang;
  final int remainingBudgetSatang;
  final int creditCardCurrentCycleSatang;
  final List<CategoryExpenseSummary> categoryExpenses;
  final List<MonthTrendSummary> monthlyTrends;
  final FinancialHealthSummary? healthSummary;
  final RunRateForecast? runRateForecast;

  const _DashboardData({
    required this.netWorthSatang,
    required this.totalIncomeMonthSatang,
    required this.totalExpenseMonthSatang,
    required this.totalBudgetMonthSatang,
    required this.remainingBudgetSatang,
    required this.creditCardCurrentCycleSatang,
    required this.categoryExpenses,
    required this.monthlyTrends,
    this.healthSummary,
    this.runRateForecast,
  });
}
