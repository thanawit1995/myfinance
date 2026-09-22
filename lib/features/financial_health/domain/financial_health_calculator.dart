import 'models/health_metric_result.dart';
import '../../../../core/money/money.dart';

class FinancialHealthInputData {
  final int liquidAssetsSatang;
  final int totalAssetsSatang;
  final int totalDebtsSatang;
  final int shortTermDebtsSatang;
  final int monthlyDebtPaymentSatang;
  final int avgMonthlyExpenseSatang;
  final int avgMonthlyIncomeSatang;
  final int currentMonthIncomeSatang;
  final int currentMonthExpenseSatang;
  final int currentMonthInvestmentSatang;
  final int portfolioMarketValueSatang;
  final int sumInsuredSatang;
  final int medicalCoverageSatang;
  final int estimatedMedicalCostSatang;
  final int familyReserveSatang;

  // Configurable target thresholds:
  final double targetBasicLiquidity;
  final double targetEmergencyMonths;
  final double targetDebtToAssetPercent;
  final double targetDtiPercent;
  final int targetFamilySecurityBufferSatang;
  final int targetHealthCoverageBufferSatang;
  final double targetSavingsRatePercent;
  final double targetInvestmentRatioPercent;

  const FinancialHealthInputData({
    required this.liquidAssetsSatang,
    required this.totalAssetsSatang,
    required this.totalDebtsSatang,
    required this.shortTermDebtsSatang,
    required this.monthlyDebtPaymentSatang,
    required this.avgMonthlyExpenseSatang,
    required this.avgMonthlyIncomeSatang,
    required this.currentMonthIncomeSatang,
    required this.currentMonthExpenseSatang,
    required this.currentMonthInvestmentSatang,
    required this.portfolioMarketValueSatang,
    required this.sumInsuredSatang,
    required this.medicalCoverageSatang,
    this.estimatedMedicalCostSatang = 50000000, // default 500,000 THB
    this.familyReserveSatang = 0,
    this.targetBasicLiquidity = 1.0,
    this.targetEmergencyMonths = 6.0,
    this.targetDebtToAssetPercent = 50.0,
    this.targetDtiPercent = 40.0,
    this.targetFamilySecurityBufferSatang = 0,
    this.targetHealthCoverageBufferSatang = 0,
    this.targetSavingsRatePercent = 10.0,
    this.targetInvestmentRatioPercent = 50.0,
  });
}

class FinancialHealthCalculator {
  /// Computes the 8 metrics and overall score (0 to 100).
  static FinancialHealthSummary calculate(FinancialHealthInputData input, {bool isThai = true}) {
    final metrics = <HealthMetricResult>[];
    final recommendations = <String>[];

    // -------------------------------------------------------------
    // 1. สภาพคล่องพื้นฐาน (Basic Liquidity) - Max 15 pts
    // สูตร: สินทรัพย์สภาพคล่อง ÷ หนี้สินระยะสั้น (> 1.0 เท่า)
    // -------------------------------------------------------------
    {
      final liquidMoney = Money(input.liquidAssetsSatang);
      final shortDebtMoney = Money(input.shortTermDebtsSatang);
      double ratio = 0.0;
      HealthStatus status;
      int score;

      if (input.shortTermDebtsSatang <= 0) {
        ratio = input.liquidAssetsSatang > 0 ? 99.0 : 0.0;
        status = HealthStatus.pass;
        score = 15;
      } else {
        ratio = input.liquidAssetsSatang / input.shortTermDebtsSatang;
        if (ratio >= input.targetBasicLiquidity) {
          status = HealthStatus.pass;
          score = 15;
        } else if (ratio >= input.targetBasicLiquidity * 0.8) {
          status = HealthStatus.warning;
          score = 8;
          recommendations.add(isThai
              ? 'สภาพคล่องพื้นฐานตึงตัว: ควรเพิ่มเงินสดสำรองหรือเร่งลดหนี้ระยะสั้นให้สินทรัพย์สภาพคล่องสูงกว่าหนี้ระยะสั้น'
              : 'Tight Basic Liquidity: Increase cash reserves or pay down short-term debts.');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add(isThai
              ? 'วิกฤตสภาพคล่องระยะสั้น: สินทรัพย์สภาพคล่องไม่พอชำระหนี้ระยะสั้น ควรระมัดระวังการผิดนัดชำระหนี้'
              : 'Critical Liquidity Risk: Liquid assets cannot cover short-term debts.');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 1,
        code: 'basic_liquidity',
        title: isThai ? 'สภาพคล่องพื้นฐาน' : 'Basic Liquidity',
        subtitle: isThai ? 'ความสามารถในการชำระหนี้ระยะสั้นทันที' : 'Ability to settle short-term debts immediately',
        currentValue: ratio,
        formattedValue: input.shortTermDebtsSatang <= 0
            ? (isThai ? 'ปลอดภัย (ไม่มีหนี้ระยะสั้น)' : 'Safe (No short-term debts)')
            : '${ratio.toStringAsFixed(2)} ${isThai ? "เท่า" : "x"}',
        targetThreshold: '> ${input.targetBasicLiquidity.toStringAsFixed(1)} ${isThai ? "เท่า" : "x"}',
        status: status,
        score: score,
        maxScore: 15,
        formulaDescription: isThai ? 'สินทรัพย์สภาพคล่อง ÷ หนี้สินระยะสั้น' : 'Liquid Assets ÷ Short-term Debts',
        breakdownItems: [
          MetricBreakdownItem(
            label: isThai ? 'สินทรัพย์สภาพคล่อง (เงินสด+เงินฝาก)' : 'Liquid Assets (Cash & Bank Deposits)',
            formattedValue: liquidMoney.format(symbol: '฿'),
          ),
          MetricBreakdownItem(
            label: isThai ? 'หนี้สินระยะสั้น (บัตรเครดิต/หนี้ <= 1 ปี)' : 'Short-term Debts (Cards & <= 1 yr)',
            formattedValue: shortDebtMoney.format(symbol: '฿'),
          ),
        ],
        recommendation: status == HealthStatus.pass
            ? (isThai
                ? 'ยอดเยี่ยม: คุณมีสินทรัพย์สภาพคล่องเพียงพอรับมือหนี้ระยะสั้นทั้งหมด'
                : 'Excellent: You have ample liquid assets to cover all short-term obligations.')
            : (isThai
                ? 'ควรกันเงินฝากไว้รองรับหนี้ระยะสั้นอย่างน้อย 1 เท่าเสมอ'
                : 'Maintain at least 1.0x liquid assets against short-term debts.'),
      ));
    }

    // -------------------------------------------------------------
    // 2. เงินออมฉุกเฉิน (Emergency Fund) - Max 15 pts
    // สูตร: สินทรัพย์สภาพคล่อง ÷ ค่าใช้จ่ายเฉลี่ยต่อเดือน (≥ 6.0 เดือน)
    // -------------------------------------------------------------
    {
      final liquidMoney = Money(input.liquidAssetsSatang);
      final avgExpMoney = Money(input.avgMonthlyExpenseSatang);
      double months = 0.0;
      HealthStatus status;
      int score;

      if (input.avgMonthlyExpenseSatang <= 0) {
        months = input.liquidAssetsSatang > 0 ? 99.0 : 0.0;
        status = HealthStatus.pass;
        score = 15;
      } else {
        months = input.liquidAssetsSatang / input.avgMonthlyExpenseSatang;
        if (months >= input.targetEmergencyMonths) {
          status = HealthStatus.pass;
          score = 15;
        } else if (months >= input.targetEmergencyMonths * 0.5) {
          status = HealthStatus.warning;
          score = 8;
          recommendations.add(isThai
              ? 'เงินออมฉุกเฉินอยู่ในระดับเฝ้าระวัง: ปัจจุบันมี ${months.toStringAsFixed(1)} เดือน ควรสะสมเพิ่มให้ครบ ${input.targetEmergencyMonths.toStringAsFixed(0)} เดือน'
              : 'Emergency Fund Warning: Currently ${months.toStringAsFixed(1)} months. Aim for ${input.targetEmergencyMonths.toStringAsFixed(0)} months.');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add(isThai
              ? 'เงินออมฉุกเฉินไม่เพียงพอ: มีไม่ถึง 3 เดือน เสี่ยงมากหากขาดรายได้กะทันหัน ควรชะลอการลงทุนและสะสมเงินออมฉุกเฉินก่อน'
              : 'Insufficient Emergency Fund: Less than 3 months of buffer. Build cash reserves before investing.');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 2,
        code: 'emergency_fund',
        title: isThai ? 'เงินออมฉุกเฉิน' : 'Emergency Fund',
        subtitle: isThai ? 'ระยะเวลาที่อยู่รอดได้หากขาดรายได้' : 'Months of survival without income',
        currentValue: months,
        formattedValue: isThai
            ? '${months >= 99 ? "> 99" : months.toStringAsFixed(1)} เดือน'
            : '${months >= 99 ? "> 99" : months.toStringAsFixed(1)} mo',
        targetThreshold: isThai
            ? '≥ ${input.targetEmergencyMonths.toStringAsFixed(1)} เดือน'
            : '≥ ${input.targetEmergencyMonths.toStringAsFixed(1)} mo',
        status: status,
        score: score,
        maxScore: 15,
        formulaDescription: isThai
            ? 'สินทรัพย์สภาพคล่อง ÷ ค่าใช้จ่ายเฉลี่ยต่อเดือน (6 เดือนย้อนหลัง)'
            : 'Liquid Assets ÷ Avg Monthly Expenses (6-mo trailing)',
        breakdownItems: [
          MetricBreakdownItem(
            label: isThai ? 'สินทรัพย์สภาพคล่อง' : 'Liquid Assets',
            formattedValue: liquidMoney.format(symbol: '฿'),
          ),
          MetricBreakdownItem(
            label: isThai ? 'ค่าใช้จ่ายเฉลี่ยต่อเดือน' : 'Avg Monthly Expenses',
            formattedValue: avgExpMoney.format(symbol: '฿'),
          ),
        ],
        recommendation: status == HealthStatus.pass
            ? (isThai
                ? 'ยอดเยี่ยม: มีเงินสำรองฉุกเฉินรองรับค่าใช้จ่ายได้สบายใจ'
                : 'Excellent: Robust emergency buffer covering living expenses.')
            : (isThai
                ? 'ตั้งเป้าทยอยสะสมเงินออมฉุกเฉินไว้ในบัญชีดอกเบี้ยสูงหรือกองทุนตลาดเงิน'
                : 'Accumulate emergency reserves in high-yield savings or money market funds.'),
      ));
    }

    // -------------------------------------------------------------
    // 3. ภาระหนี้สินรวม (Debt to Asset) - Max 15 pts
    // สูตร: หนี้สินรวม ÷ สินทรัพย์รวม (< 50.0%)
    // -------------------------------------------------------------
    {
      final debtMoney = Money(input.totalDebtsSatang);
      final assetMoney = Money(input.totalAssetsSatang);
      double pct = 0.0;
      HealthStatus status;
      int score;

      if (input.totalAssetsSatang <= 0) {
        pct = input.totalDebtsSatang > 0 ? 100.0 : 0.0;
        status = input.totalDebtsSatang > 0 ? HealthStatus.fail : HealthStatus.pass;
        score = input.totalDebtsSatang > 0 ? 0 : 15;
      } else {
        pct = (input.totalDebtsSatang / input.totalAssetsSatang) * 100.0;
        if (pct < input.targetDebtToAssetPercent) {
          status = HealthStatus.pass;
          score = 15;
        } else if (pct <= input.targetDebtToAssetPercent * 1.2) {
          status = HealthStatus.warning;
          score = 8;
          recommendations.add(isThai
              ? 'สัดส่วนหนี้สินค่อนข้างสูง (${pct.toStringAsFixed(1)}%): ควรควบคุมการก่อหนี้ใหม่และเน้นทยอยลดหนี้ดอกเบี้ยสูง'
              : 'Elevated Debt Ratio (${pct.toStringAsFixed(1)}%): Restrain new borrowing and pay down high-interest debt.');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add(isThai
              ? 'ภาระหนี้สินเกินเกณฑ์อันตราย (${pct.toStringAsFixed(1)}%): หนี้สินเกินครึ่งหนึ่งของทรัพย์สินทั้งหมด เสี่ยงต่อความมั่นคงทางการเงิน'
              : 'Critical Debt Level (${pct.toStringAsFixed(1)}%): Debts exceed 50% of assets, posing financial risks.');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 3,
        code: 'debt_to_asset',
        title: isThai ? 'ภาระหนี้สินรวม' : 'Debt to Asset',
        subtitle: isThai ? 'สัดส่วนหนี้สินเทียบกับทรัพย์สินที่มี' : 'Total debt relative to total assets',
        currentValue: pct,
        formattedValue: '${pct.toStringAsFixed(1)}%',
        targetThreshold: '< ${input.targetDebtToAssetPercent.toStringAsFixed(1)}%',
        status: status,
        score: score,
        maxScore: 15,
        formulaDescription: isThai ? 'หนี้สินรวม ÷ สินทรัพย์รวม' : 'Total Debts ÷ Total Assets',
        breakdownItems: [
          MetricBreakdownItem(
            label: isThai ? 'หนี้สินคงค้างรวมทั้งหมด' : 'Total Outstanding Debts',
            formattedValue: debtMoney.format(symbol: '฿'),
          ),
          MetricBreakdownItem(
            label: isThai ? 'สินทรัพย์รวม (เงินฝาก + พอร์ตลงทุน)' : 'Total Assets (Deposits + Portfolio)',
            formattedValue: assetMoney.format(symbol: '฿'),
          ),
        ],
        recommendation: status == HealthStatus.pass
            ? (isThai
                ? 'ยอดเยี่ยม: ภาระหนี้สินอยู่ในระดับปลอดภัย ไม่เกิน 50% ของสินทรัพย์'
                : 'Excellent: Debt level is safely below 50% of total assets.')
            : (isThai
                ? 'ควรหยุดสร้างหนี้ใหม่ และวางแผนโปะหนี้เพื่อลดดอกเบี้ยสะสม'
                : 'Pause new borrowing and accelerate repayments to curb interest expense.'),
      ));
    }

    // -------------------------------------------------------------
    // 4. ความสามารถชำระหนี้ (DTI: Debt Service Ratio) - Max 15 pts
    // สูตร: เงินผ่อนชำระหนี้ต่อเดือน ÷ รายรับเฉลี่ยต่อเดือน (< 40.0%)
    // -------------------------------------------------------------
    {
      final monthlyDebtMoney = Money(input.monthlyDebtPaymentSatang);
      final avgIncMoney = Money(input.avgMonthlyIncomeSatang);
      double dti = 0.0;
      HealthStatus status;
      int score;

      if (input.avgMonthlyIncomeSatang <= 0) {
        dti = input.monthlyDebtPaymentSatang > 0 ? 100.0 : 0.0;
        status = input.monthlyDebtPaymentSatang > 0 ? HealthStatus.fail : HealthStatus.pass;
        score = input.monthlyDebtPaymentSatang > 0 ? 0 : 15;
      } else {
        dti = (input.monthlyDebtPaymentSatang / input.avgMonthlyIncomeSatang) * 100.0;
        if (dti < input.targetDtiPercent) {
          status = HealthStatus.pass;
          score = 15;
        } else if (dti <= input.targetDtiPercent * 1.25) {
          status = HealthStatus.warning;
          score = 8;
          recommendations.add(isThai
              ? 'ค่างวดหนี้เริ่มตึงมือ (${dti.toStringAsFixed(1)}% ของรายรับ): ควรระวังค่าใช้จ่ายไม่คาดคิดที่อาจทำให้สภาพคล่องสะดุด'
              : 'Debt Service Warning (${dti.toStringAsFixed(1)}% of income): Watch for unexpected spending shocks.');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add(isThai
              ? 'ภาระผ่อนหนี้สูงเกินเกณฑ์ความปลอดภัย (${dti.toStringAsFixed(1)}%): ค่างวดหนี้กินรายได้เกือบครึ่งหนึ่ง เสี่ยงต่อการหมุนเงินไม่ทัน'
              : 'Critical Debt Burden (${dti.toStringAsFixed(1)}%): Debt installments consume almost half of monthly earnings.');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 4,
        code: 'dti',
        title: isThai ? 'ความสามารถชำระหนี้ (DTI)' : 'Debt to Income (DTI)',
        subtitle: isThai ? 'ภาระค่างวดหนี้เทียบกับรายได้ประจำเดือน' : 'Monthly debt service vs monthly income',
        currentValue: dti,
        formattedValue: '${dti.toStringAsFixed(1)}%',
        targetThreshold: '< ${input.targetDtiPercent.toStringAsFixed(1)}%',
        status: status,
        score: score,
        maxScore: 15,
        formulaDescription: isThai ? 'เงินผ่อนชำระหนี้ต่อเดือน ÷ รายรับเฉลี่ยต่อเดือน' : 'Monthly Debt Payments ÷ Avg Monthly Income',
        breakdownItems: [
          MetricBreakdownItem(
            label: isThai ? 'ค่างวดผ่อนชำระต่อเดือนรวม' : 'Total Monthly Debt Payments',
            formattedValue: monthlyDebtMoney.format(symbol: '฿'),
          ),
          MetricBreakdownItem(
            label: isThai ? 'รายรับเฉลี่ยต่อเดือน (6 เดือนย้อนหลัง)' : 'Avg Monthly Income (6-mo trailing)',
            formattedValue: avgIncMoney.format(symbol: '฿'),
          ),
        ],
        recommendation: status == HealthStatus.pass
            ? (isThai
                ? 'ยอดเยี่ยม: ค่างวดหนี้ไม่เกิน 40% ของรายรับ กระแสเงินสดยังมีความคล่องตัวสูง'
                : 'Excellent: Debt service is well under 40% of income with healthy liquidity.')
            : (isThai
                ? 'ควรเจรจารีไฟแนนซ์เพื่อยืดค่างวด หรือลดรายจ่ายส่วนอื่นเพื่อรักษาสภาพคล่อง'
                : 'Consider refinancing or reducing non-essential expenses to protect cash flow.'),
      ));
    }

    // -------------------------------------------------------------
    // 5. ความมั่นคงของครอบครัว (Family Security) - Max 10 pts
    // สูตร: สินทรัพย์รวม + ทุนประกัน − (หนี้สินรวม + เงินทุนสำรองครอบครัว) > 0 บาท
    // -------------------------------------------------------------
    {
      final totalAssets = input.totalAssetsSatang;
      final sumInsured = input.sumInsuredSatang;
      final totalDebts = input.totalDebtsSatang;
      final familyReserve = input.familyReserveSatang;

      final balanceSatang = (totalAssets + sumInsured) - (totalDebts + familyReserve);
      final balMoney = Money(balanceSatang);
      HealthStatus status;
      int score;

      if (balanceSatang >= input.targetFamilySecurityBufferSatang) {
        status = HealthStatus.pass;
        score = 10;
      } else if (balanceSatang >= -20000000) { // ขาดไม่เกิน 200,000 บาท
        status = HealthStatus.warning;
        score = 5;
        recommendations.add(isThai
            ? 'ความมั่นคงครอบครัวอยู่ในระดับเฝ้าระวัง: หากเกิดเหตุฉุกเฉิน ทุนประกันอาจเหลือไม่ครอบคลุมหนี้สินและเงินดูแลครอบครัว'
            : 'Family Protection Warning: Coverage and assets may be tight if unforeseen emergencies arise.');
      } else {
        status = HealthStatus.fail;
        score = 0;
        recommendations.add(isThai
            ? 'ความคุ้มครองชีวิตและครอบครัวไม่เพียงพอ: หนี้สินสูงกว่าสินทรัพย์และประกันรวมกัน ควรพิจารณาทำประกันชีวิตคุ้มครองภาระหนี้'
            : 'Insufficient Family Protection: Total liabilities exceed combined assets and insurance.');
      }

      metrics.add(HealthMetricResult(
        metricIndex: 5,
        code: 'family_security',
        title: isThai ? 'ความมั่นคงครอบครัว' : 'Family Security',
        subtitle: isThai ? 'ความพร้อมคุ้มครองคนข้างหลังกรณีเกิดเหตุไม่คาดฝัน' : 'Financial protection for dependents in unforeseen events',
        currentValue: balanceSatang,
        formattedValue: balanceSatang >= 0 ? '+${balMoney.format(symbol: '฿')}' : balMoney.format(symbol: '฿'),
        targetThreshold: '> 0 ฿',
        status: status,
        score: score,
        maxScore: 10,
        formulaDescription: isThai
            ? 'สินทรัพย์รวม + ทุนประกันชีวิต − (หนี้สินรวม + เงินทุนสำรองครอบครัว)'
            : 'Total Assets + Life Insurance − (Total Debts + Family Reserve)',
        breakdownItems: [
          MetricBreakdownItem(
            label: isThai ? 'สินทรัพย์รวม' : 'Total Assets',
            formattedValue: Money(totalAssets).format(symbol: '฿'),
          ),
          MetricBreakdownItem(
            label: isThai ? 'ทุนประกันชีวิตและทุพพลภาพรวม' : 'Total Life & Disability Coverage',
            formattedValue: Money(sumInsured).format(symbol: '฿'),
          ),
          MetricBreakdownItem(
            label: isThai ? 'หนี้สินคงค้างรวม' : 'Total Outstanding Debts',
            formattedValue: Money(totalDebts).format(symbol: '฿'),
          ),
          MetricBreakdownItem(
            label: isThai ? 'เงินทุนสำรองครอบครัวที่ตั้งไว้' : 'Target Family Reserve',
            formattedValue: Money(familyReserve).format(symbol: '฿'),
          ),
        ],
        recommendation: status == HealthStatus.pass
            ? (isThai
                ? 'ยอดเยี่ยม: มีสินทรัพย์และประกันคุ้มครองภาระทางการเงินครบถ้วน'
                : 'Excellent: Assets and life insurance fully protect family obligations.')
            : (isThai
                ? 'ควรทำประกันชีวิตแบบชั่วระยะเวลา (Term) เพื่อปิดความเสี่ยงภาระหนี้สิน'
                : 'Consider term life insurance to cover outstanding liabilities.'),
      ));
    }

    // -------------------------------------------------------------
    // 6. ความคุ้มครองสุขภาพ (Health Coverage) - Max 10 pts
    // สูตร: วงเงินค่ารักษาที่มี − ค่ารักษาที่ประเมินไว้ > 0 บาท
    // -------------------------------------------------------------
    {
      final coverage = input.medicalCoverageSatang;
      final estimatedCost = input.estimatedMedicalCostSatang;
      final diffSatang = coverage - estimatedCost;
      final diffMoney = Money(diffSatang);
      HealthStatus status;
      int score;

      if (diffSatang >= input.targetHealthCoverageBufferSatang) {
        status = HealthStatus.pass;
        score = 10;
      } else if (diffSatang >= -10000000) { // ขาดไม่เกิน 100,000 บาท
        status = HealthStatus.warning;
        score = 5;
        recommendations.add(isThai
            ? 'วงเงินค่ารักษาพยาบาลค่อนข้างกระชั้นชิด: อาจมีส่วนต่างค่ารักษาที่ต้องใช้เงินออมจ่ายเอง'
            : 'Borderline Medical Coverage: You may face out-of-pocket medical expenses.');
      } else {
        status = HealthStatus.fail;
        score = 0;
        recommendations.add(isThai
            ? 'ความคุ้มครองสุขภาพไม่เพียงพอ: วงเงินประกันสุขภาพต่ำกว่าค่ารักษาโรคร้ายแรงที่ประเมินไว้ เสี่ยงกระทบเงินเก็บก้อนใหญ่'
            : 'Insufficient Health Coverage: Policy coverage is below estimated critical illness costs.');
      }

      metrics.add(HealthMetricResult(
        metricIndex: 6,
        code: 'health_coverage',
        title: isThai ? 'ความคุ้มครองสุขภาพ' : 'Health Coverage',
        subtitle: isThai ? 'ความเพียงพอของสวัสดิการประกันสุขภาพ' : 'Adequacy of health & medical coverage',
        currentValue: diffSatang,
        formattedValue: diffSatang >= 0 ? '+${diffMoney.format(symbol: '฿')}' : diffMoney.format(symbol: '฿'),
        targetThreshold: '> 0 ฿',
        status: status,
        score: score,
        maxScore: 10,
        formulaDescription: isThai
            ? 'วงเงินค่ารักษาพยาบาลรวม − ค่ารักษาที่ประเมินไว้'
            : 'Total Medical Coverage − Estimated Treatment Cost',
        breakdownItems: [
          MetricBreakdownItem(
            label: isThai ? 'วงเงินค่ารักษาพยาบาลจากประกันรวม' : 'Total Medical Coverage from Policies',
            formattedValue: Money(coverage).format(symbol: '฿'),
          ),
          MetricBreakdownItem(
            label: isThai ? 'ค่ารักษาพยาบาลที่ประเมินไว้' : 'Estimated Medical / CI Cost',
            formattedValue: Money(estimatedCost).format(symbol: '฿'),
          ),
        ],
        recommendation: status == HealthStatus.pass
            ? (isThai
                ? 'ยอดเยี่ยม: วงเงินค่ารักษาพยาบาลครอบคลุมตามเป้าหมายที่ตั้งไว้'
                : 'Excellent: Medical coverage safely meets your estimated care target.')
            : (isThai
                ? 'ควรพิจารณาทำประกันสุขภาพแบบเหมาจ่าย หรือประกันโรคร้ายแรงเพิ่มเติม'
                : 'Consider comprehensive lump-sum health or critical illness insurance.'),
      ));
    }

    // -------------------------------------------------------------
    // 7. อัตราการออม (Savings Rate) - Max 10 pts
    // สูตร: (เงินออมสุทธิ + เงินลงทุน) ÷ รายรับต่อเดือน (> 10.0%)
    // -------------------------------------------------------------
    {
      final income = input.currentMonthIncomeSatang;
      final expense = input.currentMonthExpenseSatang;
      final invest = input.currentMonthInvestmentSatang;

      final savings = income - expense; // เงินออมที่เหลือหลังหักรายจ่าย
      final totalSavedAndInvested = savings > 0 ? (savings + invest) : invest;
      double savingsRate = 0.0;
      HealthStatus status;
      int score;

      if (income <= 0) {
        savingsRate = 0.0;
        status = HealthStatus.warning;
        score = 5;
      } else {
        savingsRate = (totalSavedAndInvested / income) * 100.0;
        if (savingsRate >= input.targetSavingsRatePercent) {
          status = HealthStatus.pass;
          score = 10;
        } else if (savingsRate >= input.targetSavingsRatePercent * 0.5) {
          status = HealthStatus.warning;
          score = 5;
          recommendations.add(isThai
              ? 'อัตราการออมต่ำกว่าเป้าหมาย (${savingsRate.toStringAsFixed(1)}%): ควรพยายามออมหรือลงทุนให้ได้อย่างน้อย 10% ของรายได้'
              : 'Savings Rate Below Target (${savingsRate.toStringAsFixed(1)}%): Aim to save or invest at least 10% of income.');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add(isThai
              ? 'อัตราการออมติดลบหรือน้อยมาก: รายจ่ายแทบจะเท่ากับหรือมากกว่ารายได้ ควรทบทวนงบประมาณรายจ่าย'
              : 'Zero or Negative Savings: Expenses equal or exceed earnings. Review monthly budget.');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 7,
        code: 'savings_rate',
        title: isThai ? 'อัตราการออมและลงทุน' : 'Savings & Investment Rate',
        subtitle: isThai ? 'วินัยในการกันเงินเพื่ออนาคตในแต่ละเดือน' : 'Monthly discipline in setting aside money for future',
        currentValue: savingsRate,
        formattedValue: '${savingsRate.toStringAsFixed(1)}%',
        targetThreshold: '> ${input.targetSavingsRatePercent.toStringAsFixed(1)}%',
        status: status,
        score: score,
        maxScore: 10,
        formulaDescription: isThai
            ? '(เงินออมสุทธิ + เงินลงทุน) ÷ รายรับประจำเดือน'
            : '(Net Savings + Investments) ÷ Monthly Income',
        breakdownItems: [
          MetricBreakdownItem(
            label: isThai ? 'รายรับประจำเดือนนี้' : 'Current Month Income',
            formattedValue: Money(income).format(symbol: '฿'),
          ),
          MetricBreakdownItem(
            label: isThai ? 'รายจ่ายประจำเดือนนี้' : 'Current Month Expenses',
            formattedValue: Money(expense).format(symbol: '฿'),
          ),
          MetricBreakdownItem(
            label: isThai ? 'เงินออมคงเหลือ + เงินลงทุนเพิ่ม' : 'Savings Buffer + New Investments',
            formattedValue: Money(totalSavedAndInvested).format(symbol: '฿'),
          ),
        ],
        recommendation: status == HealthStatus.pass
            ? (isThai
                ? 'ยอดเยี่ยม: ออมและลงทุนได้สม่ำเสมอเกิน 10% ของรายได้'
                : 'Excellent: Consistent savings and investment exceeding 10% of income.')
            : (isThai
                ? 'ใช้เทคนิค "ออมก่อนใช้" โดยหักเงินออม/ลงทุนทันทีที่เงินเดือนออก'
                : 'Pay yourself first by automating savings right upon payday.'),
      ));
    }

    // -------------------------------------------------------------
    // 8. สัดส่วนการลงทุน (Investment Ratio) - Max 10 pts
    // สูตร: มูลค่าพอร์ตลงทุนปัจจุบัน ÷ ความมั่งคั่งสุทธิ (> 50.0%)
    // -------------------------------------------------------------
    {
      final portMoney = Money(input.portfolioMarketValueSatang);
      final netWorthSatang = input.totalAssetsSatang - input.totalDebtsSatang;
      final netWorthMoney = Money(netWorthSatang);
      double invRatio = 0.0;
      HealthStatus status;
      int score;

      if (netWorthSatang <= 0) {
        invRatio = 0.0;
        status = HealthStatus.fail;
        score = 0;
        recommendations.add(isThai
            ? 'ความมั่งคั่งสุทธิติดลบ: หนี้สินสูงกว่าทรัพย์สิน ควรเร่งจัดการหนี้ก่อนเน้นลงทุน'
            : 'Negative Net Worth: Liabilities exceed assets. Prioritize debt reduction before investing.');
      } else {
        invRatio = (input.portfolioMarketValueSatang / netWorthSatang) * 100.0;
        if (invRatio >= input.targetInvestmentRatioPercent) {
          status = HealthStatus.pass;
          score = 10;
        } else if (invRatio >= input.targetInvestmentRatioPercent * 0.6) {
          status = HealthStatus.warning;
          score = 5;
          recommendations.add(isThai
              ? 'สัดส่วนสินทรัพย์ลงทุนยังไม่ถึง 50% (${invRatio.toStringAsFixed(1)}%): หลังจากมีเงินสำรองฉุกเฉินพอแล้ว ควรทยอยนำเงินไปลงทุนเพื่อสู้เงินเฟ้อ'
              : 'Investment Ratio Below 50% (${invRatio.toStringAsFixed(1)}%): With emergency funds ready, allocate to investments to beat inflation.');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add(isThai
              ? 'เงินส่วนใหญ่ยังจมอยู่ในสินทรัพย์ไม่ก่อให้เกิดรายได้: สินทรัพย์ลงทุนมีเพียง ${invRatio.toStringAsFixed(1)}% ของความมั่งคั่งสุทธิ'
              : 'Low Productive Capital: Invested assets represent only ${invRatio.toStringAsFixed(1)}% of net worth.');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 8,
        code: 'investment_ratio',
        title: isThai ? 'สัดส่วนสินทรัพย์ลงทุน' : 'Investment Ratio',
        subtitle: isThai ? 'ระดับการนำเงินไปต่อยอดเพื่อสร้างผลตอบแทน' : 'Level of productive wealth invested for compound growth',
        currentValue: invRatio,
        formattedValue: '${invRatio.toStringAsFixed(1)}%',
        targetThreshold: '> ${input.targetInvestmentRatioPercent.toStringAsFixed(1)}%',
        status: status,
        score: score,
        maxScore: 10,
        formulaDescription: isThai
            ? 'มูลค่าพอร์ตลงทุน ÷ ความมั่งคั่งสุทธิ (สินทรัพย์ − หนี้สิน)'
            : 'Portfolio Value ÷ Net Worth (Assets − Debts)',
        breakdownItems: [
          MetricBreakdownItem(
            label: isThai ? 'มูลค่าพอร์ตลงทุนปัจจุบัน (MTM)' : 'Current Portfolio Value (MTM)',
            formattedValue: portMoney.format(symbol: '฿'),
          ),
          MetricBreakdownItem(
            label: isThai ? 'ความมั่งคั่งสุทธิ (Net Worth)' : 'Net Worth (Assets − Debts)',
            formattedValue: netWorthMoney.format(symbol: '฿'),
          ),
        ],
        recommendation: status == HealthStatus.pass
            ? (isThai
                ? 'ยอดเยี่ยม: เงินส่วนใหญ่ทำงานงอกเงยอยู่ในสินทรัพย์ลงทุน'
                : 'Excellent: Significant net worth is actively compounding in productive assets.')
            : (isThai
                ? 'เมื่อเงินสำรองพร้อมแล้ว ทยอยแบ่งเงินฝากส่วนเกินไปลงทุนในสินทรัพย์ที่มีผลตอบแทนสูงขึ้น'
                : 'Once emergency reserve is ready, allocate surplus cash to higher-yield assets.'),
      ));
    }

    // -------------------------------------------------------------
    // Total Score Calculation (0 to 100)
    // -------------------------------------------------------------
    int totalScore = 0;
    for (final m in metrics) {
      totalScore += m.score;
    }
    if (totalScore > 100) totalScore = 100;

    HealthStatus overallStatus;
    if (totalScore >= 80) {
      overallStatus = HealthStatus.pass;
    } else if (totalScore >= 50) {
      overallStatus = HealthStatus.warning;
    } else {
      overallStatus = HealthStatus.fail;
    }

    return FinancialHealthSummary(
      totalScore: totalScore,
      overallStatus: overallStatus,
      metrics: metrics,
      prioritizedRecommendations: recommendations,
    );
  }
}
