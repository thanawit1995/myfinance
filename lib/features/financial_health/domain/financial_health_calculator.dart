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
  static FinancialHealthSummary calculate(FinancialHealthInputData input) {
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
          recommendations.add('สภาพคล่องพื้นฐานตึงตัว: ควรเพิ่มเงินสดสำรองหรือเร่งลดหนี้ระยะสั้นให้สินทรัพย์สภาพคล่องสูงกว่าหนี้ระยะสั้น');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add('วิกฤตสภาพคล่องระยะสั้น: สินทรัพย์สภาพคล่องไม่พอชำระหนี้ระยะสั้น ควรระมัดระวังการผิดนัดชำระหนี้');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 1,
        code: 'basic_liquidity',
        title: 'สภาพคล่องพื้นฐาน',
        subtitle: 'ความสามารถในการชำระหนี้ระยะสั้นทันที',
        currentValue: ratio,
        formattedValue: input.shortTermDebtsSatang <= 0 ? 'ปลอดภัย (ไม่มีหนี้ระยะสั้น)' : '${ratio.toStringAsFixed(2)} เท่า',
        targetThreshold: '> ${input.targetBasicLiquidity.toStringAsFixed(1)} เท่า',
        status: status,
        score: score,
        maxScore: 15,
        formulaDescription: 'สินทรัพย์สภาพคล่อง ÷ หนี้สินระยะสั้น',
        breakdownItems: [
          MetricBreakdownItem(label: 'สินทรัพย์สภาพคล่อง (เงินสด+เงินฝาก)', formattedValue: liquidMoney.format(symbol: '฿')),
          MetricBreakdownItem(label: 'หนี้สินระยะสั้น (บัตรเครดิต/หนี้ <= 1 ปี)', formattedValue: shortDebtMoney.format(symbol: '฿')),
        ],
        recommendation: status == HealthStatus.pass
            ? 'ยอดเยี่ยม: คุณมีสินทรัพย์สภาพคล่องเพียงพอรับมือหนี้ระยะสั้นทั้งหมด'
            : 'ควรกันเงินฝากไว้รองรับหนี้ระยะสั้นอย่างน้อย 1 เท่าเสมอ',
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
          recommendations.add('เงินออมฉุกเฉินอยู่ในระดับเฝ้าระวัง: ปัจจุบันมี ${months.toStringAsFixed(1)} เดือน ควรสะสมเพิ่มให้ครบ ${input.targetEmergencyMonths.toStringAsFixed(0)} เดือน');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add('เงินออมฉุกเฉินไม่เพียงพอ: มีไม่ถึง 3 เดือน เสี่ยงมากหากขาดรายได้กะทันหัน ควรชะลอการลงทุนและสะสมเงินออมฉุกเฉินก่อน');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 2,
        code: 'emergency_fund',
        title: 'เงินออมฉุกเฉิน',
        subtitle: 'ระยะเวลาที่อยู่รอดได้หากขาดรายได้',
        currentValue: months,
        formattedValue: '${months >= 99 ? '> 99' : months.toStringAsFixed(1)} เดือน',
        targetThreshold: '≥ ${input.targetEmergencyMonths.toStringAsFixed(1)} เดือน',
        status: status,
        score: score,
        maxScore: 15,
        formulaDescription: 'สินทรัพย์สภาพคล่อง ÷ ค่าใช้จ่ายเฉลี่ยต่อเดือน (6 เดือนย้อนหลัง)',
        breakdownItems: [
          MetricBreakdownItem(label: 'สินทรัพย์สภาพคล่อง', formattedValue: liquidMoney.format(symbol: '฿')),
          MetricBreakdownItem(label: 'ค่าใช้จ่ายเฉลี่ยต่อเดือน', formattedValue: avgExpMoney.format(symbol: '฿')),
        ],
        recommendation: status == HealthStatus.pass
            ? 'ยอดเยี่ยม: มีเงินสำรองฉุกเฉินรองรับค่าใช้จ่ายได้สบายใจ'
            : 'ตั้งเป้าทยอยสะสมเงินออมฉุกเฉินไว้ในบัญชีดอกเบี้ยสูงหรือกองทุนตลาดเงิน',
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
          recommendations.add('สัดส่วนหนี้สินค่อนข้างสูง (${pct.toStringAsFixed(1)}%): ควรควบคุมการก่อหนี้ใหม่และเน้นทยอยลดหนี้ดอกเบี้ยสูง');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add('ภาระหนี้สินเกินเกณฑ์อันตราย (${pct.toStringAsFixed(1)}%): หนี้สินเกินครึ่งหนึ่งของทรัพย์สินทั้งหมด เสี่ยงต่อความมั่นคงทางการเงิน');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 3,
        code: 'debt_to_asset',
        title: 'ภาระหนี้สินรวม',
        subtitle: 'สัดส่วนหนี้สินเทียบกับทรัพย์สินที่มี',
        currentValue: pct,
        formattedValue: '${pct.toStringAsFixed(1)}%',
        targetThreshold: '< ${input.targetDebtToAssetPercent.toStringAsFixed(1)}%',
        status: status,
        score: score,
        maxScore: 15,
        formulaDescription: 'หนี้สินรวม ÷ สินทรัพย์รวม',
        breakdownItems: [
          MetricBreakdownItem(label: 'หนี้สินคงค้างรวมทั้งหมด', formattedValue: debtMoney.format(symbol: '฿')),
          MetricBreakdownItem(label: 'สินทรัพย์รวม (เงินฝาก + พอร์ตลงทุน)', formattedValue: assetMoney.format(symbol: '฿')),
        ],
        recommendation: status == HealthStatus.pass
            ? 'ยอดเยี่ยม: ภาระหนี้สินอยู่ในระดับปลอดภัย ไม่เกิน 50% ของสินทรัพย์'
            : 'ควรหยุดสร้างหนี้ใหม่ และวางแผนโปะหนี้เพื่อลดดอกเบี้ยสะสม',
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
          recommendations.add('ค่างวดหนี้เริ่มตึงมือ (${dti.toStringAsFixed(1)}% ของรายรับ): ควรระวังค่าใช้จ่ายไม่คาดคิดที่อาจทำให้สภาพคล่องสะดุด');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add('ภาระผ่อนหนี้สูงเกินเกณฑ์ความปลอดภัย (${dti.toStringAsFixed(1)}%): ค่างวดหนี้กินรายได้เกือบครึ่งหนึ่ง เสี่ยงต่อการหมุนเงินไม่ทัน');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 4,
        code: 'dti',
        title: 'ความสามารถชำระหนี้ (DTI)',
        subtitle: 'ภาระค่างวดหนี้เทียบกับรายได้ประจำเดือน',
        currentValue: dti,
        formattedValue: '${dti.toStringAsFixed(1)}%',
        targetThreshold: '< ${input.targetDtiPercent.toStringAsFixed(1)}%',
        status: status,
        score: score,
        maxScore: 15,
        formulaDescription: 'เงินผ่อนชำระหนี้ต่อเดือน ÷ รายรับเฉลี่ยต่อเดือน',
        breakdownItems: [
          MetricBreakdownItem(label: 'ค่างวดผ่อนชำระต่อเดือนรวม', formattedValue: monthlyDebtMoney.format(symbol: '฿')),
          MetricBreakdownItem(label: 'รายรับเฉลี่ยต่อเดือน (6 เดือนย้อนหลัง)', formattedValue: avgIncMoney.format(symbol: '฿')),
        ],
        recommendation: status == HealthStatus.pass
            ? 'ยอดเยี่ยม: ค่างวดหนี้ไม่เกิน 40% ของรายรับ กระแสเงินสดยังมีความคล่องตัวสูง'
            : 'ควรเจรจารีไฟแนนซ์เพื่อยืดค่างวด หรือลดรายจ่ายส่วนอื่นเพื่อรักษาสภาพคล่อง',
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
        recommendations.add('ความมั่นคงครอบครัวอยู่ในระดับเฝ้าระวัง: หากเกิดเหตุฉุกเฉิน ทุนประกันอาจเหลือไม่ครอบคลุมหนี้สินและเงินดูแลครอบครัว');
      } else {
        status = HealthStatus.fail;
        score = 0;
        recommendations.add('ความคุ้มครองชีวิตและครอบครัวไม่เพียงพอ: หนี้สินสูงกว่าสินทรัพย์และประกันรวมกัน ควรพิจารณาทำประกันชีวิตคุ้มครองภาระหนี้');
      }

      metrics.add(HealthMetricResult(
        metricIndex: 5,
        code: 'family_security',
        title: 'ความมั่นคงครอบครัว',
        subtitle: 'ความพร้อมคุ้มครองคนข้างหลังกรณีเกิดเหตุไม่คาดฝัน',
        currentValue: balanceSatang,
        formattedValue: balanceSatang >= 0 ? '+${balMoney.format(symbol: '฿')}' : balMoney.format(symbol: '฿'),
        targetThreshold: '> 0 ฿',
        status: status,
        score: score,
        maxScore: 10,
        formulaDescription: 'สินทรัพย์รวม + ทุนประกันชีวิต − (หนี้สินรวม + เงินทุนสำรองครอบครัว)',
        breakdownItems: [
          MetricBreakdownItem(label: 'สินทรัพย์รวม', formattedValue: Money(totalAssets).format(symbol: '฿')),
          MetricBreakdownItem(label: 'ทุนประกันชีวิตและทุพพลภาพรวม', formattedValue: Money(sumInsured).format(symbol: '฿')),
          MetricBreakdownItem(label: 'หนี้สินคงค้างรวม', formattedValue: Money(totalDebts).format(symbol: '฿')),
          MetricBreakdownItem(label: 'เงินทุนสำรองครอบครัวที่ตั้งไว้', formattedValue: Money(familyReserve).format(symbol: '฿')),
        ],
        recommendation: status == HealthStatus.pass
            ? 'ยอดเยี่ยม: มีสินทรัพย์และประกันคุ้มครองภาระทางการเงินครบถ้วน'
            : 'ควรทำประกันชีวิตแบบชั่วระยะเวลา (Term) เพื่อปิดความเสี่ยงภาระหนี้สิน',
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
        recommendations.add('วงเงินค่ารักษาพยาบาลค่อนข้างกระชั้นชิด: อาจมีส่วนต่างค่ารักษาที่ต้องใช้เงินออมจ่ายเอง');
      } else {
        status = HealthStatus.fail;
        score = 0;
        recommendations.add('ความคุ้มครองสุขภาพไม่เพียงพอ: วงเงินประกันสุขภาพต่ำกว่าค่ารักษาโรคร้ายแรงที่ประเมินไว้ เสี่ยงกระทบเงินเก็บก้อนใหญ่');
      }

      metrics.add(HealthMetricResult(
        metricIndex: 6,
        code: 'health_coverage',
        title: 'ความคุ้มครองสุขภาพ',
        subtitle: 'ความเพียงพอของสวัสดิการประกันสุขภาพ',
        currentValue: diffSatang,
        formattedValue: diffSatang >= 0 ? '+${diffMoney.format(symbol: '฿')}' : diffMoney.format(symbol: '฿'),
        targetThreshold: '> 0 ฿',
        status: status,
        score: score,
        maxScore: 10,
        formulaDescription: 'วงเงินค่ารักษาพยาบาลรวม − ค่ารักษาที่ประเมินไว้',
        breakdownItems: [
          MetricBreakdownItem(label: 'วงเงินค่ารักษาพยาบาลจากประกันรวม', formattedValue: Money(coverage).format(symbol: '฿')),
          MetricBreakdownItem(label: 'ค่ารักษาพยาบาลที่ประเมินไว้', formattedValue: Money(estimatedCost).format(symbol: '฿')),
        ],
        recommendation: status == HealthStatus.pass
            ? 'ยอดเยี่ยม: วงเงินค่ารักษาพยาบาลครอบคลุมตามเป้าหมายที่ตั้งไว้'
            : 'ควรพิจารณาทำประกันสุขภาพแบบเหมาจ่าย หรือประกันโรคร้ายแรงเพิ่มเติม',
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
          recommendations.add('อัตราการออมต่ำกว่าเป้าหมาย (${savingsRate.toStringAsFixed(1)}%): ควรพยายามออมหรือลงทุนให้ได้อย่างน้อย 10% ของรายได้');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add('อัตราการออมติดลบหรือน้อยมาก: รายจ่ายแทบจะเท่ากับหรือมากกว่ารายได้ ควรทบทวนงบประมาณรายจ่าย');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 7,
        code: 'savings_rate',
        title: 'อัตราการออมและลงทุน',
        subtitle: 'วินัยในการกันเงินเพื่ออนาคตในแต่ละเดือน',
        currentValue: savingsRate,
        formattedValue: '${savingsRate.toStringAsFixed(1)}%',
        targetThreshold: '> ${input.targetSavingsRatePercent.toStringAsFixed(1)}%',
        status: status,
        score: score,
        maxScore: 10,
        formulaDescription: '(เงินออมสุทธิ + เงินลงทุน) ÷ รายรับประจำเดือน',
        breakdownItems: [
          MetricBreakdownItem(label: 'รายรับประจำเดือนนี้', formattedValue: Money(income).format(symbol: '฿')),
          MetricBreakdownItem(label: 'รายจ่ายประจำเดือนนี้', formattedValue: Money(expense).format(symbol: '฿')),
          MetricBreakdownItem(label: 'เงินออมคงเหลือ + เงินลงทุนเพิ่ม', formattedValue: Money(totalSavedAndInvested).format(symbol: '฿')),
        ],
        recommendation: status == HealthStatus.pass
            ? 'ยอดเยี่ยม: ออมและลงทุนได้สม่ำเสมอเกิน 10% ของรายได้'
            : 'ใช้เทคนิค "ออมก่อนใช้" โดยหักเงินออม/ลงทุนทันทีที่เงินเดือนออก',
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
        recommendations.add('ความมั่งคั่งสุทธิติดลบ: หนี้สินสูงกว่าทรัพย์สิน ควรเร่งจัดการหนี้ก่อนเน้นลงทุน');
      } else {
        invRatio = (input.portfolioMarketValueSatang / netWorthSatang) * 100.0;
        if (invRatio >= input.targetInvestmentRatioPercent) {
          status = HealthStatus.pass;
          score = 10;
        } else if (invRatio >= input.targetInvestmentRatioPercent * 0.6) {
          status = HealthStatus.warning;
          score = 5;
          recommendations.add('สัดส่วนสินทรัพย์ลงทุนยังไม่ถึง 50% (${invRatio.toStringAsFixed(1)}%): หลังจากมีเงินสำรองฉุกเฉินพอแล้ว ควรทยอยนำเงินไปลงทุนเพื่อสู้เงินเฟ้อ');
        } else {
          status = HealthStatus.fail;
          score = 0;
          recommendations.add('เงินส่วนใหญ่ยังจมอยู่ในสินทรัพย์ไม่ก่อให้เกิดรายได้: สินทรัพย์ลงทุนมีเพียง ${invRatio.toStringAsFixed(1)}% ของความมั่งคั่งสุทธิ');
        }
      }

      metrics.add(HealthMetricResult(
        metricIndex: 8,
        code: 'investment_ratio',
        title: 'สัดส่วนสินทรัพย์ลงทุน',
        subtitle: 'ระดับการนำเงินไปต่อยอดเพื่อสร้างผลตอบแทน',
        currentValue: invRatio,
        formattedValue: '${invRatio.toStringAsFixed(1)}%',
        targetThreshold: '> ${input.targetInvestmentRatioPercent.toStringAsFixed(1)}%',
        status: status,
        score: score,
        maxScore: 10,
        formulaDescription: 'มูลค่าพอร์ตลงทุน ÷ ความมั่งคั่งสุทธิ (สินทรัพย์ − หนี้สิน)',
        breakdownItems: [
          MetricBreakdownItem(label: 'มูลค่าพอร์ตลงทุนปัจจุบัน (MTM)', formattedValue: portMoney.format(symbol: '฿')),
          MetricBreakdownItem(label: 'ความมั่งคั่งสุทธิ (Net Worth)', formattedValue: netWorthMoney.format(symbol: '฿')),
        ],
        recommendation: status == HealthStatus.pass
            ? 'ยอดเยี่ยม: เงินส่วนใหญ่ทำงานงอกเงยอยู่ในสินทรัพย์ลงทุน'
            : 'เมื่อเงินสำรองพร้อมแล้ว ทยอยแบ่งเงินฝากส่วนเกินไปลงทุนในสินทรัพย์ที่มีผลตอบแทนสูงขึ้น',
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
