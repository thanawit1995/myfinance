import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/vault_theme.dart';

class ExpenseTrendProjectionCard extends StatelessWidget {
  final Map<int, int> dailyExpenses; // day (1..currentDay) -> satang
  final int currentDay;
  final int daysInMonth;
  final int totalExpenseSatang;
  final int totalBudgetSatang;

  const ExpenseTrendProjectionCard({
    super.key,
    required this.dailyExpenses,
    required this.currentDay,
    required this.daysInMonth,
    required this.totalExpenseSatang,
    required this.totalBudgetSatang,
  });

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final isLumi = VaultTheme.isLumi(context);
    final isDark = VaultTheme.isDark(context);

    // 1. Calculate actual cumulative expenses up to currentDay
    final List<FlSpot> actualSpots = [];
    int runningSumSatang = 0;
    for (int day = 1; day <= currentDay; day++) {
      final dayAmount = dailyExpenses[day] ?? 0;
      runningSumSatang += dayAmount;
      actualSpots.add(FlSpot(day.toDouble(), runningSumSatang / 100.0));
    }

    // Edge case: if day 1 hasn't recorded yet, ensure starting at day 1
    if (actualSpots.isEmpty) {
      actualSpots.add(const FlSpot(1, 0));
    }

    // 2. Projected cumulative expenses from currentDay to daysInMonth
    final List<FlSpot> projectedSpots = [];
    final int safeCurrentDay = currentDay > 0 ? currentDay : 1;
    final int dailyAverageSatang = (runningSumSatang / safeCurrentDay).round();
    final int remainingDays = (daysInMonth - currentDay).clamp(0, 31);
    final int projectedEndSatang = runningSumSatang + (dailyAverageSatang * remainingDays);

    if (currentDay < daysInMonth) {
      // Connects from the last actual spot to future days
      projectedSpots.add(FlSpot(currentDay.toDouble(), runningSumSatang / 100.0));
      for (int day = currentDay + 1; day <= daysInMonth; day++) {
        final projectedSatang = runningSumSatang + (dailyAverageSatang * (day - currentDay));
        projectedSpots.add(FlSpot(day.toDouble(), projectedSatang / 100.0));
      }
    }

    // 3. Determine status vs budget
    final bool hasBudget = totalBudgetSatang > 0;
    final bool isOverBudgetProjected = hasBudget && (projectedEndSatang > totalBudgetSatang);
    final int diffSatang = (projectedEndSatang - totalBudgetSatang).abs();

    // Max Y calculation to give comfortable headroom for lines and labels
    double maxY = 1000.0;
    if (hasBudget) {
      maxY = (totalBudgetSatang / 100.0);
    }
    if (projectedEndSatang / 100.0 > maxY) {
      maxY = projectedEndSatang / 100.0;
    }
    if (runningSumSatang / 100.0 > maxY) {
      maxY = runningSumSatang / 100.0;
    }
    // Add 15% headroom
    maxY = maxY <= 0 ? 1000.0 : (maxY * 1.18);

    // Color definitions
    final actualColor = isLumi
        ? (isDark ? const Color(0xFFFF7EAE) : const Color(0xFFFF4081))
        : VaultTheme.accent(context);

    final projectedColor = isOverBudgetProjected
        ? const Color(0xFFFF5252) // Warning red if predicted to bust budget
        : (isLumi
            ? (isDark ? const Color(0xFF81D4FA) : const Color(0xFF0288D1))
            : const Color(0xFFFFB74D)); // Orange / amber / cyan

    final budgetLineColor = isDark
        ? Colors.white.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.28);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLumi
            ? (isDark ? const Color(0xFF231825) : Colors.white)
            : VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(isLumi ? 22 : 16),
        border: Border.all(
          color: isLumi
              ? (isDark ? const Color(0xFF4A3448) : const Color(0xFFF3DCE5))
              : VaultTheme.border(context),
          width: 0.8,
        ),
        boxShadow: isLumi && !isDark
            ? [
                BoxShadow(
                  color: const Color(0x10FF5B9A),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title & Projected Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 18,
                color: actualColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isThai ? 'แนวโน้มและคาดการณ์รายจ่าย' : 'Expense Trend & Projection',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: VaultTheme.primaryText(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasBudget)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOverBudgetProjected
                        ? (isDark ? const Color(0xFF3E1C22) : const Color(0xFFFFEBEE))
                        : (isDark ? const Color(0xFF1B3326) : const Color(0xFFE8F5E9)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isOverBudgetProjected
                          ? const Color(0xFFFF5252).withValues(alpha: 0.5)
                          : const Color(0xFF4CAF50).withValues(alpha: 0.5),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOverBudgetProjected
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 13,
                        color: isOverBudgetProjected
                            ? const Color(0xFFFF5252)
                            : const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverBudgetProjected
                            ? (isThai ? 'เสี่ยงเกินงบ' : 'Risk Over')
                            : (isThai ? 'ตามเป้าหมาย' : 'On Track'),
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isOverBudgetProjected
                              ? const Color(0xFFFF5252)
                              : const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Key Metrics: Actual so far (burn rate) vs Projected End of Month
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: actualColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isThai ? 'ใช้จริงถึงวันที่ $currentDay' : 'Actual to Day $currentDay',
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontSize: 11,
                            color: VaultTheme.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Money(runningSumSatang).format(symbol: '฿'),
                        style: VaultTheme.tabular(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: VaultTheme.primaryText(context),
                        ),
                      ),
                    ),
                    Text(
                      '${isThai ? 'เฉลี่ยวันละ' : 'Avg/day'} ${Money(dailyAverageSatang).format(symbol: '฿')}',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 10,
                        color: VaultTheme.mutedText(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 3,
                          decoration: BoxDecoration(
                            color: projectedColor,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isThai ? 'คาดการณ์สิ้นเดือน' : 'Projected End',
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontSize: 11,
                            color: VaultTheme.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Money(projectedEndSatang).format(symbol: '฿'),
                        style: VaultTheme.tabular(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: projectedColor,
                        ),
                      ),
                    ),
                    Text(
                      hasBudget
                          ? (isOverBudgetProjected
                              ? '${isThai ? 'เกินงบ' : 'Over'} +${Money(diffSatang).format(symbol: '฿')}'
                              : '${isThai ? 'เหลืองบ' : 'Under'} ${Money(diffSatang).format(symbol: '฿')}')
                          : (isThai ? 'ไม่มีเพดานงบ' : 'No budget set'),
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isOverBudgetProjected
                            ? const Color(0xFFFF5252)
                            : (hasBudget ? const Color(0xFF4CAF50) : VaultTheme.mutedText(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // The Line Chart
          SizedBox(
            height: 145,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: daysInMonth.toDouble(),
                minY: 0,
                maxY: maxY,
                clipData: const FlClipData.none(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: VaultTheme.border(context).withValues(alpha: 0.4),
                    strokeWidth: 0.7,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (val, meta) {
                        if (val == 0) return const SizedBox.shrink();
                        final k = (val / 1000).round();
                        return Text(
                          '${k}k',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: VaultTheme.secondaryText(context),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (val, meta) {
                        final day = val.toInt();
                        if (day == 1 || day == 10 || day == 20 || day == daysInMonth) {
                          return Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: VaultTheme.secondaryText(context),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    if (hasBudget)
                      HorizontalLine(
                        y: totalBudgetSatang / 100.0,
                        color: budgetLineColor,
                        strokeWidth: 1.2,
                        dashArray: [4, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 6, bottom: 2),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: VaultTheme.secondaryText(context),
                          ),
                          labelResolver: (line) => isThai
                              ? 'งบ ${Money(totalBudgetSatang).format(symbol: '฿')}'
                              : 'Budget ${Money(totalBudgetSatang).format(symbol: '฿')}',
                        ),
                      ),
                  ],
                ),
                lineBarsData: [
                  // Actual expense line (Solid)
                  LineChartBarData(
                    spots: actualSpots,
                    isCurved: false,
                    color: actualColor,
                    barWidth: 2.8,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        // Only show dot at day 1 and currentDay to avoid visual clutter
                        return spot.x == 1 || spot.x == currentDay;
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3.5,
                          color: actualColor,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: actualColor.withValues(alpha: 0.12),
                    ),
                  ),

                  // Projected expense line (Dashed)
                  if (projectedSpots.isNotEmpty)
                    LineChartBarData(
                      spots: projectedSpots,
                      isCurved: false,
                      color: projectedColor,
                      barWidth: 2.2,
                      dashArray: [6, 4],
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, barData) => spot.x == daysInMonth,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3.5,
                            color: projectedColor,
                            strokeWidth: 1.5,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: projectedColor.withValues(alpha: 0.05),
                      ),
                    ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((barSpot) {
                        final isActual = barSpot.barIndex == 0;
                        final day = barSpot.x.toInt();
                        final amountSatang = (barSpot.y * 100).round();
                        return LineTooltipItem(
                          '${isThai ? "วันที่" : "Day"} $day: ${Money(amountSatang).format(symbol: "฿")}\n(${isActual ? (isThai ? "ใช้จริง" : "Actual") : (isThai ? "คาดการณ์" : "Projected")})',
                          TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
