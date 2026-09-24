import 'dart:math';

class TaxBracket {
  final int minSatang;
  final int? maxSatang;
  final double ratePercent;

  const TaxBracket({
    required this.minSatang,
    required this.maxSatang,
    required this.ratePercent,
  });

  factory TaxBracket.fromJson(Map<String, dynamic> json) {
    return TaxBracket(
      minSatang: (json['minSatang'] as num).toInt(),
      maxSatang: json['maxSatang'] != null ? (json['maxSatang'] as num).toInt() : null,
      ratePercent: double.parse(json['ratePercent'].toString()),
    );
  }
}

class BracketCalculationRow {
  final String rangeLabel;
  final int taxableAmountInRangeSatang;
  final double ratePercent;
  final int taxSatang;

  const BracketCalculationRow({
    required this.rangeLabel,
    required this.taxableAmountInRangeSatang,
    required this.ratePercent,
    required this.taxSatang,
  });
}

class IncomeEntry {
  final String taxCategory; // '40_1', '40_2', '40_4_interest', '40_4_dividend_th', '40_4_dividend_foreign', '40_4_crypto', '40_4_foreign_stock_gain', '40_6_medical', '40_8', 'foreign_taxable'
  final String title;
  final int grossSatang;
  final int withholdingTaxSatang;
  final int dividendTaxCreditSatang;

  const IncomeEntry({
    required this.taxCategory,
    required this.title,
    required this.grossSatang,
    this.withholdingTaxSatang = 0,
    this.dividendTaxCreditSatang = 0,
  });
}

class DeductionEntry {
  final String code;
  final String name;
  final String group;
  final int amountSatang;

  const DeductionEntry({
    required this.code,
    required this.name,
    required this.group,
    required this.amountSatang,
  });
}

class DividendOptimizationResult {
  final TaxCalculationResult withDividends;
  final TaxCalculationResult finalTaxDividends;
  final bool isFinalTaxBetter;
  final int taxDifferenceSatang;

  const DividendOptimizationResult({
    required this.withDividends,
    required this.finalTaxDividends,
    required this.isFinalTaxBetter,
    required this.taxDifferenceSatang,
  });
}

class TaxCalculationResult {
  final int taxYear;
  final int grossIncomeSatang;
  final int expenseDeductionSatang;
  final int incomeAfterExpenseSatang;
  final int totalDeductionsSatang;
  final int netTaxableIncomeSatang;
  final int computedTaxSatang;
  final int totalWithholdingTaxSatang;
  final int totalDividendTaxCreditSatang;
  final int netTaxDueSatang; // positive = must pay, negative = refund
  final bool isRefund;
  final List<BracketCalculationRow> bracketRows;
  final List<String> calculationSteps;

  const TaxCalculationResult({
    required this.taxYear,
    required this.grossIncomeSatang,
    required this.expenseDeductionSatang,
    required this.incomeAfterExpenseSatang,
    required this.totalDeductionsSatang,
    required this.netTaxableIncomeSatang,
    required this.computedTaxSatang,
    required this.totalWithholdingTaxSatang,
    required this.totalDividendTaxCreditSatang,
    required this.netTaxDueSatang,
    required this.isRefund,
    required this.bracketRows,
    required this.calculationSteps,
  });
}

class TaxCalculatorEngine {
  /// Calculates personal income tax line-by-line based on dynamic tax rules.
  static TaxCalculationResult calculateTax({
    required int taxYear,
    required List<TaxBracket> brackets,
    required List<IncomeEntry> incomes,
    required List<DeductionEntry> deductions,
    required int personalAllowanceSatang,
    required int spouseAllowanceSatang,
    required int childAllowanceSatang,
    required double expenseRate401And402Percent,
    required int expenseMax401And402Satang,
    required double flatExpense406MedicalPercent,
    required double flatExpense408Percent,
    required Map<String, dynamic> deductionLimits,
    bool includeThaiDividends = true,
  }) {
    final steps = <String>[];
    steps.add('=== เริ่มคำนวณภาษีเงินได้บุคคลธรรมดา ประจำปีภาษี $taxYear ===');

    // 1. Calculate Gross Income per Category
    int gross401 = 0;
    int gross402 = 0;
    int gross404Interest = 0;
    int gross404DividendTh = 0;
    int gross404DividendForeign = 0;
    int gross404CapitalGains = 0;
    int gross406Medical = 0;
    int gross408 = 0;
    int grossForeignTaxable = 0;

    int totalWht = 0;
    int totalDividendCredit = 0;

    for (final inc in incomes) {
      if (inc.taxCategory == 'non_taxable') continue;

      totalWht += inc.withholdingTaxSatang;

      switch (inc.taxCategory) {
        case '40_1':
          gross401 += inc.grossSatang;
          break;
        case '40_2':
          gross402 += inc.grossSatang;
          break;
        case '40_4_interest':
          gross404Interest += inc.grossSatang;
          break;
        case '40_4_dividend_th':
          if (includeThaiDividends) {
            gross404DividendTh += inc.grossSatang;
            totalDividendCredit += inc.dividendTaxCreditSatang;
          }
          break;
        case '40_4_dividend_foreign':
          gross404DividendForeign += inc.grossSatang;
          break;
        case '40_4_crypto':
        case '40_4_foreign_stock_gain':
          gross404CapitalGains += inc.grossSatang;
          break;
        case '40_6_medical':
          gross406Medical += inc.grossSatang;
          break;
        case '40_8':
          gross408 += inc.grossSatang;
          break;
        case 'foreign_taxable':
          grossForeignTaxable += inc.grossSatang;
          break;
        default:
          gross408 += inc.grossSatang;
          break;
      }
    }

    final totalGross = gross401 +
        gross402 +
        gross404Interest +
        gross404DividendTh +
        gross404DividendForeign +
        gross404CapitalGains +
        gross406Medical +
        gross408 +
        grossForeignTaxable;

    steps.add('1. เงินได้พึงประเมินรวม: ฿${(totalGross / 100).toStringAsFixed(2)}');
    if (gross401 > 0) steps.add('  - เงินเดือน 40(1): ฿${(gross401 / 100).toStringAsFixed(2)}');
    if (gross402 > 0) steps.add('  - รับจ้างทำงานให้ 40(2): ฿${(gross402 / 100).toStringAsFixed(2)}');
    if (gross404DividendTh > 0) {
      steps.add('  - ปันผลหุ้นไทย 40(4)(ข): ฿${(gross404DividendTh / 100).toStringAsFixed(2)} (เครดิตภาษี: ฿${(totalDividendCredit / 100).toStringAsFixed(2)})');
    }
    if (gross404DividendForeign > 0) steps.add('  - ปันผลต่างประเทศ: ฿${(gross404DividendForeign / 100).toStringAsFixed(2)}');
    if (gross404CapitalGains > 0) steps.add('  - กำไรหุ้นต่างประเทศ/คริปโต 40(4): ฿${(gross404CapitalGains / 100).toStringAsFixed(2)}');
    if (gross406Medical > 0) steps.add('  - วิชาชีพอิสระ (แพทย์/การประกอบโรคศิลปะ) 40(6): ฿${(gross406Medical / 100).toStringAsFixed(2)}');
    if (gross408 > 0) steps.add('  - ธุรกิจ/อื่นๆ 40(8): ฿${(gross408 / 100).toStringAsFixed(2)}');
    if (grossForeignTaxable > 0) steps.add('  - เงินได้ต่างประเทศนำเข้าไทยที่เข้าเกณฑ์: ฿${(grossForeignTaxable / 100).toStringAsFixed(2)}');

    // 2. Calculate Expense Deductions
    // 40(1) + 40(2) Combined (Max 100,000 THB)
    final combined401And402 = gross401 + gross402;
    int exp401And402 = 0;
    if (combined401And402 > 0) {
      final calc = (combined401And402 * (expenseRate401And402Percent / 100.0)).round();
      exp401And402 = min(calc, expenseMax401And402Satang);
      steps.add('2. หักค่าใช้จ่าย 40(1)+(2): ฿${(exp401And402 / 100).toStringAsFixed(2)} (อัตรา $expenseRate401And402Percent% เพดาน ฿${(expenseMax401And402Satang / 100).toStringAsFixed(2)})');
    }

    // 40(6) Medical: Flat 60%
    int exp406 = 0;
    if (gross406Medical > 0) {
      exp406 = (gross406Medical * (flatExpense406MedicalPercent / 100.0)).round();
      steps.add('  - หักค่าใช้จ่าย 40(6) การประกอบโรคศิลปะ ($flatExpense406MedicalPercent%): ฿${(exp406 / 100).toStringAsFixed(2)}');
    }

    // 40(8): Flat 60%
    int exp408 = 0;
    if (gross408 > 0) {
      exp408 = (gross408 * (flatExpense408Percent / 100.0)).round();
      steps.add('  - หักค่าใช้จ่าย 40(8) เหมา ($flatExpense408Percent%): ฿${(exp408 / 100).toStringAsFixed(2)}');
    }

    final totalExpense = exp401And402 + exp406 + exp408;
    final incomeAfterExpense = max(0, totalGross - totalExpense);
    steps.add('3. เงินได้หลังหักค่าใช้จ่าย: ฿${(incomeAfterExpense / 100).toStringAsFixed(2)}');

    // 3. Deductions & Allowances
    int totalAllowances = personalAllowanceSatang;
    steps.add('4. ค่าลดหย่อน:');
    steps.add('  - ลดหย่อนส่วนตัว: ฿${(personalAllowanceSatang / 100).toStringAsFixed(2)}');

    int lifeIns = 0;
    int healthIns = 0;
    int socialSec = 0;
    int homeLoan = 0;
    int rmf = 0;
    int ssf = 0;
    int thaiEsg = 0;
    int pvd = 0;
    int gpf = 0;
    int generalDonations = 0;
    int eduDonations = 0;

    for (final d in deductions) {
      switch (d.code) {
        case 'spouse':
          totalAllowances += spouseAllowanceSatang;
          steps.add('  - ลดหย่อนคู่สมรส: ฿${(spouseAllowanceSatang / 100).toStringAsFixed(2)}');
          break;
        case 'child':
          totalAllowances += d.amountSatang;
          steps.add('  - ลดหย่อนบุตร: ฿${(d.amountSatang / 100).toStringAsFixed(2)}');
          break;
        case 'social_security':
          socialSec += d.amountSatang;
          break;
        case 'life_insurance':
          lifeIns += d.amountSatang;
          break;
        case 'health_insurance':
          healthIns += d.amountSatang;
          break;
        case 'home_loan':
          homeLoan += d.amountSatang;
          break;
        case 'rmf':
          rmf += d.amountSatang;
          break;
        case 'ssf':
          ssf += d.amountSatang;
          break;
        case 'thai_esg':
          thaiEsg += d.amountSatang;
          break;
        case 'provident_fund':
          pvd += d.amountSatang;
          break;
        case 'gpf':
          gpf += d.amountSatang;
          break;
        case 'donation_general':
          generalDonations += d.amountSatang;
          break;
        case 'donation_education':
          eduDonations += d.amountSatang;
          break;
        default:
          totalAllowances += d.amountSatang;
          steps.add('  - ${d.name}: ฿${(d.amountSatang / 100).toStringAsFixed(2)}');
          break;
      }
    }

    // Social Security (Cap 9,000 THB)
    final ssLimit = (deductionLimits['socialSecurityMaxSatang'] as num?)?.toInt() ?? 900000;
    final allowedSs = min(socialSec, ssLimit);
    if (allowedSs > 0) {
      totalAllowances += allowedSs;
      steps.add('  - ประกันสังคม: ฿${(allowedSs / 100).toStringAsFixed(2)}');
    }

    // Life & Health Insurance (Life max 100k, Health max 25k, Combined max 100k)
    final lifeLimit = (deductionLimits['lifeInsuranceMaxSatang'] as num?)?.toInt() ?? 10000000;
    final healthLimit = (deductionLimits['healthInsuranceMaxSatang'] as num?)?.toInt() ?? 2500000;
    final lifeHealthCombinedLimit = (deductionLimits['lifeAndHealthInsuranceCombinedMaxSatang'] as num?)?.toInt() ?? 10000000;

    final cappedLife = min(lifeIns, lifeLimit);
    final cappedHealth = min(healthIns, healthLimit);
    final allowedLifeAndHealth = min(cappedLife + cappedHealth, lifeHealthCombinedLimit);
    if (allowedLifeAndHealth > 0) {
      totalAllowances += allowedLifeAndHealth;
      steps.add('  - ประกันชีวิตและสุขภาพ (เพดาน ฿100,000): ฿${(allowedLifeAndHealth / 100).toStringAsFixed(2)}');
    }

    // Home Loan Interest (Cap 100,000 THB)
    final homeLimit = (deductionLimits['homeLoanInterestMaxSatang'] as num?)?.toInt() ?? 10000000;
    final allowedHome = min(homeLoan, homeLimit);
    if (allowedHome > 0) {
      totalAllowances += allowedHome;
      steps.add('  - ดอกเบี้ยกู้ยืมเพื่อที่อยู่อาศัย: ฿${(allowedHome / 100).toStringAsFixed(2)}');
    }

    // Retirement Group: SSF (max 30% or 200k), RMF (max 30% or 500k), PVD (max 15% or 500k), GPF (max 30% or 500k), combined max 500k
    final ssfMax = (deductionLimits['ssfMaxSatang'] as num?)?.toInt() ?? 20000000;
    final rmfMax = (deductionLimits['rmfMaxSatang'] as num?)?.toInt() ?? 50000000;
    final pvdMax = (deductionLimits['providentFundMaxSatang'] as num?)?.toInt() ?? 50000000;
    final gpfMax = (deductionLimits['gpfMaxSatang'] as num?)?.toInt() ?? 50000000;
    final retirementCombined = (deductionLimits['retirementGroupCombinedMaxSatang'] as num?)?.toInt() ?? 50000000;

    final cappedSsf = min(ssf, min(ssfMax, (totalGross * 0.30).round()));
    final cappedRmf = min(rmf, min(rmfMax, (totalGross * 0.30).round()));
    final cappedPvd = min(pvd, min(pvdMax, (totalGross * 0.15).round()));
    final cappedGpf = min(gpf, min(gpfMax, (totalGross * 0.30).round()));
    final allowedRetirement = min(cappedSsf + cappedRmf + cappedPvd + cappedGpf, retirementCombined);
    if (allowedRetirement > 0) {
      totalAllowances += allowedRetirement;
      steps.add('  - กลุ่มเกษียณ (กบข., RMF, SSF, PVD เพดานรวม ฿500,000): ฿${(allowedRetirement / 100).toStringAsFixed(2)}');
    }

    // ThaiESG (Separate Cap 300,000 THB, max 30%)
    final thaiEsgMax = (deductionLimits['thaiEsgMaxSatang'] as num?)?.toInt() ?? 30000000;
    final allowedThaiEsg = min(thaiEsg, min(thaiEsgMax, (totalGross * 0.30).round()));
    if (allowedThaiEsg > 0) {
      totalAllowances += allowedThaiEsg;
      steps.add('  - กองทุน ThaiESG (เพดาน ฿300,000): ฿${(allowedThaiEsg / 100).toStringAsFixed(2)}');
    }

    // Pre-donation Income
    final preDonationIncome = max(0, incomeAfterExpense - totalAllowances);

    // Donations (Education 2x max 10%, General max 10%)
    if (eduDonations > 0) {
      final maxEdu = (preDonationIncome * 0.10).round();
      final allowedEdu = min(eduDonations * 2, maxEdu);
      totalAllowances += allowedEdu;
      steps.add('  - บริจาคเพื่อการศึกษา/กีฬา (2 เท่า เพดาน 10%): ฿${(allowedEdu / 100).toStringAsFixed(2)}');
    }
    if (generalDonations > 0) {
      final maxGen = (preDonationIncome * 0.10).round();
      final allowedGen = min(generalDonations, maxGen);
      totalAllowances += allowedGen;
      steps.add('  - บริจาคทั่วไป (เพดาน 10%): ฿${(allowedGen / 100).toStringAsFixed(2)}');
    }

    // 4. Net Taxable Income (Clamped to 0)
    final netTaxableIncome = max(0, incomeAfterExpense - totalAllowances);
    steps.add('5. เงินได้สุทธิ (Net Taxable Income): ฿${(netTaxableIncome / 100).toStringAsFixed(2)}');

    // 5. Progressive Tax Calculation
    int computedTax = 0;
    final bracketRows = <BracketCalculationRow>[];

    for (final b in brackets) {
      if (netTaxableIncome <= b.minSatang) continue;

      final rangeMax = b.maxSatang ?? netTaxableIncome;
      final upper = min(netTaxableIncome, rangeMax);
      final taxableAmount = upper - b.minSatang + 1;

      if (taxableAmount > 0) {
        final taxForBracket = (taxableAmount * (b.ratePercent / 100.0)).round();
        computedTax += taxForBracket;

        final label = b.maxSatang != null
            ? '${(b.minSatang / 100).toStringAsFixed(0)} - ${(b.maxSatang! / 100).toStringAsFixed(0)}'
            : '> ${(b.minSatang / 100).toStringAsFixed(0)}';

        bracketRows.add(BracketCalculationRow(
          rangeLabel: label,
          taxableAmountInRangeSatang: taxableAmount,
          ratePercent: b.ratePercent,
          taxSatang: taxForBracket,
        ));

        steps.add('  - ขั้น $label (${b.ratePercent}%): ฐานเงินได้ ฿${(taxableAmount / 100).toStringAsFixed(2)} -> ภาษี ฿${(taxForBracket / 100).toStringAsFixed(2)}');
      }
    }

    steps.add('6. ภาษีคำนวณตามขั้นบันได: ฿${(computedTax / 100).toStringAsFixed(2)}');

    // 6. Net Tax Due / Refund
    final totalCredits = totalWht + totalDividendCredit;
    final netTaxDue = computedTax - totalCredits;

    if (totalWht > 0) steps.add('  - หักภาษี ณ ที่จ่าย (WHT): ฿${(totalWht / 100).toStringAsFixed(2)}');
    if (totalDividendCredit > 0) steps.add('  - หักเครดิตภาษีเงินปันผล: ฿${(totalDividendCredit / 100).toStringAsFixed(2)}');

    if (netTaxDue > 0) {
      steps.add('7. สรุป: ต้องชำระภาษีเพิ่มเติม ฿${(netTaxDue / 100).toStringAsFixed(2)}');
    } else if (netTaxDue < 0) {
      steps.add('7. สรุป: ได้รับเงินคืนภาษี ฿${((netTaxDue.abs()) / 100).toStringAsFixed(2)}');
    } else {
      steps.add('7. สรุป: ภาษีพอดี ไม่มียอดต้องชำระเพิ่มหรือขอคืน');
    }

    return TaxCalculationResult(
      taxYear: taxYear,
      grossIncomeSatang: totalGross,
      expenseDeductionSatang: totalExpense,
      incomeAfterExpenseSatang: incomeAfterExpense,
      totalDeductionsSatang: totalAllowances,
      netTaxableIncomeSatang: netTaxableIncome,
      computedTaxSatang: computedTax,
      totalWithholdingTaxSatang: totalWht,
      totalDividendTaxCreditSatang: totalDividendCredit,
      netTaxDueSatang: netTaxDue,
      isRefund: netTaxDue < 0,
      bracketRows: bracketRows,
      calculationSteps: steps,
    );
  }

  /// Compares including Thai dividends in progressive tax vs keeping them as 10% Final Tax.
  static DividendOptimizationResult compareDividendStrategy({
    required int taxYear,
    required List<TaxBracket> brackets,
    required List<IncomeEntry> incomes,
    required List<DeductionEntry> deductions,
    required int personalAllowanceSatang,
    required int spouseAllowanceSatang,
    required int childAllowanceSatang,
    required double expenseRate401And402Percent,
    required int expenseMax401And402Satang,
    required double flatExpense406MedicalPercent,
    required double flatExpense408Percent,
    required Map<String, dynamic> deductionLimits,
  }) {
    // Strategy 1: Include Thai dividends in progressive brackets (with dividend credit)
    final withDividends = calculateTax(
      taxYear: taxYear,
      brackets: brackets,
      incomes: incomes,
      deductions: deductions,
      personalAllowanceSatang: personalAllowanceSatang,
      spouseAllowanceSatang: spouseAllowanceSatang,
      childAllowanceSatang: childAllowanceSatang,
      expenseRate401And402Percent: expenseRate401And402Percent,
      expenseMax401And402Satang: expenseMax401And402Satang,
      flatExpense406MedicalPercent: flatExpense406MedicalPercent,
      flatExpense408Percent: flatExpense408Percent,
      deductionLimits: deductionLimits,
      includeThaiDividends: true,
    );

    // Strategy 2: Exclude Thai dividends (Final Tax 10% already paid at source)
    final finalTaxDividends = calculateTax(
      taxYear: taxYear,
      brackets: brackets,
      incomes: incomes,
      deductions: deductions,
      personalAllowanceSatang: personalAllowanceSatang,
      spouseAllowanceSatang: spouseAllowanceSatang,
      childAllowanceSatang: childAllowanceSatang,
      expenseRate401And402Percent: expenseRate401And402Percent,
      expenseMax401And402Satang: expenseMax401And402Satang,
      flatExpense406MedicalPercent: flatExpense406MedicalPercent,
      flatExpense408Percent: flatExpense408Percent,
      deductionLimits: deductionLimits,
      includeThaiDividends: false,
    );

    // Total tax burden for Strategy 1 vs Strategy 2
    // With dividends: netTaxDue is (computedTax - totalWht - totalDividendCredit)
    // With Final Tax: user paid 10% WHT on dividends, plus netTaxDue of other incomes
    int thaiDividendSatang = 0;
    for (final inc in incomes) {
      if (inc.taxCategory == '40_4_dividend_th') {
        thaiDividendSatang += inc.grossSatang;
      }
    }
    final finalTaxPaidOnDividends = (thaiDividendSatang * 0.10).round();
    final totalCostFinalTax = finalTaxDividends.netTaxDueSatang + finalTaxPaidOnDividends;
    final totalCostWithDividends = withDividends.netTaxDueSatang + finalTaxPaidOnDividends;

    final isFinalTaxBetter = totalCostFinalTax < totalCostWithDividends;
    final diff = (totalCostWithDividends - totalCostFinalTax).abs();

    return DividendOptimizationResult(
      withDividends: withDividends,
      finalTaxDividends: finalTaxDividends,
      isFinalTaxBetter: isFinalTaxBetter,
      taxDifferenceSatang: diff,
    );
  }
}
