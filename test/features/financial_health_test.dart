import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/features/financial_health/domain/financial_health_calculator.dart';
import 'package:myfinance/features/financial_health/domain/models/health_metric_result.dart';

void main() {
  group('Financial Health Calculator - 8 Metrics & Scoring Tests', () {
    test('Healthy Financial Profile gets 100/100 score and all metrics pass', () {
      final input = FinancialHealthInputData(
        liquidAssetsSatang: 60000000, // 600,000 THB
        totalAssetsSatang: 300000000, // 3,000,000 THB
        totalDebtsSatang: 50000000, // 500,000 THB (16.6% < 50%)
        shortTermDebtsSatang: 3000000, // 30,000 THB (liquidity = 20x > 1.0)
        monthlyDebtPaymentSatang: 1500000, // 15,000 THB
        avgMonthlyExpenseSatang: 5000000, // 50,000 THB (emergency = 12 mo >= 6.0)
        avgMonthlyIncomeSatang: 10000000, // 100,000 THB (DTI = 15% < 40%)
        currentMonthIncomeSatang: 10000000,
        currentMonthExpenseSatang: 5000000, // savings = 50,000
        currentMonthInvestmentSatang: 2000000, // invest = 20,000 (rate = 70% > 10%)
        portfolioMarketValueSatang: 180000000, // 1.8M THB (net worth = 2.5M, ratio = 72% > 50%)
        sumInsuredSatang: 100000000, // 1,000,000 THB
        medicalCoverageSatang: 100000000, // 1,000,000 THB
        estimatedMedicalCostSatang: 50000000, // 500,000 THB (coverage diff = +500,000 > 0)
        familyReserveSatang: 50000000, // 500,000 THB (security balance > 0)
      );

      final summary = FinancialHealthCalculator.calculate(input);

      expect(summary.totalScore, equals(100));
      expect(summary.overallStatus, equals(HealthStatus.pass));
      expect(summary.metrics.length, equals(8));
      expect(summary.metrics.every((m) => m.status == HealthStatus.pass), isTrue);
      expect(summary.prioritizedRecommendations, isEmpty);
    });

    test('Zero debt and zero expense edge cases do not divide by zero', () {
      const input = FinancialHealthInputData(
        liquidAssetsSatang: 10000000, // 100,000 THB
        totalAssetsSatang: 10000000,
        totalDebtsSatang: 0,
        shortTermDebtsSatang: 0,
        monthlyDebtPaymentSatang: 0,
        avgMonthlyExpenseSatang: 0,
        avgMonthlyIncomeSatang: 5000000, // 50,000 THB
        currentMonthIncomeSatang: 5000000,
        currentMonthExpenseSatang: 0,
        currentMonthInvestmentSatang: 0,
        portfolioMarketValueSatang: 0,
        sumInsuredSatang: 0,
        medicalCoverageSatang: 0,
        estimatedMedicalCostSatang: 0,
      );

      final summary = FinancialHealthCalculator.calculate(input);

      // Basic Liquidity should pass with 0 debts
      final m1 = summary.metrics.firstWhere((m) => m.code == 'basic_liquidity');
      expect(m1.status, equals(HealthStatus.pass));
      expect(m1.score, equals(15));

      // Emergency fund should pass when expenses are 0
      final m2 = summary.metrics.firstWhere((m) => m.code == 'emergency_fund');
      expect(m2.status, equals(HealthStatus.pass));
      expect(m2.score, equals(15));

      // Debt to Asset should pass with 0 debt
      final m3 = summary.metrics.firstWhere((m) => m.code == 'debt_to_asset');
      expect(m3.status, equals(HealthStatus.pass));
      expect(m3.score, equals(15));

      // DTI should pass with 0 debt payment
      final m4 = summary.metrics.firstWhere((m) => m.code == 'dti');
      expect(m4.status, equals(HealthStatus.pass));
      expect(m4.score, equals(15));
    });

    test('Critical Debt & Low Liquidity triggers warnings/fails and prioritized recommendations', () {
      const input = FinancialHealthInputData(
        liquidAssetsSatang: 2000000, // 20,000 THB
        totalAssetsSatang: 100000000, // 1,000,000 THB
        totalDebtsSatang: 75000000, // 750,000 THB (75% debt-to-asset -> FAIL)
        shortTermDebtsSatang: 5000000, // 50,000 THB (liquidity = 0.4x -> FAIL)
        monthlyDebtPaymentSatang: 3000000, // 30,000 THB
        avgMonthlyExpenseSatang: 3000000, // 30,000 THB (emergency = 0.67 mo -> FAIL)
        avgMonthlyIncomeSatang: 5000000, // 50,000 THB (DTI = 60% -> FAIL)
        currentMonthIncomeSatang: 5000000,
        currentMonthExpenseSatang: 4800000, // savings = 2,000 THB (4% -> FAIL)
        currentMonthInvestmentSatang: 0,
        portfolioMarketValueSatang: 10000000, // 100,000 THB (net worth = 250k, ratio = 40% -> WARNING)
        sumInsuredSatang: 0, // No life insurance -> FAIL
        medicalCoverageSatang: 0, // No health insurance -> FAIL
        estimatedMedicalCostSatang: 50000000, // 500,000 THB
        familyReserveSatang: 20000000, // 200,000 THB
      );

      final summary = FinancialHealthCalculator.calculate(input);

      expect(summary.totalScore, lessThan(30));
      expect(summary.overallStatus, equals(HealthStatus.fail));
      expect(summary.prioritizedRecommendations, isNotEmpty);

      // Verify foundational safety issues are reported
      expect(summary.prioritizedRecommendations.any((r) => r.contains('สภาพคล่อง')), isTrue);
      expect(summary.prioritizedRecommendations.any((r) => r.contains('เงินออมฉุกเฉิน')), isTrue);
      expect(summary.prioritizedRecommendations.any((r) => r.contains('หนี้')), isTrue);
    });

    test('Buffer thresholds in Family Security and Health Coverage trigger Warning before Fail', () {
      const input = FinancialHealthInputData(
        liquidAssetsSatang: 50000000,
        totalAssetsSatang: 100000000,
        totalDebtsSatang: 20000000,
        shortTermDebtsSatang: 1000000,
        monthlyDebtPaymentSatang: 500000,
        avgMonthlyExpenseSatang: 3000000,
        avgMonthlyIncomeSatang: 8000000,
        currentMonthIncomeSatang: 8000000,
        currentMonthExpenseSatang: 3000000,
        currentMonthInvestmentSatang: 2000000,
        portfolioMarketValueSatang: 50000000,
        sumInsuredSatang: 0,
        medicalCoverageSatang: 45000000, // 450,000 THB
        estimatedMedicalCostSatang: 50000000, // 500,000 THB (diff = -50,000 THB -> Warning)
      );

      final summary = FinancialHealthCalculator.calculate(input);

      final m6 = summary.metrics.firstWhere((m) => m.code == 'health_coverage');
      expect(m6.status, equals(HealthStatus.warning));
      expect(m6.score, equals(5)); // 5/10 for warning
    });
  });
}
