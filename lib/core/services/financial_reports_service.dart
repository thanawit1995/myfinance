import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../database/daos/accounts_dao.dart';
import '../database/daos/budgets_dao.dart';
import '../database/daos/financial_health_dao.dart';
import '../database/daos/insurance_dao.dart';
import '../database/daos/investments_dao.dart';
import '../database/daos/liabilities_dao.dart';
import '../database/daos/remittances_dao.dart';
import '../database/daos/tax_dao.dart';
import '../database/daos/transactions_dao.dart';
import '../../features/financial_health/domain/models/health_metric_result.dart';
import '../../features/tax/domain/tax_calculator_engine.dart';
import '../../features/remittance/domain/remittance_assessment_engine.dart';

// -------------------------------------------------------------
// Report Data Models
// -------------------------------------------------------------

class MonthlyCategoryItem {
  final String categoryId;
  final String categoryName;
  final int actualSatang;
  final int budgetSatang;
  final int varianceSatang; // budget - actual (positive = under budget, negative = over budget)
  final double percentOfBudget;

  const MonthlyCategoryItem({
    required this.categoryId,
    required this.categoryName,
    required this.actualSatang,
    required this.budgetSatang,
    required this.varianceSatang,
    required this.percentOfBudget,
  });
}

class MonthlySummaryReport {
  final int year;
  final int month;
  final int totalIncomeSatang;
  final int totalExpenseSatang;
  final int netSavingsSatang;
  final double savingsRatePercent;
  final int previousMonthIncomeSatang;
  final int previousMonthExpenseSatang;
  final int incomeDiffSatang;
  final int expenseDiffSatang;
  final List<MonthlyCategoryItem> categories;

  const MonthlySummaryReport({
    required this.year,
    required this.month,
    required this.totalIncomeSatang,
    required this.totalExpenseSatang,
    required this.netSavingsSatang,
    required this.savingsRatePercent,
    required this.previousMonthIncomeSatang,
    required this.previousMonthExpenseSatang,
    required this.incomeDiffSatang,
    required this.expenseDiffSatang,
    required this.categories,
  });
}

class AnnualMonthItem {
  final int month;
  final int incomeSatang;
  final int expenseSatang;
  final int netSatang;

  const AnnualMonthItem({
    required this.month,
    required this.incomeSatang,
    required this.expenseSatang,
    required this.netSatang,
  });
}

class AnnualSummaryReport {
  final int year;
  final List<AnnualMonthItem> months;
  final int totalIncomeSatang;
  final int totalExpenseSatang;
  final int netSavingsSatang;
  final int previousYearIncomeSatang;
  final int previousYearExpenseSatang;
  final int previousYearNetSatang;

  const AnnualSummaryReport({
    required this.year,
    required this.months,
    required this.totalIncomeSatang,
    required this.totalExpenseSatang,
    required this.netSavingsSatang,
    required this.previousYearIncomeSatang,
    required this.previousYearExpenseSatang,
    required this.previousYearNetSatang,
  });
}

class CashFlowItem {
  final String label;
  final int amountSatang;
  final bool isInflow;

  const CashFlowItem({
    required this.label,
    required this.amountSatang,
    required this.isInflow,
  });
}

class CashFlowStatementReport {
  final DateTime startDate;
  final DateTime endDate;
  final int operatingInflowsSatang;
  final int operatingOutflowsSatang;
  final int netOperatingSatang;
  final List<CashFlowItem> operatingItems;

  final int investingInflowsSatang;
  final int investingOutflowsSatang;
  final int netInvestingSatang;
  final List<CashFlowItem> investingItems;

  final int financingInflowsSatang;
  final int financingOutflowsSatang;
  final int netFinancingSatang;
  final List<CashFlowItem> financingItems;

  final int netCashFlowSatang;

  const CashFlowStatementReport({
    required this.startDate,
    required this.endDate,
    required this.operatingInflowsSatang,
    required this.operatingOutflowsSatang,
    required this.netOperatingSatang,
    required this.operatingItems,
    required this.investingInflowsSatang,
    required this.investingOutflowsSatang,
    required this.netInvestingSatang,
    required this.investingItems,
    required this.financingInflowsSatang,
    required this.financingOutflowsSatang,
    required this.netFinancingSatang,
    required this.financingItems,
    required this.netCashFlowSatang,
  });
}

class BalanceSheetItem {
  final String name;
  final String category;
  final int valueSatang;

  const BalanceSheetItem({
    required this.name,
    required this.category,
    required this.valueSatang,
  });
}

class PersonalBalanceSheetReport {
  final DateTime asOfDate;
  final int liquidAssetsSatang;
  final int investmentAssetsSatang;
  final int personalAssetsSatang;
  final int totalAssetsSatang;
  final List<BalanceSheetItem> assetItems;

  final int shortTermLiabilitiesSatang;
  final int longTermLiabilitiesSatang;
  final int totalLiabilitiesSatang;
  final List<BalanceSheetItem> liabilityItems;

  final int netWorthSatang;

  const PersonalBalanceSheetReport({
    required this.asOfDate,
    required this.liquidAssetsSatang,
    required this.investmentAssetsSatang,
    required this.personalAssetsSatang,
    required this.totalAssetsSatang,
    required this.assetItems,
    required this.shortTermLiabilitiesSatang,
    required this.longTermLiabilitiesSatang,
    required this.totalLiabilitiesSatang,
    required this.liabilityItems,
    required this.netWorthSatang,
  });
}

class HoldingReportItem {
  final String symbol;
  final String name;
  final String assetType;
  final Decimal units;
  final int costSatang;
  final int marketValueSatang;
  final int unrealizedGainLossSatang;
  final double returnPercent;

  const HoldingReportItem({
    required this.symbol,
    required this.name,
    required this.assetType,
    required this.units,
    required this.costSatang,
    required this.marketValueSatang,
    required this.unrealizedGainLossSatang,
    required this.returnPercent,
  });
}

class InvestmentPortfolioReport {
  final int totalCostSatang;
  final int totalMarketValueSatang;
  final int unrealizedGainLossSatang;
  final double unrealizedReturnPercent;
  final int realizedGainLossSatang;
  final int dividendIncomeSatang;
  final List<HoldingReportItem> holdings;

  const InvestmentPortfolioReport({
    required this.totalCostSatang,
    required this.totalMarketValueSatang,
    required this.unrealizedGainLossSatang,
    required this.unrealizedReturnPercent,
    required this.realizedGainLossSatang,
    required this.dividendIncomeSatang,
    required this.holdings,
  });
}

class RemittanceReportItem {
  final String id;
  final DateTime remittanceDate;
  final String sourceAccountName;
  final String destinationAccountName;
  final int amountOriginalSatang;
  final String currency;
  final Decimal fxRate;
  final int amountThbSatang;
  final int? taxYearEarned;
  final int taxYearRemitted;
  final bool isPrincipal;
  final bool isTaxable;
  final String statusLabel;

  const RemittanceReportItem({
    required this.id,
    required this.remittanceDate,
    required this.sourceAccountName,
    required this.destinationAccountName,
    required this.amountOriginalSatang,
    required this.currency,
    required this.fxRate,
    required this.amountThbSatang,
    required this.taxYearEarned,
    required this.taxYearRemitted,
    required this.isPrincipal,
    required this.isTaxable,
    required this.statusLabel,
  });
}

class TaxIncomeTransactionDetail {
  final String transactionId;
  final DateTime transactionDate;
  final String taxCategory;
  final String description;
  final int amountThbSatang;
  final int withholdingTaxSatang;

  const TaxIncomeTransactionDetail({
    required this.transactionId,
    required this.transactionDate,
    required this.taxCategory,
    required this.description,
    required this.amountThbSatang,
    required this.withholdingTaxSatang,
  });
}

class TaxPreparationReport {
  final int taxYear;
  final int daysInThailand;
  final Map<String, int> grossByCategorySatang;
  final int totalGrossIncomeSatang;
  final int totalExpenseDeductionsSatang;
  final int totalAllowancesSatang;
  final int netTaxableIncomeSatang;
  final int computedTaxSatang;
  final int totalWithholdingTaxSatang;
  final int totalDividendTaxCreditSatang;
  final int netTaxDueSatang;
  final bool isRefund;
  final List<BracketCalculationRow> bracketRows;
  final List<String> calculationSteps;
  final List<RemittanceReportItem> remittances;
  final DividendOptimizationResult dividendOptimization;
  final List<TaxIncomeTransactionDetail> incomeTransactions;
  final List<DeductionEntry> deductions;
  final int totalRemittanceSatang;
  final int totalRemittanceTaxableSatang;
  final int totalRemittancePrincipalSatang;

  const TaxPreparationReport({
    required this.taxYear,
    required this.daysInThailand,
    required this.grossByCategorySatang,
    required this.totalGrossIncomeSatang,
    required this.totalExpenseDeductionsSatang,
    required this.totalAllowancesSatang,
    required this.netTaxableIncomeSatang,
    required this.computedTaxSatang,
    required this.totalWithholdingTaxSatang,
    required this.totalDividendTaxCreditSatang,
    required this.netTaxDueSatang,
    required this.isRefund,
    required this.bracketRows,
    required this.calculationSteps,
    required this.remittances,
    required this.dividendOptimization,
    this.incomeTransactions = const [],
    this.deductions = const [],
    this.totalRemittanceSatang = 0,
    this.totalRemittanceTaxableSatang = 0,
    this.totalRemittancePrincipalSatang = 0,
  });
}

// -------------------------------------------------------------
// Financial Reports Service
// -------------------------------------------------------------

class FinancialReportsService {
  final AppDatabase db;
  final TransactionsDao transactionsDao;
  final BudgetsDao budgetsDao;
  final InvestmentsDao investmentsDao;
  final AccountsDao accountsDao;
  final LiabilitiesDao liabilitiesDao;
  final InsuranceDao insuranceDao;
  final TaxDao taxDao;
  final RemittancesDao remittancesDao;
  final FinancialHealthDao financialHealthDao;

  FinancialReportsService({
    required this.db,
    required this.transactionsDao,
    required this.budgetsDao,
    required this.investmentsDao,
    required this.accountsDao,
    required this.liabilitiesDao,
    required this.insuranceDao,
    required this.taxDao,
    required this.remittancesDao,
    required this.financialHealthDao,
  });

  /// 1. Monthly Summary Report
  Future<MonthlySummaryReport> generateMonthlySummary(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 1);

    final txList = await transactionsDao.searchTransactions(
      startDate: start,
      endDate: end.subtract(const Duration(milliseconds: 1)),
    );

    int income = 0;
    int expense = 0;
    final categoryActuals = <String, int>{};

    for (final tx in txList) {
      if (tx.transactionType == 'income') {
        income += tx.amountThbSatang;
      } else if (tx.transactionType == 'expense') {
        final total = tx.amountThbSatang + tx.feeThbSatang;
        expense += total;
        final catId = tx.categoryId ?? 'uncategorized';
        categoryActuals[catId] = (categoryActuals[catId] ?? 0) + total;
      }
    }

    final netSavings = income - expense;
    final savingsRate = income > 0 ? (netSavings / income) * 100.0 : 0.0;

    // Previous month comparison
    final prevYear = month == 1 ? year - 1 : year;
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevStart = DateTime(prevYear, prevMonth, 1);
    final prevEnd = DateTime(month == 1 ? year : year, month, 1);

    final prevTxList = await transactionsDao.searchTransactions(
      startDate: prevStart,
      endDate: prevEnd.subtract(const Duration(milliseconds: 1)),
    );

    int prevIncome = 0;
    int prevExpense = 0;
    for (final tx in prevTxList) {
      if (tx.transactionType == 'income') {
        prevIncome += tx.amountThbSatang;
      } else if (tx.transactionType == 'expense') {
        prevExpense += (tx.amountThbSatang + tx.feeThbSatang);
      }
    }

    // Budgets comparison
    final budgetStatuses = await budgetsDao.getBudgetStatusForMonth(year, month);
    final budgetMap = {for (final b in budgetStatuses) b.categoryId: b};

    final allCategories = await db.select(db.categories).get();
    final catLookup = {for (final c in allCategories) c.id: c};

    final categoryItems = <MonthlyCategoryItem>[];
    final allCategoryIds = {...categoryActuals.keys, ...budgetMap.keys};

    for (final catId in allCategoryIds) {
      final actual = categoryActuals[catId] ?? 0;
      final budget = budgetMap[catId]?.limitSatang ?? 0;
      final cat = catLookup[catId];
      final name = cat?.nameTh ?? (catId == 'uncategorized' ? 'ไม่ระบุหมวดหมู่' : 'หมวดหมู่อื่นๆ');

      categoryItems.add(MonthlyCategoryItem(
        categoryId: catId,
        categoryName: name,
        actualSatang: actual,
        budgetSatang: budget,
        varianceSatang: budget - actual,
        percentOfBudget: budget > 0 ? (actual / budget) * 100.0 : 0.0,
      ));
    }

    categoryItems.sort((a, b) => b.actualSatang.compareTo(a.actualSatang));

    return MonthlySummaryReport(
      year: year,
      month: month,
      totalIncomeSatang: income,
      totalExpenseSatang: expense,
      netSavingsSatang: netSavings,
      savingsRatePercent: savingsRate,
      previousMonthIncomeSatang: prevIncome,
      previousMonthExpenseSatang: prevExpense,
      incomeDiffSatang: income - prevIncome,
      expenseDiffSatang: expense - prevExpense,
      categories: categoryItems,
    );
  }

  /// 2. Annual Summary Report (12 months)
  Future<AnnualSummaryReport> generateAnnualSummary(int year) async {
    final months = <AnnualMonthItem>[];
    int totalIncome = 0;
    int totalExpense = 0;

    for (int m = 1; m <= 12; m++) {
      final start = DateTime(year, m, 1);
      final end = DateTime(m == 12 ? year + 1 : year, m == 12 ? 1 : m + 1, 1);

      final txList = await transactionsDao.searchTransactions(
        startDate: start,
        endDate: end.subtract(const Duration(milliseconds: 1)),
      );

      int mIncome = 0;
      int mExpense = 0;
      for (final tx in txList) {
        if (tx.transactionType == 'income') {
          mIncome += tx.amountThbSatang;
        } else if (tx.transactionType == 'expense') {
          mExpense += (tx.amountThbSatang + tx.feeThbSatang);
        }
      }

      totalIncome += mIncome;
      totalExpense += mExpense;
      months.add(AnnualMonthItem(
        month: m,
        incomeSatang: mIncome,
        expenseSatang: mExpense,
        netSatang: mIncome - mExpense,
      ));
    }

    // Previous year totals
    final prevYear = year - 1;
    final prevStart = DateTime(prevYear, 1, 1);
    final prevEnd = DateTime(year, 1, 1);
    final prevTxList = await transactionsDao.searchTransactions(
      startDate: prevStart,
      endDate: prevEnd.subtract(const Duration(milliseconds: 1)),
    );

    int prevTotalIncome = 0;
    int prevTotalExpense = 0;
    for (final tx in prevTxList) {
      if (tx.transactionType == 'income') {
        prevTotalIncome += tx.amountThbSatang;
      } else if (tx.transactionType == 'expense') {
        prevTotalExpense += (tx.amountThbSatang + tx.feeThbSatang);
      }
    }

    return AnnualSummaryReport(
      year: year,
      months: months,
      totalIncomeSatang: totalIncome,
      totalExpenseSatang: totalExpense,
      netSavingsSatang: totalIncome - totalExpense,
      previousYearIncomeSatang: prevTotalIncome,
      previousYearExpenseSatang: prevTotalExpense,
      previousYearNetSatang: prevTotalIncome - prevTotalExpense,
    );
  }

  /// 3. Cash Flow Statement (Arbitrary date range)
  Future<CashFlowStatementReport> generateCashFlowStatement(DateTime startDate, DateTime endDate) async {
    final txList = await transactionsDao.searchTransactions(
      startDate: startDate,
      endDate: endDate,
    );

    final opItems = <CashFlowItem>[];
    final invItems = <CashFlowItem>[];
    final finItems = <CashFlowItem>[];

    int opIn = 0;
    int opOut = 0;
    int invIn = 0;
    int invOut = 0;
    int finIn = 0;
    int finOut = 0;

    for (final tx in txList) {
      final note = tx.note?.isNotEmpty == true ? tx.note! : 'รายการทางการเงิน';
      if (tx.transactionType == 'income') {
        if (tx.taxCategory == '40_4_dividend_th' ||
            tx.taxCategory == '40_4_dividend_foreign' ||
            tx.taxCategory == '40_4_interest') {
          invIn += tx.amountThbSatang;
          invItems.add(CashFlowItem(label: note, amountSatang: tx.amountThbSatang, isInflow: true));
        } else {
          opIn += tx.amountThbSatang;
          opItems.add(CashFlowItem(label: note, amountSatang: tx.amountThbSatang, isInflow: true));
        }
      } else if (tx.transactionType == 'expense') {
        final amount = tx.amountThbSatang + tx.feeThbSatang;
        opOut += amount;
        opItems.add(CashFlowItem(label: note, amountSatang: amount, isInflow: false));
      } else if (tx.transactionType == 'transfer') {
        // Checking if related to debt payoff or investment
        if (tx.tag?.contains('investment') == true) {
          invOut += tx.amountThbSatang;
          invItems.add(CashFlowItem(label: 'ลงทุน / โอนเงินไปพอร์ต: $note', amountSatang: tx.amountThbSatang, isInflow: false));
        } else if (tx.tag?.contains('loan') == true || tx.tag?.contains('debt') == true) {
          finOut += tx.amountThbSatang;
          finItems.add(CashFlowItem(label: 'ชำระคืนเงินกู้ / หนี้: $note', amountSatang: tx.amountThbSatang, isInflow: false));
        }
      }
    }

    final netOp = opIn - opOut;
    final netInv = invIn - invOut;
    final netFin = finIn - finOut;
    final netCash = netOp + netInv + netFin;

    return CashFlowStatementReport(
      startDate: startDate,
      endDate: endDate,
      operatingInflowsSatang: opIn,
      operatingOutflowsSatang: opOut,
      netOperatingSatang: netOp,
      operatingItems: opItems,
      investingInflowsSatang: invIn,
      investingOutflowsSatang: invOut,
      netInvestingSatang: netInv,
      investingItems: invItems,
      financingInflowsSatang: finIn,
      financingOutflowsSatang: finOut,
      netFinancingSatang: netFin,
      financingItems: finItems,
      netCashFlowSatang: netCash,
    );
  }

  /// 4. Personal Balance Sheet
  Future<PersonalBalanceSheetReport> generatePersonalBalanceSheet(DateTime asOfDate) async {
    final activeAccounts = await accountsDao.getActiveAccounts();
    final usdRate = await accountsDao.getLatestUsdFxRate();

    int liquidAssets = 0;
    int shortTermLiabilities = 0;
    final assetItems = <BalanceSheetItem>[];
    final liabilityItems = <BalanceSheetItem>[];

    for (final acc in activeAccounts) {
      final balance = await accountsDao.getAccountBalanceSatang(acc.id);
      int thbValue = balance;
      if (acc.currencyCode != 'THB') {
        thbValue = (Decimal.fromInt(balance) * usdRate).toBigInt().toInt();
      }

      if (acc.accountType == 'credit_card') {
        final debt = thbValue < 0 ? -thbValue : 0;
        if (debt > 0) {
          shortTermLiabilities += debt;
          liabilityItems.add(BalanceSheetItem(name: acc.name, category: 'บัตรเครดิต', valueSatang: debt));
        }
      } else {
        if (thbValue > 0) {
          liquidAssets += thbValue;
          assetItems.add(BalanceSheetItem(name: acc.name, category: 'เงินฝาก/เงินสด', valueSatang: thbValue));
        }
      }
    }

    // Investments
    final portfolio = await investmentsDao.getPortfolioSummary();
    final investmentAssets = portfolio.totalValueThbSatang;
    if (investmentAssets > 0) {
      assetItems.add(BalanceSheetItem(name: 'พอร์ตการลงทุนรวม', category: 'สินทรัพย์ลงทุน', valueSatang: investmentAssets));
    }

    // Personal / Insurance Assets
    final policies = await insuranceDao.getActivePolicies();
    int personalAssets = 0;
    for (final p in policies) {
      if (p.sumInsuredSatang > 0) {
        personalAssets += p.sumInsuredSatang;
        assetItems.add(BalanceSheetItem(
          name: '${p.policyName} (${p.insuranceType})',
          category: 'ความคุ้มครองกรมธรรม์',
          valueSatang: p.sumInsuredSatang,
        ));
      }
    }

    // Long-term Liabilities
    final liabilities = await liabilitiesDao.getActiveLiabilities();
    int longTermLiabilities = 0;
    for (final l in liabilities) {
      if (l.liabilityType != 'credit_card') {
        longTermLiabilities += l.remainingPrincipalSatang;
        liabilityItems.add(BalanceSheetItem(name: l.name, category: l.liabilityType, valueSatang: l.remainingPrincipalSatang));
      }
    }

    final totalAssets = liquidAssets + investmentAssets + personalAssets;
    final totalLiabilities = shortTermLiabilities + longTermLiabilities;
    final netWorth = totalAssets - totalLiabilities;

    return PersonalBalanceSheetReport(
      asOfDate: asOfDate,
      liquidAssetsSatang: liquidAssets,
      investmentAssetsSatang: investmentAssets,
      personalAssetsSatang: personalAssets,
      totalAssetsSatang: totalAssets,
      assetItems: assetItems,
      shortTermLiabilitiesSatang: shortTermLiabilities,
      longTermLiabilitiesSatang: longTermLiabilities,
      totalLiabilitiesSatang: totalLiabilities,
      liabilityItems: liabilityItems,
      netWorthSatang: netWorth,
    );
  }

  /// 5. Investment Portfolio Report
  Future<InvestmentPortfolioReport> generateInvestmentPortfolioReport() async {
    final summary = await investmentsDao.getPortfolioSummary();
    final realizedList = await investmentsDao.getRealizedGainLossByYear();
    final totalRealized = realizedList.fold<int>(0, (sum, r) => sum + r.totalRealizedGainLossThbSatang);

    // Dividend income total
    final allTx = await transactionsDao.getRecentTransactions(limit: 500);
    int dividendIncome = 0;
    for (final tx in allTx) {
      if (tx.taxCategory == '40_4_dividend_th' || tx.taxCategory == '40_4_dividend_foreign') {
        dividendIncome += tx.amountThbSatang;
      }
    }

    final holdings = <HoldingReportItem>[];
    for (final h in summary.holdings) {
      final retPct = h.totalCostThbSatang > 0
          ? (h.totalUnrealizedGainLossThbSatang / h.totalCostThbSatang) * 100.0
          : 0.0;

      holdings.add(HoldingReportItem(
        symbol: h.asset.symbol,
        name: h.asset.name,
        assetType: h.asset.assetType,
        units: h.totalQuantity,
        costSatang: h.totalCostThbSatang,
        marketValueSatang: h.currentValueThbSatang,
        unrealizedGainLossSatang: h.totalUnrealizedGainLossThbSatang,
        returnPercent: retPct,
      ));
    }

    final totalRetPct = summary.totalCostThbSatang > 0
        ? (summary.totalUnrealizedGainLossThbSatang / summary.totalCostThbSatang) * 100.0
        : 0.0;

    return InvestmentPortfolioReport(
      totalCostSatang: summary.totalCostThbSatang,
      totalMarketValueSatang: summary.totalValueThbSatang,
      unrealizedGainLossSatang: summary.totalUnrealizedGainLossThbSatang,
      unrealizedReturnPercent: totalRetPct,
      realizedGainLossSatang: totalRealized,
      dividendIncomeSatang: dividendIncome,
      holdings: holdings,
    );
  }

  /// 6. Tax Preparation Bundle Report
  Future<TaxPreparationReport> generateTaxPreparationReport(int taxYear) async {
    // 1. Fetch Tax Rules
    var rule = await taxDao.getTaxRule(taxYear);
    if (rule == null) {
      final defaultRule = await taxDao.getActiveTaxRule();
      rule = defaultRule;
    }

    final brackets = <TaxBracket>[];
    if (rule != null) {
      final list = jsonDecode(rule.bracketsJson) as List;
      for (final item in list) {
        brackets.add(TaxBracket.fromJson(item as Map<String, dynamic>));
      }
    }

    final deductionLimits = rule != null
        ? jsonDecode(rule.deductionLimitsJson) as Map<String, dynamic>
        : <String, dynamic>{};

    // 2. Fetch Residency
    final residency = await taxDao.getTaxResidency(taxYear);
    final daysInTh = residency?.daysInThailand ?? 365;

    // 3. Incomes for the year
    final start = DateTime(taxYear, 1, 1);
    final end = DateTime(taxYear, 12, 31, 23, 59, 59);

    final txList = await transactionsDao.searchTransactions(
      startDate: start,
      endDate: end,
    );

    final incomeEntries = <IncomeEntry>[];
    final incomeTxDetails = <TaxIncomeTransactionDetail>[];
    final grossByCategory = <String, int>{};
    int gpfSatang = 0;
    int lifeInsuranceSatang = 0;

    for (final tx in txList) {
      if (tx.transactionType == 'income') {
        final cat = tx.taxCategory ?? '40_8';
        final gross = tx.amountThbSatang;
        final wht = tx.withholdingTaxSatang;

        grossByCategory[cat] = (grossByCategory[cat] ?? 0) + gross;

        incomeEntries.add(IncomeEntry(
          taxCategory: cat,
          title: tx.note ?? 'รายได้',
          grossSatang: gross,
          withholdingTaxSatang: wht,
          dividendTaxCreditSatang: cat == '40_4_dividend_th' ? (gross * 0.25).round() : 0, // 20/80 = 25% credit default
        ));

        incomeTxDetails.add(TaxIncomeTransactionDetail(
          transactionId: tx.id,
          transactionDate: tx.transactionDate,
          taxCategory: cat,
          description: tx.note?.isNotEmpty == true ? tx.note! : 'รายได้',
          amountThbSatang: gross,
          withholdingTaxSatang: wht,
        ));
      } else if (tx.transactionType == 'expense') {
        final tag = tx.tag ?? '';
        final note = (tx.note ?? '').toLowerCase();
        if (tag.contains('deduction:gpf') || note.contains('กบข') || note.contains('gpf')) {
          gpfSatang += tx.amountThbSatang;
        } else if (tag.contains('deduction:life_insurance') || note.contains('ประกันออมทรัพย์')) {
          lifeInsuranceSatang += tx.amountThbSatang;
        }
      }
    }

    // 4. Foreign Remittances
    final remList = await remittancesDao.getRemittancesForYear(taxYear);
    final allAccounts = await accountsDao.getAllAccounts();
    final accMap = {for (final a in allAccounts) a.id: a};

    final remItems = <RemittanceReportItem>[];
    int totalRemittanceSatang = 0;
    int totalRemittanceTaxableSatang = 0;
    int totalRemittancePrincipalSatang = 0;

    for (final r in remList) {
      final remittedYear = r.taxYearRemitted ?? taxYear;
      final assess = RemittanceAssessmentEngine.assessRemittance(
        isPrincipal: r.isPrincipal,
        taxYearEarned: r.taxYearEarned,
        taxYearRemitted: remittedYear,
        daysInThailandYearRemitted: daysInTh,
      );

      if (assess.isTaxable) {
        grossByCategory['foreign_taxable'] = (grossByCategory['foreign_taxable'] ?? 0) + r.amountThbSatang;
        incomeEntries.add(IncomeEntry(
          taxCategory: 'foreign_taxable',
          title: 'เงินได้ต่างประเทศนำเข้าไทย (${r.currencyCode})',
          grossSatang: r.amountThbSatang,
        ));
        totalRemittanceTaxableSatang += r.amountThbSatang;
      } else {
        totalRemittancePrincipalSatang += r.amountThbSatang;
      }
      totalRemittanceSatang += r.amountThbSatang;

      remItems.add(RemittanceReportItem(
        id: r.id,
        remittanceDate: r.remittanceDate,
        sourceAccountName: accMap[r.sourceAccountId]?.name ?? 'บัญชีต่างประเทศ',
        destinationAccountName: accMap[r.destinationAccountId]?.name ?? 'บัญชีไทย',
        amountOriginalSatang: r.amountOriginalSatang,
        currency: r.currencyCode,
        fxRate: Decimal.parse(r.fxRate),
        amountThbSatang: r.amountThbSatang,
        taxYearEarned: r.taxYearEarned,
        taxYearRemitted: remittedYear,
        isPrincipal: r.isPrincipal,
        isTaxable: assess.isTaxable,
        statusLabel: assess.statusLabel,
      ));
    }

    // 5. Deductions
    final savedDeductions = await taxDao.getDeductionsForYear(taxYear);
    final deductionEntries = <DeductionEntry>[];

    for (final d in savedDeductions) {
      deductionEntries.add(DeductionEntry(
        code: d.deductionType,
        name: d.deductionType,
        group: d.deductionGroup,
        amountSatang: d.amountSatang,
      ));
    }

    if (gpfSatang > 0) {
      deductionEntries.add(DeductionEntry(
        code: 'gpf',
        name: 'เงินสะสม กบข.',
        group: 'fund',
        amountSatang: gpfSatang,
      ));
    }

    if (lifeInsuranceSatang > 0) {
      deductionEntries.add(DeductionEntry(
        code: 'life_insurance',
        name: 'เบี้ยประกันชีวิต/ประกันออมทรัพย์',
        group: 'insurance',
        amountSatang: lifeInsuranceSatang,
      ));
    }

    // 6. Run Tax Engine
    final calcResult = TaxCalculatorEngine.calculateTax(
      taxYear: taxYear,
      brackets: brackets,
      incomes: incomeEntries,
      deductions: deductionEntries,
      personalAllowanceSatang: rule?.personalAllowanceSatang ?? 6000000,
      spouseAllowanceSatang: rule?.spouseAllowanceSatang ?? 6000000,
      childAllowanceSatang: rule?.childAllowanceSatang ?? 3000000,
      expenseRate401And402Percent: double.tryParse(rule?.expenseRatePercent ?? '50.0') ?? 50.0,
      expenseMax401And402Satang: rule?.expenseMaxSatang ?? 10000000,
      flatExpense406MedicalPercent: double.tryParse(rule?.flatExpense406MedicalPercent ?? '60.0') ?? 60.0,
      flatExpense408Percent: double.tryParse(rule?.flatExpense408Percent ?? '60.0') ?? 60.0,
      deductionLimits: deductionLimits,
      includeThaiDividends: true,
    );

    final opt = TaxCalculatorEngine.compareDividendStrategy(
      taxYear: taxYear,
      brackets: brackets,
      incomes: incomeEntries,
      deductions: deductionEntries,
      personalAllowanceSatang: rule?.personalAllowanceSatang ?? 6000000,
      spouseAllowanceSatang: rule?.spouseAllowanceSatang ?? 6000000,
      childAllowanceSatang: rule?.childAllowanceSatang ?? 3000000,
      expenseRate401And402Percent: double.tryParse(rule?.expenseRatePercent ?? '50.0') ?? 50.0,
      expenseMax401And402Satang: rule?.expenseMaxSatang ?? 10000000,
      flatExpense406MedicalPercent: double.tryParse(rule?.flatExpense406MedicalPercent ?? '60.0') ?? 60.0,
      flatExpense408Percent: double.tryParse(rule?.flatExpense408Percent ?? '60.0') ?? 60.0,
      deductionLimits: deductionLimits,
    );

    return TaxPreparationReport(
      taxYear: taxYear,
      daysInThailand: daysInTh,
      grossByCategorySatang: grossByCategory,
      totalGrossIncomeSatang: calcResult.grossIncomeSatang,
      totalExpenseDeductionsSatang: calcResult.expenseDeductionSatang,
      totalAllowancesSatang: calcResult.totalDeductionsSatang,
      netTaxableIncomeSatang: calcResult.netTaxableIncomeSatang,
      computedTaxSatang: calcResult.computedTaxSatang,
      totalWithholdingTaxSatang: calcResult.totalWithholdingTaxSatang,
      totalDividendTaxCreditSatang: calcResult.totalDividendTaxCreditSatang,
      netTaxDueSatang: calcResult.netTaxDueSatang,
      isRefund: calcResult.isRefund,
      bracketRows: calcResult.bracketRows,
      calculationSteps: calcResult.calculationSteps,
      remittances: remItems,
      dividendOptimization: opt,
      incomeTransactions: incomeTxDetails,
      deductions: deductionEntries,
      totalRemittanceSatang: totalRemittanceSatang,
      totalRemittanceTaxableSatang: totalRemittanceTaxableSatang,
      totalRemittancePrincipalSatang: totalRemittancePrincipalSatang,
    );
  }

  /// 7. Financial Health Report
  Future<FinancialHealthSummary> generateFinancialHealthReport() {
    return financialHealthDao.getFinancialHealthSummary();
  }
}

final financialReportsServiceProvider = Provider<FinancialReportsService>((ref) {
  return FinancialReportsService(
    db: ref.watch(databaseProvider),
    transactionsDao: ref.watch(transactionsDaoProvider),
    budgetsDao: ref.watch(budgetsDaoProvider),
    investmentsDao: ref.watch(investmentsDaoProvider),
    accountsDao: ref.watch(accountsDaoProvider),
    liabilitiesDao: ref.watch(liabilitiesDaoProvider),
    insuranceDao: ref.watch(insuranceDaoProvider),
    taxDao: ref.watch(taxDaoProvider),
    remittancesDao: ref.watch(remittancesDaoProvider),
    financialHealthDao: ref.watch(financialHealthDaoProvider),
  );
});

