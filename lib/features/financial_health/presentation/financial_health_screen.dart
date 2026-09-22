import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../domain/models/health_metric_result.dart';
import '../domain/run_rate_calculator.dart';
import 'health_settings_dialog.dart';
import 'liabilities_insurance_screen.dart';
import 'metric_detail_sheet.dart';

class FinancialHealthScreen extends ConsumerStatefulWidget {
  const FinancialHealthScreen({super.key});

  @override
  ConsumerState<FinancialHealthScreen> createState() => _FinancialHealthScreenState();
}

class _FinancialHealthScreenState extends ConsumerState<FinancialHealthScreen> {
  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(financialHealthDaoProvider);
    final theme = Theme.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      appBar: AppBar(
        title: Text(isThai ? 'สุขภาพการเงินและพยากรณ์เงิน' : 'Financial Health & Forecast'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: isThai ? 'ทะเบียนหนี้สินและประกัน' : 'Debts & Insurance',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LiabilitiesInsuranceScreen()),
              ).then((_) => _refresh());
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: isThai ? 'ตั้งค่าเกณฑ์สุขภาพการเงิน' : 'Health Metric Settings',
            onPressed: () async {
              final updated = await HealthSettingsDialog.show(context);
              if (updated == true) _refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder(
          future: Future.wait([
            dao.getFinancialHealthSummary(isThai: isThai),
            dao.getRunRateForecast(),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(isThai ? 'เกิดข้อผิดพลาด: ${snapshot.error}' : 'Error: ${snapshot.error}'));
            }

            final summary = snapshot.data![0] as FinancialHealthSummary;
            final forecast = snapshot.data![1] as RunRateForecast;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // 1. Overall Score Hero Card
                _buildScoreHeroCard(context, summary),
                const SizedBox(height: 16),

                // 2. Run-rate Forecasting Card
                _buildRunRateCard(context, forecast),
                const SizedBox(height: 20),

                // 3. Section Header: 8 Core Financial Metrics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isThai ? 'ตัวชี้วัด 8 ด้าน (Financial Metrics)' : '8 Financial Health Metrics',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      isThai ? 'แตะเพื่อดูสูตร' : 'Tap for details',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 4. List of 8 Metric Cards
                ...summary.metrics.map((m) => _buildMetricCard(context, m)),
                const SizedBox(height: 16),

                // 5. Prioritized Recommendations
                if (summary.prioritizedRecommendations.isNotEmpty) ...[
                  _buildRecommendationsCard(context, summary.prioritizedRecommendations),
                  const SizedBox(height: 24),
                ],

                // 6. Navigation shortcut to Liabilities & Insurance
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: const Icon(Icons.assignment_outlined, color: Colors.indigo),
                    title: Text(
                      isThai ? 'จัดการทะเบียนหนี้สินและกรมธรรม์ประกัน' : 'Manage Debts & Insurance Policies',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(isThai ? 'บันทึกยอดหนี้ วงเงินบัตร และความคุ้มครองประกันภัย' : 'Track loan balances, credit limits and coverage'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LiabilitiesInsuranceScreen()),
                      ).then((_) => _refresh());
                    },
                  ),
                ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreHeroCard(BuildContext context, FinancialHealthSummary summary) {
    final theme = Theme.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final score = summary.totalScore;
    final scoreColor = _getGradeColor(score);
    final gradeLabel = _getGradeLabel(score, isThai);

    final liqScore = summary.metrics.where((m) => m.metricIndex == 1 || m.metricIndex == 2).fold(0, (s, m) => s + m.score);
    final debtScore = summary.metrics.where((m) => m.metricIndex == 3 || m.metricIndex == 4).fold(0, (s, m) => s + m.score);
    final savScore = summary.metrics.where((m) => m.metricIndex == 5 || m.metricIndex == 6).fold(0, (s, m) => s + m.score);
    final insScore = summary.metrics.where((m) => m.metricIndex == 7 || m.metricIndex == 8).fold(0, (s, m) => s + m.score);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Circular score indicator
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scoreColor, width: 4),
                    color: scoreColor.withValues(alpha: 0.08),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      const Text(
                        '/ 100',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isThai ? 'คะแนนสุขภาพการเงินรวม' : 'Overall Health Score',
                        style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gradeLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (score / 100).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            // 4 Pillars Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPillarTile(isThai ? 'สภาพคล่อง' : 'Liquidity', liqScore, 30, Colors.blue.shade700),
                Container(height: 32, width: 1, color: Colors.grey.shade300),
                _buildPillarTile(isThai ? 'หนี้สิน' : 'Debt', debtScore, 30, Colors.deepOrange.shade700),
                Container(height: 32, width: 1, color: Colors.grey.shade300),
                _buildPillarTile(isThai ? 'ออม/ลงทุน' : 'Savings', savScore, 20, Colors.green.shade700),
                Container(height: 32, width: 1, color: Colors.grey.shade300),
                _buildPillarTile(isThai ? 'คุ้มครอง' : 'Insurance', insScore, 20, Colors.purple.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarTile(String label, int score, int maxScore, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '$score/$maxScore',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildRunRateCard(BuildContext context, RunRateForecast forecast) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOverBudget = forecast.varianceSatang > 0;
    final varianceColor = isOverBudget ? Colors.red.shade700 : Colors.green.shade700;
    final variancePct = forecast.monthlyBudgetLimitSatang > 0
        ? (forecast.varianceSatang / forecast.monthlyBudgetLimitSatang * 100).abs()
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.speed_rounded, color: theme.colorScheme.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isThai ? 'พยากรณ์การใช้เงิน (Run-rate Forecast)' : 'Spending Forecast (Run-rate)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Projected Month Spend vs Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isThai ? 'คาดการณ์สิ้นเดือนนี้' : 'Projected End of Month',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Money(forecast.projectedMonthEndSatang).format(symbol: '฿'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isOverBudget ? Colors.red.shade700 : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isThai ? 'เพดานงบประมาณ' : 'Monthly Budget',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Money(forecast.monthlyBudgetLimitSatang).format(symbol: '฿'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: forecast.monthlyBudgetLimitSatang > 0
                    ? (forecast.projectedMonthEndSatang / forecast.monthlyBudgetLimitSatang).clamp(0.0, 1.0)
                    : 0.0,
                minHeight: 8,
                backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget
                      ? Colors.red.shade700
                      : (forecast.varianceSatang == 0 ? Colors.green.shade700 : Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Stats grid (using Wrap so it never overflows)
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  '${isThai ? "ใช้ไปแล้ว" : "Spent"}: ${Money(forecast.accumulatedExpenseSatang).format(symbol: '฿')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                Text(
                  '${isThai ? "ส่วนต่างงบ" : "Variance"}: ${isOverBudget ? "+" : ""}${Money(forecast.varianceSatang).format(symbol: '฿')} (${variancePct.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: varianceColor,
                  ),
                ),
              ],
            ),
            Divider(height: 24, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),

            // Recommended Daily Spend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isThai ? 'วงเงินที่ควรใช้ต่อวัน (เพื่อให้ไม่เกินงบ)' : 'Target Daily Spend (To Stay On Budget)',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${Money(forecast.recommendedDailySpendSatang).format(symbol: '฿')} / ${isThai ? "วัน" : "day"}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: forecast.recommendedDailySpendSatang <= 0 ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isThai ? 'เหลืออีก' : 'Remaining',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${forecast.remainingDaysInMonth} ${isThai ? "วัน" : "days"}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, HealthMetricResult m) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(m.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => MetricDetailSheet.show(context, m),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Status Circle / Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(alpha: 0.12),
                ),
                child: Icon(_getStatusIcon(m.status), color: statusColor, size: 22),
              ),
              const SizedBox(width: 14),

              // Title and Values
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            m.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Text(
                          '${m.score}/${m.maxScore}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${isThai ? "ปัจจุบัน" : "Current"}: ${m.formattedValue}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '(${isThai ? "เป้า" : "Target"}: ${m.targetThreshold})',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(BuildContext context, List<String> recs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF2E2412) : Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates_outlined, color: isDark ? Colors.amber.shade400 : Colors.amber.shade900, size: 20),
                const SizedBox(width: 8),
                Text(
                  isThai ? 'ข้อแนะนำเพื่อสุขภาพการเงินที่ดีขึ้น' : 'Financial Health Recommendations',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recs.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.amber.shade400 : Colors.amber.shade900)),
                    Expanded(
                      child: Text(
                        r,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.amber.shade100 : Colors.brown.shade900,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(int score) {
    if (score >= 80) return Colors.green.shade700;
    if (score >= 60) return Colors.blue.shade700;
    if (score >= 40) return Colors.amber.shade800;
    return Colors.red.shade700;
  }

  String _getGradeLabel(int score, [bool isThai = true]) {
    if (score >= 80) return isThai ? 'ยอดเยี่ยม (สุขภาพการเงินแข็งแกร่ง)' : 'Excellent (Strong)';
    if (score >= 60) return isThai ? 'ดี (มีความมั่นคง)' : 'Good (Stable)';
    if (score >= 40) return isThai ? 'ปานกลาง (มีจุดที่ควรเฝ้าระวัง)' : 'Moderate (Watchlist)';
    return isThai ? 'ควรปรับปรุง (มีความเสี่ยงทางการเงิน)' : 'Needs Improvement (High Risk)';
  }

  Color _getStatusColor(HealthStatus status) {
    switch (status) {
      case HealthStatus.pass:
        return Colors.green.shade700;
      case HealthStatus.warning:
        return Colors.amber.shade800;
      case HealthStatus.fail:
        return Colors.red.shade700;
    }
  }

  IconData _getStatusIcon(HealthStatus status) {
    switch (status) {
      case HealthStatus.pass:
        return Icons.check_circle;
      case HealthStatus.warning:
        return Icons.warning_amber_rounded;
      case HealthStatus.fail:
        return Icons.error_outline;
    }
  }
}
