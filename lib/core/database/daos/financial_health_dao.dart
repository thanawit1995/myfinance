import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/all_tables.dart';
import '../../../features/financial_health/domain/financial_health_calculator.dart';
import '../../../features/financial_health/domain/models/health_metric_result.dart';
import '../../../features/financial_health/domain/run_rate_calculator.dart';

part 'financial_health_dao.g.dart';

@DriftAccessor(tables: [FinancialHealthSettings, Accounts, Transactions, Liabilities, InsurancePolicies, Assets, Budgets, AuditLogs])
class FinancialHealthDao extends DatabaseAccessor<AppDatabase> with _$FinancialHealthDaoMixin {
  FinancialHealthDao(super.db);

  final _uuid = const Uuid();

  // -------------------------------------------------------------
  // 1. SETTINGS & THRESHOLDS CRUD
  // -------------------------------------------------------------

  Future<List<FinancialHealthSetting>> getAllSettings() {
    return (select(financialHealthSettings)..where((s) => s.deletedAt.isNull())).get();
  }

  Future<FinancialHealthSetting?> getSettingByMetric(String metricCode) {
    return (select(financialHealthSettings)
          ..where((s) => s.metricCode.equals(metricCode) & s.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> upsertSetting({
    required String metricCode,
    required String targetOperator,
    required String targetValue,
    String? warningValue,
    int? userParam1Satang,
    int? userParam2Satang,
  }) async {
    final now = DateTime.now();
    final existing = await getSettingByMetric(metricCode);

    if (existing != null) {
      await (update(financialHealthSettings)..where((s) => s.id.equals(existing.id))).write(
        FinancialHealthSettingsCompanion(
          targetOperator: Value(targetOperator),
          targetValue: Value(targetValue),
          warningValue: Value(warningValue),
          userParam1Satang: Value(userParam1Satang ?? existing.userParam1Satang),
          userParam2Satang: Value(userParam2Satang ?? existing.userParam2Satang),
          updatedAt: Value(now),
        ),
      );
    } else {
      await into(financialHealthSettings).insert(
        FinancialHealthSettingsCompanion.insert(
          id: _uuid.v4(),
          metricCode: metricCode,
          targetOperator: targetOperator,
          targetValue: targetValue,
          warningValue: Value(warningValue),
          userParam1Satang: Value(userParam1Satang),
          userParam2Satang: Value(userParam2Satang),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  // -------------------------------------------------------------
  // 2. DATA AGGREGATION FOR 8 METRICS
  // -------------------------------------------------------------

  /// Liquid assets = Cash + all Bank accounts in all currencies converted to THB
  Future<int> getLiquidAssetsSatang() async {
    final accounts = await db.accountsDao.getActiveAccounts();
    int totalLiquidSatang = 0;

    for (final acc in accounts) {
      if (acc.accountType == 'bank' || acc.accountType == 'cash' || acc.accountType == 'fcd') {
        final breakdown = await db.accountsDao.getAccountBalanceBreakdown(acc.id);
        if (breakdown.thbEquivalentSatang > 0) {
          totalLiquidSatang += breakdown.thbEquivalentSatang;
        }
      }
    }

    return totalLiquidSatang;
  }

  /// Total assets = Positive bank balances + Portfolio Market Value (Mark-to-market)
  Future<int> getTotalAssetsSatang() async {
    final liquid = await getLiquidAssetsSatang();
    final portfolioSummary = await db.investmentsDao.getPortfolioSummary();
    final portValue = portfolioSummary.totalValueThbSatang;

    return liquid + portValue;
  }

  /// 6-month average true expense (excluding transfers and investment purchases)
  Future<int> getAverageMonthlyExpenseSatang({int months = 6}) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months, now.day);

    final expenseRows = await (select(transactions)
          ..where((t) =>
              t.transactionType.equals('expense') &
              t.transactionDate.isBiggerOrEqualValue(startDate) &
              t.transactionDate.isSmallerOrEqualValue(now) &
              t.deletedAt.isNull() &
              (t.tag.isNull() | t.tag.like('investment_buy:%').not())))
        .get();

    int sum = 0;
    for (final row in expenseRows) {
      sum += row.amountThbSatang;
    }

    return months > 0 ? (sum / months).round() : sum;
  }

  /// 6-month average true income (excluding transfers and investment sells)
  Future<int> getAverageMonthlyIncomeSatang({int months = 6}) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months, now.day);

    final incomeRows = await (select(transactions)
          ..where((t) =>
              t.transactionType.equals('income') &
              t.isCleared.equals(true) &
              t.transactionDate.isBiggerOrEqualValue(startDate) &
              t.transactionDate.isSmallerOrEqualValue(now) &
              t.deletedAt.isNull() &
              (t.tag.isNull() | t.tag.like('investment_sell:%').not())))
        .get();

    int sum = 0;
    for (final row in incomeRows) {
      sum += row.amountThbSatang;
    }

    return months > 0 ? (sum / months).round() : sum;
  }

  /// Current month income, expense, and investment additions
  Future<({int incomeSatang, int expenseSatang, int investmentSatang})> getCurrentMonthCashFlow() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final monthTxs = await (select(transactions)
          ..where((t) =>
              t.transactionDate.isBiggerOrEqualValue(startOfMonth) &
              t.transactionDate.isSmallerOrEqualValue(now) &
              t.deletedAt.isNull()))
        .get();

    int inc = 0;
    int exp = 0;
    int inv = 0;

    for (final t in monthTxs) {
      final isInvBuy = t.tag != null && t.tag!.startsWith('investment_buy:');
      final isInvSell = t.tag != null && t.tag!.startsWith('investment_sell:');

      if (t.transactionType == 'income' && !isInvSell && t.isCleared) {
        inc += t.amountThbSatang;
      } else if (t.transactionType == 'expense') {
        if (isInvBuy) {
          inv += t.amountThbSatang;
        } else {
          exp += t.amountThbSatang;
        }
      }
    }

    return (incomeSatang: inc, expenseSatang: exp, investmentSatang: inv);
  }

  // -------------------------------------------------------------
  // 3. FULL FINANCIAL HEALTH CALCULATION
  // -------------------------------------------------------------

  Future<FinancialHealthSummary> getFinancialHealthSummary({bool isThai = true}) async {
    // 1. Gather Assets
    final liquidAssets = await getLiquidAssetsSatang();
    final totalAssets = await getTotalAssetsSatang();

    // 2. Gather Debts
    final totalDebts = await db.liabilitiesDao.getTotalLiabilitiesSatang();
    final shortTermDebts = await db.liabilitiesDao.getShortTermLiabilitiesSatang();
    final monthlyDebtPayment = await db.liabilitiesDao.getTotalMonthlyPaymentSatang();

    // 3. Gather Cash Flow
    final avgMonthlyExpense = await getAverageMonthlyExpenseSatang(months: 6);
    final avgMonthlyIncome = await getAverageMonthlyIncomeSatang(months: 6);
    final monthFlow = await getCurrentMonthCashFlow();

    // 4. Gather Insurance
    final sumInsured = await db.insuranceDao.getTotalSumInsuredSatang();
    final medicalCoverage = await db.insuranceDao.getTotalMedicalCoverageSatang();

    // 5. Gather Investments
    final portfolioSummary = await db.investmentsDao.getPortfolioSummary();
    final portValue = portfolioSummary.totalValueThbSatang;

    // 6. User Custom Thresholds from Settings
    final generalSettings = await getSettingByMetric('general_settings');
    final estimatedMedicalCost = generalSettings?.userParam2Satang ?? 50000000; // 500k THB default
    final familyReserve = generalSettings?.userParam1Satang ?? 0;

    final basicLiqSetting = await getSettingByMetric('basic_liquidity');
    final emergSetting = await getSettingByMetric('emergency_fund');
    final dtaSetting = await getSettingByMetric('debt_to_asset');
    final dtiSetting = await getSettingByMetric('dti');
    final savingsSetting = await getSettingByMetric('savings_rate');
    final invSetting = await getSettingByMetric('investment_ratio');

    final input = FinancialHealthInputData(
      liquidAssetsSatang: liquidAssets,
      totalAssetsSatang: totalAssets,
      totalDebtsSatang: totalDebts,
      shortTermDebtsSatang: shortTermDebts,
      monthlyDebtPaymentSatang: monthlyDebtPayment,
      avgMonthlyExpenseSatang: avgMonthlyExpense,
      avgMonthlyIncomeSatang: avgMonthlyIncome,
      currentMonthIncomeSatang: monthFlow.incomeSatang,
      currentMonthExpenseSatang: monthFlow.expenseSatang,
      currentMonthInvestmentSatang: monthFlow.investmentSatang,
      portfolioMarketValueSatang: portValue,
      sumInsuredSatang: sumInsured,
      medicalCoverageSatang: medicalCoverage,
      estimatedMedicalCostSatang: estimatedMedicalCost,
      familyReserveSatang: familyReserve,
      targetBasicLiquidity: double.tryParse(basicLiqSetting?.targetValue ?? '1.0') ?? 1.0,
      targetEmergencyMonths: double.tryParse(emergSetting?.targetValue ?? '6.0') ?? 6.0,
      targetDebtToAssetPercent: double.tryParse(dtaSetting?.targetValue ?? '50.0') ?? 50.0,
      targetDtiPercent: double.tryParse(dtiSetting?.targetValue ?? '40.0') ?? 40.0,
      targetSavingsRatePercent: double.tryParse(savingsSetting?.targetValue ?? '10.0') ?? 10.0,
      targetInvestmentRatioPercent: double.tryParse(invSetting?.targetValue ?? '50.0') ?? 50.0,
    );

    return FinancialHealthCalculator.calculate(input, isThai: isThai);
  }

  // -------------------------------------------------------------
  // 4. RUN-RATE FORECASTING
  // -------------------------------------------------------------

  Future<RunRateForecast> getRunRateForecast() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);

    // Accumulated expenses this month (excluding investment buys)
    final monthTxs = await (select(transactions)
          ..where((t) =>
              t.transactionType.equals('expense') &
              t.transactionDate.isBiggerOrEqualValue(startOfMonth) &
              t.transactionDate.isSmallerOrEqualValue(now) &
              t.deletedAt.isNull() &
              (t.tag.isNull() | t.tag.like('investment_buy:%').not())))
        .get();

    int accumulatedMonthSatang = 0;
    for (final t in monthTxs) {
      accumulatedMonthSatang += t.amountThbSatang;
    }

    // Accumulated expenses this year
    final yearTxs = await (select(transactions)
          ..where((t) =>
              t.transactionType.equals('expense') &
              t.transactionDate.isBiggerOrEqualValue(startOfYear) &
              t.transactionDate.isSmallerOrEqualValue(now) &
              t.deletedAt.isNull() &
              (t.tag.isNull() | t.tag.like('investment_buy:%').not())))
        .get();

    int accumulatedYearSatang = 0;
    for (final t in yearTxs) {
      accumulatedYearSatang += t.amountThbSatang;
    }

    // Monthly budget limit
    final activeBudgets = await db.budgetsDao.getActiveBudgets();
    int totalBudgetLimit = 0;
    for (final b in activeBudgets) {
      totalBudgetLimit += b.limitSatang;
    }
    if (totalBudgetLimit <= 0) {
      // If user hasn't set budget limit, default to 6-month average expense
      totalBudgetLimit = await getAverageMonthlyExpenseSatang(months: 6);
      if (totalBudgetLimit <= 0) totalBudgetLimit = accumulatedMonthSatang;
    }

    return RunRateCalculator.calculate(
      currentDate: now,
      accumulatedMonthExpenseSatang: accumulatedMonthSatang,
      monthlyBudgetLimitSatang: totalBudgetLimit,
      accumulatedYearExpenseSatang: accumulatedYearSatang,
    );
  }
}
