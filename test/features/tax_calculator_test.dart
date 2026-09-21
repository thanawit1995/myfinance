import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/features/tax/domain/tax_calculator_engine.dart';

void main() {
  final defaultBrackets = [
    const TaxBracket(minSatang: 0, maxSatang: 15000000, ratePercent: 0.0),
    const TaxBracket(minSatang: 15000001, maxSatang: 30000000, ratePercent: 5.0),
    const TaxBracket(minSatang: 30000001, maxSatang: 50000000, ratePercent: 10.0),
    const TaxBracket(minSatang: 50000001, maxSatang: 75000000, ratePercent: 15.0),
    const TaxBracket(minSatang: 75000001, maxSatang: 100000000, ratePercent: 20.0),
    const TaxBracket(minSatang: 100000001, maxSatang: 200000000, ratePercent: 25.0),
    const TaxBracket(minSatang: 200000001, maxSatang: 500000000, ratePercent: 30.0),
    const TaxBracket(minSatang: 500000001, maxSatang: null, ratePercent: 35.0),
  ];

  final defaultDeductionLimits = {
    'socialSecurityMaxSatang': 900000,
    'lifeInsuranceMaxSatang': 10000000,
    'healthInsuranceMaxSatang': 2500000,
    'lifeAndHealthInsuranceCombinedMaxSatang': 10000000,
    'rmfMaxSatang': 50000000,
    'ssfMaxSatang': 20000000,
    'thaiEsgMaxSatang': 30000000,
    'providentFundMaxSatang': 50000000,
    'retirementGroupCombinedMaxSatang': 50000000,
    'homeLoanInterestMaxSatang': 10000000,
  };

  group('TaxCalculatorEngine Tests', () {
    test('Case 1: Standard Salary 40(1) with progressive brackets and WHT', () {
      // Salary 600,000 THB (60,000,000 satang), WHT 20,000 THB (2,000,000 satang)
      final incomes = [
        const IncomeEntry(
          taxCategory: '40_1',
          title: 'เงินเดือนประจำ',
          grossSatang: 60000000,
          withholdingTaxSatang: 2000000,
        ),
      ];

      final deductions = [
        const DeductionEntry(
          code: 'social_security',
          name: 'ประกันสังคม',
          group: 'allowance',
          amountSatang: 900000, // 9,000 THB
        ),
      ];

      final result = TaxCalculatorEngine.calculateTax(
        taxYear: 2025,
        brackets: defaultBrackets,
        incomes: incomes,
        deductions: deductions,
        personalAllowanceSatang: 6000000, // 60,000 THB
        spouseAllowanceSatang: 6000000,
        childAllowanceSatang: 3000000,
        expenseRate401And402Percent: 50.0,
        expenseMax401And402Satang: 10000000, // 100,000 THB cap
        flatExpense406MedicalPercent: 60.0,
        flatExpense408Percent: 60.0,
        deductionLimits: defaultDeductionLimits,
      );

      // Gross = 600,000 THB
      expect(result.grossIncomeSatang, 60000000);
      // Expense = 100,000 THB (50% of 600k capped at 100k)
      expect(result.expenseDeductionSatang, 10000000);
      // After expense = 500,000 THB
      expect(result.incomeAfterExpenseSatang, 50000000);
      // Deductions = 60,000 (personal) + 9,000 (social security) = 69,000 THB (6,900,000 satang)
      expect(result.totalDeductionsSatang, 6900000);
      // Net taxable = 500,000 - 69,000 = 431,000 THB (43,100,000 satang)
      expect(result.netTaxableIncomeSatang, 43100000);

      // Tax Brackets:
      // 0 - 150k @ 0% = 0
      // 150,001 - 300,000 @ 5% = 150,000 * 5% = 7,500 THB (750,000 satang)
      // 300,001 - 431,000 @ 10% = 131,000 * 10% = 13,100 THB (1,310,000 satang)
      // Total computed tax = 7,500 + 13,100 = 20,600 THB (2,060,000 satang)
      expect(result.computedTaxSatang, 2060000);

      // WHT = 20,000 THB -> Net tax due = 20,600 - 20,000 = 600 THB (60,000 satang)
      expect(result.totalWithholdingTaxSatang, 2000000);
      expect(result.netTaxDueSatang, 60000);
      expect(result.isRefund, false);
    });

    test('Case 2: 40(1) + 40(2) combined expense cap (100,000 THB)', () {
      final incomes = [
        const IncomeEntry(
          taxCategory: '40_1',
          title: 'เงินเดือน',
          grossSatang: 12000000, // 120,000 THB
        ),
        const IncomeEntry(
          taxCategory: '40_2',
          title: 'ค่าจ้างฟรีแลนซ์',
          grossSatang: 10000000, // 100,000 THB
        ),
      ];

      final result = TaxCalculatorEngine.calculateTax(
        taxYear: 2025,
        brackets: defaultBrackets,
        incomes: incomes,
        deductions: [],
        personalAllowanceSatang: 6000000,
        spouseAllowanceSatang: 6000000,
        childAllowanceSatang: 3000000,
        expenseRate401And402Percent: 50.0,
        expenseMax401And402Satang: 10000000, // 100k cap
        flatExpense406MedicalPercent: 60.0,
        flatExpense408Percent: 60.0,
        deductionLimits: defaultDeductionLimits,
      );

      // Total 40(1)+40(2) = 220,000 THB. 50% = 110,000 THB -> capped at 100,000 THB
      expect(result.expenseDeductionSatang, 10000000);
      expect(result.incomeAfterExpenseSatang, 12000000); // 220k - 100k = 120k
      expect(result.netTaxableIncomeSatang, 6000000); // 120k - 60k personal = 60k
      expect(result.computedTaxSatang, 0); // 60k is in 0-150k bracket
    });

    test('Case 3: Doctor Clinic Shift 40(6) with 60% flat expense deduction', () {
      final incomes = [
        const IncomeEntry(
          taxCategory: '40_6_medical',
          title: 'เวรคลินิก (ประกอบโรคศิลปะ)',
          grossSatang: 100000000, // 1,000,000 THB
          withholdingTaxSatang: 3000000, // 30,000 THB (3% WHT)
        ),
      ];

      final result = TaxCalculatorEngine.calculateTax(
        taxYear: 2025,
        brackets: defaultBrackets,
        incomes: incomes,
        deductions: [],
        personalAllowanceSatang: 6000000,
        spouseAllowanceSatang: 6000000,
        childAllowanceSatang: 3000000,
        expenseRate401And402Percent: 50.0,
        expenseMax401And402Satang: 10000000,
        flatExpense406MedicalPercent: 60.0, // 60% flat
        flatExpense408Percent: 60.0,
        deductionLimits: defaultDeductionLimits,
      );

      // 1,000,000 THB * 60% = 600,000 THB expense (60,000,000 satang)
      expect(result.expenseDeductionSatang, 60000000);
      expect(result.incomeAfterExpenseSatang, 40000000); // 400,000 THB
      // Net taxable = 400,000 - 60,000 personal = 340,000 THB (34,000,000 satang)
      expect(result.netTaxableIncomeSatang, 34000000);

      // Tax:
      // 0 - 150k = 0
      // 150k - 300k @ 5% = 7,500 THB
      // 300k - 340k @ 10% = 40,000 * 10% = 4,000 THB
      // Total tax = 11,500 THB (1,150,000 satang)
      expect(result.computedTaxSatang, 1150000);

      // Paid WHT 30,000 THB -> Refund = 18,500 THB (1,850,000 satang)
      expect(result.netTaxDueSatang, -1850000);
      expect(result.isRefund, true);
    });

    test('Case 4: Thai Dividend Tax Credit and Final Tax Optimization', () {
      // Income: Salary 200,000 THB + Thai Dividend 100,000 THB (with credit 20/80 = 25,000 THB, WHT 10% = 10,000 THB)
      final incomes = [
        const IncomeEntry(
          taxCategory: '40_1',
          title: 'เงินเดือน',
          grossSatang: 20000000,
        ),
        const IncomeEntry(
          taxCategory: '40_4_dividend_th',
          title: 'ปันผล PTT',
          grossSatang: 10000000, // 100,000 THB
          withholdingTaxSatang: 1000000, // 10,000 THB
          dividendTaxCreditSatang: 2500000, // 25,000 THB (corporate rate 20%)
        ),
      ];

      final optResult = TaxCalculatorEngine.compareDividendStrategy(
        taxYear: 2025,
        brackets: defaultBrackets,
        incomes: incomes,
        deductions: [],
        personalAllowanceSatang: 6000000,
        spouseAllowanceSatang: 6000000,
        childAllowanceSatang: 3000000,
        expenseRate401And402Percent: 50.0,
        expenseMax401And402Satang: 10000000,
        flatExpense406MedicalPercent: 60.0,
        flatExpense408Percent: 60.0,
        deductionLimits: defaultDeductionLimits,
      );

      // When income is low (in 0% - 5% bracket), claiming dividend tax credit yields a large tax refund.
      // Therefore, including dividends in progressive tax should be better than 10% Final Tax.
      expect(optResult.isFinalTaxBetter, false);
      expect(optResult.withDividends.totalDividendTaxCreditSatang, 2500000);
    });

    test('Case 5: Net taxable income clamps to 0 when deductions exceed income', () {
      final incomes = [
        const IncomeEntry(
          taxCategory: '40_1',
          title: 'เงินเดือนพาร์ทไทม์',
          grossSatang: 5000000, // 50,000 THB
        ),
      ];

      final deductions = [
        const DeductionEntry(
          code: 'life_insurance',
          name: 'ประกันชีวิต',
          group: 'allowance',
          amountSatang: 10000000, // 100,000 THB
        ),
      ];

      final result = TaxCalculatorEngine.calculateTax(
        taxYear: 2025,
        brackets: defaultBrackets,
        incomes: incomes,
        deductions: deductions,
        personalAllowanceSatang: 6000000, // 60,000 THB
        spouseAllowanceSatang: 6000000,
        childAllowanceSatang: 3000000,
        expenseRate401And402Percent: 50.0,
        expenseMax401And402Satang: 10000000,
        flatExpense406MedicalPercent: 60.0,
        flatExpense408Percent: 60.0,
        deductionLimits: defaultDeductionLimits,
      );

      expect(result.netTaxableIncomeSatang, 0);
      expect(result.computedTaxSatang, 0);
      expect(result.netTaxDueSatang, 0);
    });
  });
}
