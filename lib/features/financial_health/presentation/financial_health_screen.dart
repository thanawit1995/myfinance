import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../domain/models/health_metric_result.dart';
import '../domain/run_rate_calculator.dart';
import '../../../../core/theme/vault_theme.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('สุขภาพการเงินและพยากรณ์เงิน'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'ทะเบียนหนี้สินและประกัน',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LiabilitiesInsuranceScreen()),
              ).then((_) => _refresh());
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'ตั้งค่าเกณฑ์สุขภาพการเงิน',
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
            dao.getFinancialHealthSummary(),
            dao.getRunRateForecast(),
          ]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
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
                    Text(
                      'ตัวชี้วัด 8 ด้าน (Financial Metrics)',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'แตะเพื่อดูสูตรและที่มา',
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
                    title: const Text('จัดการทะเบียนหนี้สินและกรมธรรม์ประกัน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('บันทึกยอดหนี้ วงเงินบัตร และความคุ้มครองประกันภัย'),
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
    final score = summary.totalScore;
    final scoreColor = _getGradeColor(score);
    final gradeLabel = _getGradeLabel(score);

    final liqScore = summary.metrics.where((m) => m.metricIndex == 1 || m.metricIndex == 2).fold(0, (s, m) => s + m.score);
    final debtScore = summary.metrics.where((m) => m.metricIndex == 3 || m.metricIndex == 4).fold(0, (s, m) => s + m.score);
    final savScore = summary.metrics.where((m) => m.metricIndex == 5 || m.metricIndex == 6).fold(0, (s, m) => s + m.score);
    final insScore = summary.metrics.where((m) => m.metricIndex == 7 || m.metricIndex == 8).fold(0, (s, m) => s + m.score);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.colorScheme.surface,
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
                        'คะแนนสุขภาพการเงินรวม',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        gradeLabel,
                        style: TextStyle(
                          fontSize: 16,
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
                _buildPillarTile('สภาพคล่อง', liqScore, 30, Colors.blue.shade700),
                Container(height: 32, width: 1, color: Colors.grey.shade300),
                _buildPillarTile('หนี้สิน', debtScore, 30, Colors.deepOrange.shade700),
                Container(height: 32, width: 1, color: Colors.grey.shade300),
                _buildPillarTile('ออม/ลงทุน', savScore, 20, Colors.green.shade700),
                Container(height: 32, width: 1, color: Colors.grey.shade300),
                _buildPillarTile('คุ้มครอง', insScore, 20, Colors.purple.shade700),
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
    final isOverBudget = forecast.varianceSatang > 0;
    final varianceColor = isOverBudget ? VaultTheme.negative(context) : VaultTheme.positive(context);
    final variancePct = forecast.monthlyBudgetLimitSatang > 0
        ? (forecast.varianceSatang / forecast.monthlyBudgetLimitSatang * 100).abs()
        : 0.0;
    final isLumi = VaultTheme.isLumi(context);

    return Container(
      decoration: BoxDecoration(
        color: VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VaultTheme.border(context), width: 0.8),
        boxShadow: isLumi
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
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
                  color: VaultTheme.accent(context).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.speed_rounded, color: VaultTheme.accent(context), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'พยากรณ์การใช้เงิน (Run-rate Forecast)',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: VaultTheme.primaryText(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Projected Month Spend vs Budget
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'คาดการณ์สิ้นเดือนนี้',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 12,
                      color: VaultTheme.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Money(forecast.projectedMonthEndSatang).format(symbol: '฿'),
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isOverBudget ? VaultTheme.negative(context) : VaultTheme.primaryText(context),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'เพดานงบประมาณ',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 12,
                      color: VaultTheme.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Money(forecast.monthlyBudgetLimitSatang).format(symbol: '฿'),
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: VaultTheme.primaryText(context),
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
              backgroundColor: VaultTheme.border(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget
                    ? VaultTheme.negative(context)
                    : (forecast.varianceSatang == 0 ? VaultTheme.positive(context) : Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stats grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ใช้ไปแล้ว: ${Money(forecast.accumulatedExpenseSatang).format(symbol: '฿')}',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 12,
                  color: VaultTheme.secondaryText(context),
                ),
              ),
              Text(
                'ส่วนต่างงบ: ${isOverBudget ? "+" : ""}${Money(forecast.varianceSatang).format(symbol: '฿')} (${variancePct.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: varianceColor,
                ),
              ),
            ],
          ),
          Divider(height: 24, color: VaultTheme.border(context)),

          // Recommended Daily Spend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'วงเงินที่ควรใช้ต่อวัน (เพื่อให้ไม่เกินงบ)',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 11.5,
                        color: VaultTheme.secondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Money(forecast.recommendedDailySpendSatang).format(symbol: '฿')} / วัน',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: forecast.recommendedDailySpendSatang <= 0 ? VaultTheme.negative(context) : VaultTheme.positive(context),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'เหลืออีก',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 11.5,
                      color: VaultTheme.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${forecast.remainingDaysInMonth} วัน',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: VaultTheme.primaryText(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, HealthMetricResult m) {
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
                    Row(
                      children: [
                        Text(
                          'ปัจจุบัน: ${m.formattedValue}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(เป้า: ${m.targetThreshold})',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
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
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates_outlined, color: Colors.amber.shade900, size: 20),
                const SizedBox(width: 8),
                Text(
                  'ข้อแนะนำเพื่อสุขภาพการเงินที่ดีขึ้น',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
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
                    Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                    Expanded(
                      child: Text(
                        r,
                        style: TextStyle(fontSize: 13, color: Colors.brown.shade900, height: 1.35),
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

  String _getGradeLabel(int score) {
    if (score >= 80) return 'ยอดเยี่ยม (สุขภาพการเงินแข็งแกร่ง)';
    if (score >= 60) return 'ดี (มีความมั่นคง)';
    if (score >= 40) return 'ปานกลาง (มีจุดที่ควรเฝ้าระวัง)';
    return 'ควรปรับปรุง (มีความเสี่ยงทางการเงิน)';
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
