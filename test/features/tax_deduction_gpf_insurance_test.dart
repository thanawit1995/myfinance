import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/daos/accounts_dao.dart';
import 'package:myfinance/core/database/daos/budgets_dao.dart';
import 'package:myfinance/core/database/daos/financial_health_dao.dart';
import 'package:myfinance/core/database/daos/insurance_dao.dart';
import 'package:myfinance/core/database/daos/investments_dao.dart';
import 'package:myfinance/core/database/daos/liabilities_dao.dart';
import 'package:myfinance/core/database/daos/remittances_dao.dart';
import 'package:myfinance/core/database/daos/tax_dao.dart';
import 'package:myfinance/core/database/daos/transactions_dao.dart';
import 'package:myfinance/core/services/financial_reports_service.dart';
import 'package:myfinance/features/tax/domain/tax_calculator_engine.dart';

void main() {
  group('Tax Deduction GPF & Insurance Tests', () {
    const brackets = [
      TaxBracket(minSatang: 0, maxSatang: 15000000, ratePercent: 0),
      TaxBracket(minSatang: 15000000, maxSatang: 30000000, ratePercent: 5),
      TaxBracket(minSatang: 30000000, maxSatang: 50000000, ratePercent: 10),
      TaxBracket(minSatang: 50000000, maxSatang: 75000000, ratePercent: 15),
      TaxBracket(minSatang: 75000000, maxSatang: 100000000, ratePercent: 20),
      TaxBracket(minSatang: 100000000, maxSatang: 200000000, ratePercent: 25),
      TaxBracket(minSatang: 200000000, maxSatang: 500000000, ratePercent: 30),
      TaxBracket(minSatang: 500000000, maxSatang: null, ratePercent: 35),
    ];

    test('TaxCalculatorEngine correctly applies GPF and Life Insurance deductions', () {
      // Gross 40(1) income 1,200,000 THB = 120,000,000 satang
      final incomes = [
        const IncomeEntry(
          taxCategory: '40_1',
          title: 'เงินเดือนทั้งปี',
          grossSatang: 120000000,
        ),
      ];

      // Standard expense deduction: 50% max 100,000 THB = 10,000,000 satang
      // Personal allowance: 60,000 THB = 6,000,000 satang
      // Income after expense: 120,000,000 - 10,000,000 = 110,000,000 satang
      // Without extra deductions: taxable income = 110,000,000 - 6,000,000 = 104,000,000 satang

      final withoutDeductions = TaxCalculatorEngine.calculateTax(
        taxYear: 2025,
        brackets: brackets,
        incomes: incomes,
        deductions: [],
        personalAllowanceSatang: 6000000,
        spouseAllowanceSatang: 6000000,
        childAllowanceSatang: 3000000,
        expenseRate401And402Percent: 50.0,
        expenseMax401And402Satang: 10000000,
        flatExpense406MedicalPercent: 60.0,
        flatExpense408Percent: 60.0,
        deductionLimits: {},
        includeThaiDividends: true,
      );

      expect(withoutDeductions.netTaxableIncomeSatang, 104000000);

      // Now add GPF 43,596 THB (3,633 * 12) = 4,359,600 satang
      // And Life Insurance 45,000 THB = 4,500,000 satang
      final deductions = [
        const DeductionEntry(
          code: 'gpf',
          name: 'เงินสะสม กบข.',
          group: 'fund',
          amountSatang: 4359600,
        ),
        const DeductionEntry(
          code: 'life_insurance',
          name: 'ประกันออมทรัพย์',
          group: 'insurance',
          amountSatang: 4500000,
        ),
      ];

      final withDeductions = TaxCalculatorEngine.calculateTax(
        taxYear: 2025,
        brackets: brackets,
        incomes: incomes,
        deductions: deductions,
        personalAllowanceSatang: 6000000,
        spouseAllowanceSatang: 6000000,
        childAllowanceSatang: 3000000,
        expenseRate401And402Percent: 50.0,
        expenseMax401And402Satang: 10000000,
        flatExpense406MedicalPercent: 60.0,
        flatExpense408Percent: 60.0,
        deductionLimits: {},
        includeThaiDividends: true,
      );

      // Total allowances: 6,000,000 (personal) + 4,359,600 (GPF) + 4,500,000 (Insurance) = 14,859,600 satang
      expect(withDeductions.totalDeductionsSatang, 14859600);
      expect(withDeductions.netTaxableIncomeSatang, 110000000 - 14859600);
      // Tax due must be strictly less than without deductions
      expect(withDeductions.computedTaxSatang < withoutDeductions.computedTaxSatang, isTrue);
    });

    test('FinancialReportsService automatically captures GPF and Insurance from tagged expense transactions', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final transactionsDao = TransactionsDao(db);
      final accountsDao = AccountsDao(db);
      final budgetsDao = BudgetsDao(db);
      final investmentsDao = InvestmentsDao(db);
      final liabilitiesDao = LiabilitiesDao(db);
      final insuranceDao = InsuranceDao(db);
      final taxDao = TaxDao(db);
      final remittancesDao = RemittancesDao(db);
      final financialHealthDao = FinancialHealthDao(db);

      final reportsService = FinancialReportsService(
        db: db,
        transactionsDao: transactionsDao,
        budgetsDao: budgetsDao,
        investmentsDao: investmentsDao,
        accountsDao: accountsDao,
        liabilitiesDao: liabilitiesDao,
        insuranceDao: insuranceDao,
        taxDao: taxDao,
        remittancesDao: remittancesDao,
        financialHealthDao: financialHealthDao,
      );

      final now = DateTime(2025, 6, 15);

      // 1. Account
      await accountsDao.createAccount(
        AccountsCompanion.insert(
          id: 'acc-1',
          name: 'Main Cash',
          accountType: 'cash',
          currencyCode: 'THB',
          isDomestic: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 2. Income transaction (40_1) 500,000 THB = 50,000,000 satang
      await transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-inc-1',
          transactionType: 'income',
          sourceAccountId: const Value('acc-1'),
          amountOriginalSatang: 50000000,
          currencyCode: 'THB',
          amountThbSatang: 50000000,
          taxCategory: const Value('40_1'),
          transactionDate: DateTime(2025, 1, 25),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 3. GPF Expense: 36,330 THB = 3,633,000 satang with tag 'deduction:gpf'
      await transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-gpf-1',
          transactionType: 'expense',
          sourceAccountId: const Value('acc-1'),
          amountOriginalSatang: 3633000,
          currencyCode: 'THB',
          amountThbSatang: 3633000,
          tag: const Value('deduction:gpf'),
          note: const Value('ส่ง กบข.'),
          transactionDate: DateTime(2025, 2, 26),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 4. Insurance Expense: 45,000 THB = 4,500,000 satang with tag 'deduction:life_insurance'
      await transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-ins-1',
          transactionType: 'expense',
          sourceAccountId: const Value('acc-1'),
          amountOriginalSatang: 4500000,
          currencyCode: 'THB',
          amountThbSatang: 4500000,
          tag: const Value('deduction:life_insurance'),
          note: const Value('ประกันออมทรัพย์'),
          transactionDate: DateTime(2025, 12, 1),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 5. Generate Tax Preparation Report for 2025
      final report = await reportsService.generateTaxPreparationReport(2025);

      expect(report.taxYear, 2025);
      expect(report.totalGrossIncomeSatang, 50000000);

      // Verify deductions list contains GPF and Life Insurance
      final gpfDeduction = report.deductions.firstWhere((d) => d.code == 'gpf');
      expect(gpfDeduction.amountSatang, 3633000);

      final insDeduction = report.deductions.firstWhere((d) => d.code == 'life_insurance');
      expect(insDeduction.amountSatang, 4500000);

      // Allowances: 6,000,000 (personal) + 3,633,000 (GPF) + 4,500,000 (Insurance) = 14,133,000 satang
      expect(report.totalAllowancesSatang, 14133000);

      // Calculation steps mention GPF and Insurance
      final stepsJoined = report.calculationSteps.join('\n');
      expect(stepsJoined.contains('กบข'), isTrue);
      expect(stepsJoined.contains('ประกันชีวิตและสุขภาพ'), isTrue);

      await db.close();
    });
  });
}
