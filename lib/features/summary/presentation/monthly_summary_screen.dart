import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/vault_theme.dart';

class MonthlySummaryScreen extends ConsumerStatefulWidget {
  final DateTime? initialMonth;

  const MonthlySummaryScreen({super.key, this.initialMonth});

  @override
  ConsumerState<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends ConsumerState<MonthlySummaryScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = widget.initialMonth ?? DateTime(now.year, now.month);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  String _formatMonthYear(DateTime date, bool isThai) {
    if (isThai) {
      const thaiMonths = [
        'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
        'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
        'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
      ];
      final month = thaiMonths[date.month - 1];
      final year = date.year + 543; // พ.ศ.
      return '$month $year';
    } else {
      return DateFormat('MMMM yyyy').format(date);
    }
  }

  String _formatShortMonth(int month, bool isThai) {
    if (isThai) {
      const thaiShortMonths = [
        'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.',
        'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.',
        'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
      ];
      return thaiShortMonths[month - 1];
    } else {
      const enShortMonths = [
        'Jan', 'Feb', 'Mar', 'Apr',
        'May', 'Jun', 'Jul', 'Aug',
        'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return enShortMonths[month - 1];
    }
  }

  Future<_MonthlyReportData> _loadData() async {
    final year = _selectedMonth.year;
    final month = _selectedMonth.month;

    final start = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final end = DateTime(year, month, daysInMonth, 23, 59, 59, 999);

    final txsDao = ref.read(transactionsDaoProvider);
    final currentTxs = await txsDao.searchTransactions(startDate: start, endDate: end);

    int incomeSatang = 0;
    int expenseSatang = 0;

    for (final t in currentTxs) {
      if (t.transactionType == 'income') {
        incomeSatang += t.amountThbSatang;
      } else if (t.transactionType == 'expense') {
        expenseSatang += (t.amountThbSatang + t.feeThbSatang);
      }
    }

    final savingsSatang = incomeSatang - expenseSatang;

    // Previous month comparison
    final prevStart = DateTime(year, month - 1, 1);
    final prevDays = DateTime(year, month, 0).day;
    final prevEnd = DateTime(year, month - 1, prevDays, 23, 59, 59, 999);

    final prevTxs = await txsDao.searchTransactions(startDate: prevStart, endDate: prevEnd);
    int prevIncome = 0;
    int prevExpense = 0;
    for (final t in prevTxs) {
      if (t.transactionType == 'income') {
        prevIncome += t.amountThbSatang;
      } else if (t.transactionType == 'expense') {
        prevExpense += (t.amountThbSatang + t.feeThbSatang);
      }
    }
    final prevSavings = prevIncome - prevExpense;

    int? savingsMoMPercent;
    if (prevSavings > 0) {
      savingsMoMPercent = (((savingsSatang - prevSavings) / prevSavings) * 100).round();
    }

    // Cumulative expense checkpoints for LineChart: days 1, 8, 15, 22, and end of month
    final checkpoints = [1, 8, 15, 22, daysInMonth];
    final Map<int, double> cumulativeExpensesByDay = {};

    double runningSumThb = 0.0;
    for (final cp in checkpoints) {
      final cpTxs = currentTxs.where((t) =>
          t.transactionType == 'expense' &&
          t.transactionDate.day <= cp);
      int sumSatang = 0;
      for (final t in cpTxs) {
        sumSatang += (t.amountThbSatang + t.feeThbSatang);
      }
      runningSumThb = sumSatang / 100.0;
      cumulativeExpensesByDay[cp] = runningSumThb;
    }

    return _MonthlyReportData(
      incomeSatang: incomeSatang,
      expenseSatang: expenseSatang,
      savingsSatang: savingsSatang,
      savingsMoMPercent: savingsMoMPercent,
      cumulativeExpensesByDay: cumulativeExpensesByDay,
      daysInMonth: daysInMonth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLumi = VaultTheme.isLumi(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        elevation: 0,
        title: Text(
          isLumi ? 'สรุป 🌸' : 'SUMMARY',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: isLumi ? 0.5 : 2.5,
            color: VaultTheme.primaryText(context),
          ),
        ),
      ),
      body: FutureBuilder<_MonthlyReportData>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: VaultTheme.accent(context)),
            );
          }

          final data = snapshot.data ??
              _MonthlyReportData(
                incomeSatang: 0,
                expenseSatang: 0,
                savingsSatang: 0,
                savingsMoMPercent: null,
                cumulativeExpensesByDay: {1: 0, 8: 0, 15: 0, 22: 0, 30: 0},
                daysInMonth: 30,
              );

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // 1. Header with Month Navigator & Mascot
              _buildHeader(context, isLumi, isThai),
              const SizedBox(height: 18),

              // 2. Dual Cards: Income & Expense
              _buildDualIncomeExpenseCards(context, data, isLumi),
              const SizedBox(height: 14),

              // 3. Net Savings Card
              _buildSavingsCard(context, data, isLumi),
              const SizedBox(height: 18),

              // 4. Expense Trend Curve Chart
              _buildExpenseTrendCard(context, data, isLumi, isThai),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLumi, bool isThai) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(isLumi ? 22 : 16),
        border: Border.all(color: VaultTheme.border(context), width: 0.75),
        boxShadow: isLumi
            ? [
                BoxShadow(
                  color: const Color(0xFFFF5C9D).withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLumi ? 'สรุปภาพรวม ☀️' : 'MONTHLY OVERVIEW',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: isLumi ? 20 : 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: isLumi ? 0.2 : 1.5,
                    color: VaultTheme.primaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    InkWell(
                      onTap: _previousMonth,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: VaultTheme.border(context).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          size: 20,
                          color: VaultTheme.primaryText(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatMonthYear(_selectedMonth, isThai),
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: VaultTheme.secondaryText(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _nextMonth,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: VaultTheme.border(context).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: VaultTheme.primaryText(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isLumi)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/lumi_summary_header.png',
                width: 90,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDualIncomeExpenseCards(BuildContext context, _MonthlyReportData data, bool isLumi) {
    return Row(
      children: [
        // Left: Income Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLumi ? const Color(0xFFEDF9EC) : VaultTheme.surface(context),
              borderRadius: BorderRadius.circular(isLumi ? 20 : 14),
              border: Border.all(
                color: isLumi ? const Color(0xFFC3EBC0) : VaultTheme.border(context),
                width: 0.75,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'รายรับ',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isLumi ? const Color(0xFF286E24) : VaultTheme.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFF38A130),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        Money(data.incomeSatang).format(symbol: '฿'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VaultTheme.tabular(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isLumi ? const Color(0xFF1E561A) : VaultTheme.positive(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Right: Expense Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLumi ? const Color(0xFFFFF0F5) : VaultTheme.surface(context),
              borderRadius: BorderRadius.circular(isLumi ? 20 : 14),
              border: Border.all(
                color: isLumi ? const Color(0xFFFFD1DC) : VaultTheme.border(context),
                width: 0.75,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'รายจ่าย',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isLumi ? const Color(0xFF8A3052) : VaultTheme.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF5C9D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        Money(data.expenseSatang).format(symbol: '฿'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: VaultTheme.tabular(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isLumi ? const Color(0xFF8A3052) : VaultTheme.negative(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsCard(BuildContext context, _MonthlyReportData data, bool isLumi) {
    final momText = data.savingsMoMPercent != null
        ? (data.savingsMoMPercent! >= 0
            ? '↑ ${data.savingsMoMPercent}% จากเดือนที่แล้ว'
            : '↓ ${data.savingsMoMPercent!.abs()}% จากเดือนที่แล้ว')
        : 'ยอดเงินออมสุทธิประจำเดือน';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isLumi ? const Color(0xFFEBF5FC) : VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(isLumi ? 22 : 16),
        border: Border.all(
          color: isLumi ? const Color(0xFFBFE9FF) : VaultTheme.border(context),
          width: 0.75,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ออมได้',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isLumi ? const Color(0xFF1F4E6E) : VaultTheme.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Money(data.savingsSatang).format(symbol: '฿'),
                  style: VaultTheme.tabular(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isLumi ? const Color(0xFF13364C) : VaultTheme.primaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  momText,
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isLumi ? const Color(0xFF2A84BC) : VaultTheme.accent(context),
                  ),
                ),
              ],
            ),
          ),
          if (isLumi)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/lumi_savings_cat.png',
                width: 95,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseTrendCard(
    BuildContext context,
    _MonthlyReportData data,
    bool isLumi,
    bool isThai,
  ) {
    final spots = <FlSpot>[];
    double maxVal = 1000.0;

    data.cumulativeExpensesByDay.forEach((day, amount) {
      spots.add(FlSpot(day.toDouble(), amount));
      if (amount > maxVal) maxVal = amount;
    });

    // Determine Y-axis max rounded nicely
    final roundedMax = ((maxVal * 1.25) / 1000).ceil() * 1000.0;
    final shortMonth = _formatShortMonth(_selectedMonth.month, isThai);
    final themeColor = isLumi ? const Color(0xFFFF5C9D) : VaultTheme.accent(context);

    final lastEntry = data.cumulativeExpensesByDay.entries.lastOrNull;
    final lastAmount = lastEntry?.value ?? 0.0;
    final lastBadgeText = lastAmount >= 1000
        ? '${(lastAmount / 1000).toStringAsFixed(0)}K'
        : '${lastAmount.toStringAsFixed(0)}฿';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(isLumi ? 22 : 16),
        border: Border.all(color: VaultTheme.border(context), width: 0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'แนวโน้มรายจ่าย',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: VaultTheme.primaryText(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lastBadgeText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: data.daysInMonth.toDouble(),
                minY: 0,
                maxY: roundedMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: VaultTheme.border(context).withValues(alpha: 0.5),
                    strokeWidth: 0.8,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) {
                          return const Text('0', style: TextStyle(fontSize: 10, color: Colors.grey));
                        }
                        if (value >= 1000) {
                          final k = (value / 1000).toInt();
                          return Text('${k}K', style: const TextStyle(fontSize: 10, color: Colors.grey));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final day = value.toInt();
                        if (day == 1 || day == 8 || day == 15 || day == 22 || day == data.daysInMonth) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '$day $shortMonth',
                              style: const TextStyle(fontSize: 9.5, color: Colors.grey),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: themeColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: themeColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          themeColor.withValues(alpha: 0.28),
                          themeColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyReportData {
  final int incomeSatang;
  final int expenseSatang;
  final int savingsSatang;
  final int? savingsMoMPercent;
  final Map<int, double> cumulativeExpensesByDay;
  final int daysInMonth;

  const _MonthlyReportData({
    required this.incomeSatang,
    required this.expenseSatang,
    required this.savingsSatang,
    required this.savingsMoMPercent,
    required this.cumulativeExpensesByDay,
    required this.daysInMonth,
  });
}
