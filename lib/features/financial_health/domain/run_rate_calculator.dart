class RunRateForecast {
  final int daysPassed;
  final int totalDaysInMonth;
  final int remainingDaysInMonth;
  final int accumulatedExpenseSatang;
  final int projectedMonthEndSatang;
  final int monthlyBudgetLimitSatang;
  final int varianceSatang; // positive = over budget, negative = under budget
  final int recommendedDailySpendSatang;
  final int accumulatedYearExpenseSatang;
  final int projectedYearEndSatang;

  const RunRateForecast({
    required this.daysPassed,
    required this.totalDaysInMonth,
    required this.remainingDaysInMonth,
    required this.accumulatedExpenseSatang,
    required this.projectedMonthEndSatang,
    required this.monthlyBudgetLimitSatang,
    required this.varianceSatang,
    required this.recommendedDailySpendSatang,
    required this.accumulatedYearExpenseSatang,
    required this.projectedYearEndSatang,
  });
}

class RunRateCalculator {
  /// Calculates run-rate forecasting for current month and year.
  /// Formula: (Accumulated Expense / Days Passed) * Total Days In Month
  static RunRateForecast calculate({
    required DateTime currentDate,
    required int accumulatedMonthExpenseSatang,
    required int monthlyBudgetLimitSatang,
    required int accumulatedYearExpenseSatang,
  }) {
    final now = currentDate;
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysPassed = now.day;
    final remainingDays = totalDaysInMonth - daysPassed;

    // Run-rate per day in current month
    final dailyRunRate = daysPassed > 0
        ? (accumulatedMonthExpenseSatang / daysPassed).round()
        : 0;

    final projectedMonthEnd = (dailyRunRate * totalDaysInMonth);
    final variance = projectedMonthEnd - monthlyBudgetLimitSatang;

    // Remaining budget that can be spent over remaining days
    final remainingBudget = monthlyBudgetLimitSatang - accumulatedMonthExpenseSatang;
    final recommendedDaily = remainingDays > 0 && remainingBudget > 0
        ? (remainingBudget / remainingDays).round()
        : 0;

    // Year-end projection: accumulated year expense + (current monthly run rate * remaining months)
    final remainingMonthsInYear = 12 - now.month;
    final projectedYearEnd = accumulatedYearExpenseSatang + (projectedMonthEnd * remainingMonthsInYear);

    return RunRateForecast(
      daysPassed: daysPassed,
      totalDaysInMonth: totalDaysInMonth,
      remainingDaysInMonth: remainingDays,
      accumulatedExpenseSatang: accumulatedMonthExpenseSatang,
      projectedMonthEndSatang: projectedMonthEnd,
      monthlyBudgetLimitSatang: monthlyBudgetLimitSatang,
      varianceSatang: variance,
      recommendedDailySpendSatang: recommendedDaily,
      accumulatedYearExpenseSatang: accumulatedYearExpenseSatang,
      projectedYearEndSatang: projectedYearEnd,
    );
  }
}
