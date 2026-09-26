import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/features/financial_health/domain/run_rate_calculator.dart';

void main() {
  group('Run Rate Calculator - Monthly and Year-end Forecasting Tests', () {
    test('Mid-month calculation projects end-of-month and compares with budget ceiling', () {
      // 15th of September (30 days in September)
      final currentDate = DateTime(2026, 9, 15);
      // Spent 15,000 THB in 15 days (1,000 THB/day = 100,000 satang/day)
      const accumulatedMonthSatang = 1500000;
      // Budget limit = 25,000 THB (2,500,000 satang)
      const monthlyBudgetLimitSatang = 2500000;
      // Year-to-date spent = 120,000 THB (12,000,000 satang)
      const accumulatedYearSatang = 12000000;

      final forecast = RunRateCalculator.calculate(
        currentDate: currentDate,
        accumulatedMonthExpenseSatang: accumulatedMonthSatang,
        monthlyBudgetLimitSatang: monthlyBudgetLimitSatang,
        accumulatedYearExpenseSatang: accumulatedYearSatang,
      );

      expect(forecast.daysPassed, equals(15));
      expect(forecast.totalDaysInMonth, equals(30));
      expect(forecast.remainingDaysInMonth, equals(15));

      // Projected month-end: 1,000 THB/day * 30 days = 30,000 THB (3,000,000 satang)
      expect(forecast.projectedMonthEndSatang, equals(3000000));

      // Variance: 30,000 - 25,000 = +5,000 THB over budget
      expect(forecast.varianceSatang, equals(500000));

      // Recommended daily spend to stay within 25,000 THB:
      // Remaining budget = 25,000 - 15,000 = 10,000 THB across 15 days = ~666.67 THB (66,667 satang)
      expect(forecast.recommendedDailySpendSatang, equals(66667));

      // Year-end projection:
      // YTD so far = 120,000 THB (up to Sept 15)
      // Remaining for Sept (15-30) = 30,000 - 15,000 = 15,000 THB
      // Remaining 3 full months (Oct, Nov, Dec) = 30,000 * 3 = 90,000 THB
      // Total Year-end = 120,000 + 15,000 + 90,000 = 225,000 THB (22,500,000 satang)
      expect(forecast.projectedYearEndSatang, equals(22500000));
    });

    test('First day of month handles 1 day passed without zero division', () {
      final currentDate = DateTime(2026, 1, 1);
      const accumulatedMonthSatang = 200000; // 2,000 THB on day 1
      const monthlyBudgetLimitSatang = 6000000; // 60,000 THB
      const accumulatedYearSatang = 200000;

      final forecast = RunRateCalculator.calculate(
        currentDate: currentDate,
        accumulatedMonthExpenseSatang: accumulatedMonthSatang,
        monthlyBudgetLimitSatang: monthlyBudgetLimitSatang,
        accumulatedYearExpenseSatang: accumulatedYearSatang,
      );

      expect(forecast.daysPassed, equals(1));
      expect(forecast.totalDaysInMonth, equals(31));
      expect(forecast.projectedMonthEndSatang, equals(6200000)); // 2k * 31 = 62k THB
      expect(forecast.varianceSatang, equals(200000)); // 62k - 60k = +2k
    });

    test('February Leap year calculation accurately uses 29 days', () {
      final currentDate = DateTime(2028, 2, 10); // 2028 is a leap year
      const accumulatedMonthSatang = 1000000; // 10,000 THB in 10 days = 1,000 THB/day

      final forecast = RunRateCalculator.calculate(
        currentDate: currentDate,
        accumulatedMonthExpenseSatang: accumulatedMonthSatang,
        monthlyBudgetLimitSatang: 3000000,
        accumulatedYearExpenseSatang: 5000000,
      );

      expect(forecast.totalDaysInMonth, equals(29));
      expect(forecast.projectedMonthEndSatang, equals(2900000)); // 1k * 29 = 29,000 THB
      expect(forecast.varianceSatang, equals(-100000)); // 1,000 THB under budget
    });
  });
}
