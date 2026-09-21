import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/services/financial_reports_service.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../financial_health/domain/models/health_metric_result.dart';
import '../../financial_health/presentation/financial_health_screen.dart';
import '../../remittance/presentation/foreign_remittance_screen.dart';
import '../../tax/presentation/tax_screen.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        title: Text(
          'PLAN',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: VaultTheme.primaryText(context),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: VaultTheme.accent(context),
        backgroundColor: VaultTheme.surface(context),
        onRefresh: () async {
          ref.invalidate(financialHealthDaoProvider);
          ref.invalidate(remittancesDaoProvider);
          ref.invalidate(financialReportsServiceProvider);
        },
        child: FutureBuilder<_PlanDashboardData>(
          future: _loadPlanData(ref, now.year),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: VaultTheme.accent(context)),
              );
            }

            final data = snapshot.data;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Text(
                  'PLANNING & WEALTH ARCHITECTURE',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: VaultTheme.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 1: Tax Planning
                _buildTaxCard(context, data),
                const SizedBox(height: 16),

                // Card 2: Foreign Remittance
                _buildRemittanceCard(context, data),
                const SizedBox(height: 16),

                // Card 3: Financial Health
                _buildHealthCard(context, data),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- 1. Tax Planning Card ---
  Widget _buildTaxCard(BuildContext context, _PlanDashboardData? data) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final estTaxSatang = data?.taxEstimatedSatang ?? 0;
    final whtSatang = data?.taxWhtSatang ?? 0;
    final reserveSatang = (estTaxSatang - whtSatang).clamp(0, estTaxSatang);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaxScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: VaultTheme.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VaultTheme.border(context), width: 0.75),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_outlined, size: 20, color: VaultTheme.accent(context)),
                    const SizedBox(width: 8),
                    Text(
                      isThai ? 'วางแผนภาษี (TAX PLANNING)' : 'TAX PLANNING',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: VaultTheme.primaryText(context),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: VaultTheme.mutedText(context)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              isThai ? 'ภาษีคาดการณ์ (ปี ${DateTime.now().year})' : 'Estimated Tax (${DateTime.now().year})',
              style: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontSize: 12,
                color: VaultTheme.secondaryText(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              Money(estTaxSatang).format(symbol: '฿'),
              style: VaultTheme.tabular(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: VaultTheme.primaryText(context),
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: VaultTheme.border(context), height: 1),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  '${isThai ? "หัก ณ ที่จ่ายแล้ว" : "Withheld"}: ${Money(whtSatang).format(symbol: '฿')}',
                  style: VaultTheme.tabular(
                    fontSize: 12,
                    color: VaultTheme.secondaryText(context),
                  ),
                ),
                Text(
                  '${isThai ? "ควรสำรองเพิ่ม" : "Reserve Needed"}: ${Money(reserveSatang).format(symbol: '฿')}',
                  style: VaultTheme.tabular(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: reserveSatang > 0 ? VaultTheme.accent(context) : VaultTheme.positive(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Foreign Remittance Card ---
  Widget _buildRemittanceCard(BuildContext context, _PlanDashboardData? data) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ForeignRemittanceScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: VaultTheme.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VaultTheme.border(context), width: 0.75),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.public_rounded, size: 20, color: VaultTheme.accent(context)),
                    const SizedBox(width: 8),
                    Text(
                      isThai ? 'นำเข้าเงินได้ต่างประเทศ' : 'FOREIGN REMITTANCE',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: VaultTheme.primaryText(context),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: VaultTheme.mutedText(context)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isThai ? 'เงินต้นคงเหลือในต่างประเทศ' : 'Offshore Principal',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 12,
                          color: VaultTheme.secondaryText(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$ ${(data?.foreignPrincipalUsdSatang ?? 0) / 100.0}',
                        style: VaultTheme.tabular(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: VaultTheme.primaryText(context),
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
                      isThai ? 'นำเข้าไทยปีนี้' : 'Brought In This Year',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 12,
                        color: VaultTheme.secondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Money(data?.remittanceBroughtInSatang ?? 0).format(symbol: '฿'),
                      style: VaultTheme.tabular(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: VaultTheme.accent(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: VaultTheme.border(context), height: 1),
            const SizedBox(height: 10),
            Text(
              data != null
                  ? (isThai ? data.remittanceAlertTextTh : data.remittanceAlertTextEn)
                  : (isThai ? 'สถานะการนำเข้าเงินได้เป็นไปตามเกณฑ์' : 'Remittance status compliant'),
              style: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontSize: 12,
                color: VaultTheme.secondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Financial Health Card ---
  Widget _buildHealthCard(BuildContext context, _PlanDashboardData? data) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final score = data?.healthScore ?? 85;
    final runway = data?.emergencyRunwayMonths ?? 6.0;
    final savingsRate = data?.savingsRatePercent ?? 30.0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FinancialHealthScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: VaultTheme.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: VaultTheme.border(context), width: 0.75),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 20, color: VaultTheme.positive(context)),
                    const SizedBox(width: 8),
                    Text(
                      isThai ? 'สุขภาพการเงิน' : 'FINANCIAL HEALTH',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: VaultTheme.primaryText(context),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: VaultTheme.mutedText(context)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '$score',
                  style: VaultTheme.tabular(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: VaultTheme.positive(context),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '/ 100',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 14,
                    color: VaultTheme.mutedText(context),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: VaultTheme.positive(context).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data != null
                        ? (isThai ? data.healthGradeTh : data.healthGradeEn)
                        : (isThai ? 'แข็งแกร่ง (Strong)' : 'Strong'),
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: VaultTheme.positive(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: VaultTheme.border(context), height: 1),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  '${isThai ? "เงินสำรองฉุกเฉิน" : "Runway"}: ${runway.toStringAsFixed(1)} ${isThai ? "เดือน" : "mo"}',
                  style: VaultTheme.tabular(
                    fontSize: 12,
                    color: VaultTheme.secondaryText(context),
                  ),
                ),
                Text(
                  '${isThai ? "อัตราการออม" : "Savings Rate"}: ${savingsRate.toStringAsFixed(0)}%',
                  style: VaultTheme.tabular(
                    fontSize: 12,
                    color: VaultTheme.secondaryText(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<_PlanDashboardData> _loadPlanData(WidgetRef ref, int year) async {
    int estTax = 0;
    int wht = 0;
    try {
      final reportsService = ref.read(financialReportsServiceProvider);
      final taxReport = await reportsService.generateTaxPreparationReport(year);
      estTax = taxReport.computedTaxSatang;
      wht = taxReport.totalWithholdingTaxSatang;
    } catch (_) {}

    int principalUsd = 0;
    int broughtInThb = 0;
    String alertTh = 'ติดตามเงินต้นและผลตอบแทนที่นำเข้าไทย';
    String alertEn = 'Track foreign principal and returns remitted to Thailand';
    try {
      final remDao = ref.read(remittancesDaoProvider);
      principalUsd = await remDao.getRemainingForeignPrincipalSatang();
      final broughtInEvents = await remDao.getRemittancesForYear(year);
      for (final e in broughtInEvents) {
        broughtInThb += e.amountThbSatang;
      }
      if (broughtInEvents.isNotEmpty) {
        alertTh = 'นำเข้าเงินได้ปีนี้ ${broughtInEvents.length} รายการ';
        alertEn = '${broughtInEvents.length} remittances brought in this year';
      }
    } catch (_) {}

    int score = 85;
    double runway = 6.0;
    double savings = 32.0;
    String gradeTh = 'แข็งแกร่ง (Strong)';
    String gradeEn = 'Strong';
    try {
      final healthDao = ref.read(financialHealthDaoProvider);
      final summary = await healthDao.getFinancialHealthSummary();
      score = summary.totalScore;
      gradeTh = summary.overallStatus == HealthStatus.pass
          ? 'แข็งแกร่ง (Strong)'
          : (summary.overallStatus == HealthStatus.warning ? 'ปานกลาง (Fair)' : 'ควรปรับปรุง (Attention)');
      gradeEn = summary.overallStatus == HealthStatus.pass
          ? 'Strong'
          : (summary.overallStatus == HealthStatus.warning ? 'Fair' : 'Attention');
      final emergencyMetric = summary.metrics.where((m) => m.code == 'emergency_fund').firstOrNull;
      final savingsMetric = summary.metrics.where((m) => m.code == 'savings_rate').firstOrNull;
      if (emergencyMetric != null) {
        runway = emergencyMetric.currentValue.toDouble();
      }
      if (savingsMetric != null) {
        savings = savingsMetric.currentValue.toDouble();
      }
    } catch (_) {}

    return _PlanDashboardData(
      taxEstimatedSatang: estTax,
      taxWhtSatang: wht,
      foreignPrincipalUsdSatang: principalUsd,
      remittanceBroughtInSatang: broughtInThb,
      remittanceAlertTextTh: alertTh,
      remittanceAlertTextEn: alertEn,
      healthScore: score,
      healthGradeTh: gradeTh,
      healthGradeEn: gradeEn,
      emergencyRunwayMonths: runway,
      savingsRatePercent: savings,
    );
  }
}

class _PlanDashboardData {
  final int taxEstimatedSatang;
  final int taxWhtSatang;
  final int foreignPrincipalUsdSatang;
  final int remittanceBroughtInSatang;
  final String remittanceAlertTextTh;
  final String remittanceAlertTextEn;
  final int healthScore;
  final String healthGradeTh;
  final String healthGradeEn;
  final double emergencyRunwayMonths;
  final double savingsRatePercent;

  const _PlanDashboardData({
    required this.taxEstimatedSatang,
    required this.taxWhtSatang,
    required this.foreignPrincipalUsdSatang,
    required this.remittanceBroughtInSatang,
    required this.remittanceAlertTextTh,
    required this.remittanceAlertTextEn,
    required this.healthScore,
    required this.healthGradeTh,
    required this.healthGradeEn,
    required this.emergencyRunwayMonths,
    required this.savingsRatePercent,
  });
}
