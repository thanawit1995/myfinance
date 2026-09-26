import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../../../core/widgets/category_icon_helper.dart';

enum ReportGranularity {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
  all,
  custom,
}

class _CategoryBreakdownItem {
  final String categoryId;
  final String name;
  final String icon;
  final int totalSatang;
  final double percentage;

  const _CategoryBreakdownItem({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.totalSatang,
    required this.percentage,
  });
}

class _PeriodReportData {
  final DateTime startDate;
  final DateTime endDate;
  final int incomeSatang;
  final int accruedIncomeSatang;
  final int expenseSatang;
  final int savingsSatang;
  final double savingsRatePercent;
  final int? savingsMoMPercent;
  final Map<int, double> cumulativeExpensesByDay;
  final int daysInMonth;
  final List<_CategoryBreakdownItem> expenseCategories;
  final List<_CategoryBreakdownItem> incomeCategories;

  const _PeriodReportData({
    required this.startDate,
    required this.endDate,
    required this.incomeSatang,
    required this.accruedIncomeSatang,
    required this.expenseSatang,
    required this.savingsSatang,
    required this.savingsRatePercent,
    required this.savingsMoMPercent,
    required this.cumulativeExpensesByDay,
    required this.daysInMonth,
    required this.expenseCategories,
    required this.incomeCategories,
  });
}

class MonthlySummaryScreen extends ConsumerStatefulWidget {
  final DateTime? initialMonth;

  const MonthlySummaryScreen({super.key, this.initialMonth});

  @override
  ConsumerState<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends ConsumerState<MonthlySummaryScreen> {
  ReportGranularity _granularity = ReportGranularity.monthly;
  late DateTime _cursorDate;
  DateTimeRange? _customRange;
  bool _showIncomeCategories = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _cursorDate = widget.initialMonth ?? DateTime(now.year, now.month, now.day);
  }

  void _previousPeriod() {
    setState(() {
      switch (_granularity) {
        case ReportGranularity.daily:
          _cursorDate = _cursorDate.subtract(const Duration(days: 1));
          break;
        case ReportGranularity.weekly:
          _cursorDate = _cursorDate.subtract(const Duration(days: 7));
          break;
        case ReportGranularity.monthly:
          _cursorDate = DateTime(_cursorDate.year, _cursorDate.month - 1, 1);
          break;
        case ReportGranularity.quarterly:
          _cursorDate = DateTime(_cursorDate.year, _cursorDate.month - 3, 1);
          break;
        case ReportGranularity.yearly:
          _cursorDate = DateTime(_cursorDate.year - 1, 1, 1);
          break;
        case ReportGranularity.all:
        case ReportGranularity.custom:
          break;
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      switch (_granularity) {
        case ReportGranularity.daily:
          _cursorDate = _cursorDate.add(const Duration(days: 1));
          break;
        case ReportGranularity.weekly:
          _cursorDate = _cursorDate.add(const Duration(days: 7));
          break;
        case ReportGranularity.monthly:
          _cursorDate = DateTime(_cursorDate.year, _cursorDate.month + 1, 1);
          break;
        case ReportGranularity.quarterly:
          _cursorDate = DateTime(_cursorDate.year, _cursorDate.month + 3, 1);
          break;
        case ReportGranularity.yearly:
          _cursorDate = DateTime(_cursorDate.year + 1, 1, 1);
          break;
        case ReportGranularity.all:
        case ReportGranularity.custom:
          break;
      }
    });
  }

  ({DateTime start, DateTime end}) _computeDateRange() {
    switch (_granularity) {
      case ReportGranularity.daily:
        final s = DateTime(_cursorDate.year, _cursorDate.month, _cursorDate.day, 0, 0, 0);
        final e = DateTime(_cursorDate.year, _cursorDate.month, _cursorDate.day, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.weekly:
        final weekday = _cursorDate.weekday; // 1 = Monday, 7 = Sunday
        final monday = _cursorDate.subtract(Duration(days: weekday - 1));
        final s = DateTime(monday.year, monday.month, monday.day, 0, 0, 0);
        final sunday = monday.add(const Duration(days: 6));
        final e = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.monthly:
        final s = DateTime(_cursorDate.year, _cursorDate.month, 1, 0, 0, 0);
        final days = DateTime(_cursorDate.year, _cursorDate.month + 1, 0).day;
        final e = DateTime(_cursorDate.year, _cursorDate.month, days, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.quarterly:
        final q = ((_cursorDate.month - 1) ~/ 3) + 1; // 1..4
        final startMonth = (q - 1) * 3 + 1;
        final endMonth = startMonth + 2;
        final s = DateTime(_cursorDate.year, startMonth, 1, 0, 0, 0);
        final days = DateTime(_cursorDate.year, endMonth + 1, 0).day;
        final e = DateTime(_cursorDate.year, endMonth, days, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.yearly:
        final s = DateTime(_cursorDate.year, 1, 1, 0, 0, 0);
        final e = DateTime(_cursorDate.year, 12, 31, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.all:
        final s = DateTime(2020, 1, 1, 0, 0, 0);
        final e = DateTime(2050, 12, 31, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.custom:
        final s = _customRange?.start ?? DateTime(_cursorDate.year, _cursorDate.month, 1);
        final rawEnd = _customRange?.end ?? _cursorDate;
        final e = DateTime(rawEnd.year, rawEnd.month, rawEnd.day, 23, 59, 59, 999);
        return (start: s, end: e);
    }
  }

  String _formatPeriodTitle(bool isThai) {
    const thaiMonths = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
      'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
      'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    const thaiShortMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.',
      'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.',
      'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];

    switch (_granularity) {
      case ReportGranularity.daily:
        final d = _cursorDate;
        final m = isThai ? thaiShortMonths[d.month - 1] : DateFormat('MMM').format(d);
        return '${d.day} $m ${d.year}';

      case ReportGranularity.weekly:
        final range = _computeDateRange();
        final s = range.start;
        final e = range.end;
        final sm = isThai ? thaiShortMonths[s.month - 1] : DateFormat('MMM').format(s);
        final em = isThai ? thaiShortMonths[e.month - 1] : DateFormat('MMM').format(e);
        return '${s.day} $sm - ${e.day} $em ${e.year}';

      case ReportGranularity.monthly:
        final m = isThai ? thaiMonths[_cursorDate.month - 1] : DateFormat('MMMM').format(_cursorDate);
        return '$m ${_cursorDate.year}';

      case ReportGranularity.quarterly:
        final q = ((_cursorDate.month - 1) ~/ 3) + 1;
        return 'Q$q ${_cursorDate.year}';

      case ReportGranularity.yearly:
        return isThai ? 'ปี ${_cursorDate.year}' : 'Year ${_cursorDate.year}';

      case ReportGranularity.all:
        return isThai ? 'ข้อมูลทั้งหมด (All Time)' : 'All Time History';

      case ReportGranularity.custom:
        final range = _computeDateRange();
        final s = range.start;
        final e = range.end;
        final sm = isThai ? thaiShortMonths[s.month - 1] : DateFormat('MMM').format(s);
        final em = isThai ? thaiShortMonths[e.month - 1] : DateFormat('MMM').format(e);
        return '${s.day} $sm ${s.year} - ${e.day} $em ${e.year}';
    }
  }

  Future<_PeriodReportData> _loadData() async {
    final range = _computeDateRange();
    final start = range.start;
    final end = range.end;

    final txsDao = ref.read(transactionsDaoProvider);
    final currentTxs = await txsDao.searchTransactions(startDate: start, endDate: end);
    final allCats = await ref.read(categoriesDaoProvider).getAllCategories();
    final catMap = {for (final c in allCats) c.id: c};

    int incomeSatang = 0;
    int accruedIncomeSatang = 0;
    int expenseSatang = 0;

    final Map<String, int> expenseByCat = {};
    final Map<String, int> incomeByCat = {};

    for (final t in currentTxs) {
      if (t.transactionType == 'income') {
        if (t.isCleared) {
          incomeSatang += t.amountThbSatang;
          final catId = t.categoryId ?? 'uncategorized';
          incomeByCat[catId] = (incomeByCat[catId] ?? 0) + t.amountThbSatang;
        } else {
          accruedIncomeSatang += t.amountThbSatang;
        }
      } else if (t.transactionType == 'expense') {
        final cost = t.amountThbSatang + t.feeThbSatang;
        expenseSatang += cost;
        final catId = t.categoryId ?? 'uncategorized';
        expenseByCat[catId] = (expenseByCat[catId] ?? 0) + cost;
      }
    }

    final savingsSatang = incomeSatang - expenseSatang;
    final savingsRatePercent = incomeSatang > 0
        ? ((savingsSatang / incomeSatang) * 100.0).clamp(-100.0, 100.0)
        : 0.0;

    // Previous period comparison for monthly
    int? savingsMoMPercent;
    if (_granularity == ReportGranularity.monthly) {
      final year = _cursorDate.year;
      final month = _cursorDate.month;
      final prevStart = DateTime(year, month - 1, 1);
      final prevDays = DateTime(year, month, 0).day;
      final prevEnd = DateTime(year, month - 1, prevDays, 23, 59, 59, 999);

      final prevTxs = await txsDao.searchTransactions(startDate: prevStart, endDate: prevEnd);
      int prevIncome = 0;
      int prevExpense = 0;
      for (final t in prevTxs) {
        if (t.transactionType == 'income' && t.isCleared) {
          prevIncome += t.amountThbSatang;
        } else if (t.transactionType == 'expense') {
          prevExpense += (t.amountThbSatang + t.feeThbSatang);
        }
      }
      final prevSavings = prevIncome - prevExpense;
      if (prevSavings > 0) {
        savingsMoMPercent = (((savingsSatang - prevSavings) / prevSavings) * 100).round();
      }
    }

    // Cumulative expense checkpoints for LineChart (when in monthly view)
    final daysInMonth = DateTime(_cursorDate.year, _cursorDate.month + 1, 0).day;
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

    // Process Category Breakdown
    final isThai = mounted ? Localizations.localeOf(context).languageCode == 'th' : true;
    final expenseCategories = <_CategoryBreakdownItem>[];
    expenseByCat.forEach((catId, satang) {
      final cat = catMap[catId];
      final name = cat != null
          ? (isThai ? cat.nameTh : cat.nameEn)
          : (isThai ? 'ไม่ระบุหมวดหมู่' : 'Uncategorized');
      final icon = cat?.icon ?? 'receipt_long';
      final pct = expenseSatang > 0 ? (satang / expenseSatang) * 100.0 : 0.0;
      expenseCategories.add(_CategoryBreakdownItem(
        categoryId: catId,
        name: name,
        icon: icon,
        totalSatang: satang,
        percentage: pct,
      ));
    });
    expenseCategories.sort((a, b) => b.totalSatang.compareTo(a.totalSatang));

    final incomeCategories = <_CategoryBreakdownItem>[];
    incomeByCat.forEach((catId, satang) {
      final cat = catMap[catId];
      final name = cat != null
          ? (isThai ? cat.nameTh : cat.nameEn)
          : (isThai ? 'ไม่ระบุหมวดหมู่' : 'Uncategorized');
      final icon = cat?.icon ?? 'account_balance_wallet';
      final pct = incomeSatang > 0 ? (satang / incomeSatang) * 100.0 : 0.0;
      incomeCategories.add(_CategoryBreakdownItem(
        categoryId: catId,
        name: name,
        icon: icon,
        totalSatang: satang,
        percentage: pct,
      ));
    });
    incomeCategories.sort((a, b) => b.totalSatang.compareTo(a.totalSatang));

    return _PeriodReportData(
      startDate: start,
      endDate: end,
      incomeSatang: incomeSatang,
      accruedIncomeSatang: accruedIncomeSatang,
      expenseSatang: expenseSatang,
      savingsSatang: savingsSatang,
      savingsRatePercent: savingsRatePercent,
      savingsMoMPercent: savingsMoMPercent,
      cumulativeExpensesByDay: cumulativeExpensesByDay,
      daysInMonth: daysInMonth,
      expenseCategories: expenseCategories,
      incomeCategories: incomeCategories,
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
          isLumi ? 'สรุปภาพรวม 🌸' : 'FINANCIAL SUMMARY',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: isLumi ? 0.5 : 2.0,
            color: VaultTheme.primaryText(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isThai ? 'รีเฟรช' : 'Refresh',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            // Swipe Left -> Next Period
            if (details.primaryVelocity! < -150) {
              _nextPeriod();
            }
            // Swipe Right -> Previous Period
            else if (details.primaryVelocity! > 150) {
              _previousPeriod();
            }
          }
        },
        child: FutureBuilder<_PeriodReportData>(
          future: _loadData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: VaultTheme.accent(context)),
              );
            }

            final data = snapshot.data ??
                _PeriodReportData(
                  startDate: DateTime.now(),
                  endDate: DateTime.now(),
                  incomeSatang: 0,
                  accruedIncomeSatang: 0,
                  expenseSatang: 0,
                  savingsSatang: 0,
                  savingsRatePercent: 0.0,
                  savingsMoMPercent: null,
                  cumulativeExpensesByDay: {1: 0, 8: 0, 15: 0, 22: 0, 30: 0},
                  daysInMonth: 30,
                  expenseCategories: [],
                  incomeCategories: [],
                );

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // 1. Granularity Selector (Day, Week, Month, Quarter, Year, All, Custom)
                _buildGranularitySelector(context, isThai),
                const SizedBox(height: 12),

                // 2. Navigation Header with Swipe Hint & Date Title
                _buildNavigationHeader(context, isLumi, isThai),
                const SizedBox(height: 14),

                // 3. Dual Cards: Income & Expense
                _buildDualIncomeExpenseCards(context, data, isLumi),
                const SizedBox(height: 12),

                // 4. Net Savings Card
                _buildSavingsCard(context, data, isLumi),
                const SizedBox(height: 16),

                // 5. Income vs Expense Bar Chart
                _buildIncomeExpenseBarChart(context, data, isThai),
                const SizedBox(height: 16),

                // 6. Cumulative Expense Trend Chart (if Monthly)
                if (_granularity == ReportGranularity.monthly) ...[
                  _buildExpenseTrendCard(context, data, isLumi, isThai),
                  const SizedBox(height: 16),
                ],

                // 7. Category Breakdown Section
                _buildCategoryBreakdownCard(context, data, isThai),
                const SizedBox(height: 36),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGranularitySelector(BuildContext context, bool isThai) {
    final surface = VaultTheme.surface(context);
    final border = VaultTheme.border(context);
    final accent = VaultTheme.accent(context);
    final primaryText = VaultTheme.primaryText(context);

    final items = [
      (ReportGranularity.daily, isThai ? 'รายวัน' : 'Day'),
      (ReportGranularity.weekly, isThai ? 'สัปดาห์' : 'Week'),
      (ReportGranularity.monthly, isThai ? 'เดือน' : 'Month'),
      (ReportGranularity.quarterly, isThai ? 'ไตรมาส' : 'Quarter'),
      (ReportGranularity.yearly, isThai ? 'ปี' : 'Year'),
      (ReportGranularity.all, isThai ? 'ทั้งหมด' : 'All'),
      (ReportGranularity.custom, isThai ? 'กำหนดเอง' : 'Custom'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final isSelected = _granularity == item.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              backgroundColor: surface,
              selectedColor: accent,
              side: BorderSide(color: isSelected ? accent : border, width: 0.75),
              label: Text(
                item.$2,
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : primaryText,
                ),
              ),
              selected: isSelected,
              onSelected: (val) async {
                if (item.$1 == ReportGranularity.custom) {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2050),
                    initialDateRange: _customRange ??
                        DateTimeRange(
                          start: DateTime(_cursorDate.year, _cursorDate.month, 1),
                          end: DateTime.now(),
                        ),
                  );
                  if (picked != null) {
                    setState(() {
                      _customRange = picked;
                      _granularity = ReportGranularity.custom;
                    });
                  }
                } else if (val) {
                  setState(() => _granularity = item.$1);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationHeader(BuildContext context, bool isLumi, bool isThai) {
    final surface = VaultTheme.surface(context);
    final border = VaultTheme.border(context);
    final primaryText = VaultTheme.primaryText(context);
    final secondaryText = VaultTheme.secondaryText(context);
    final accent = VaultTheme.accent(context);

    final isNavDisabled = _granularity == ReportGranularity.all;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.swipe_outlined, size: 16, color: accent),
                  const SizedBox(width: 6),
                  Text(
                    isThai ? 'ปัดจอซ้าย-ขวา เพื่อเปลี่ยนช่วงเวลา' : 'Swipe left/right to change period',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 11.5,
                      color: secondaryText,
                    ),
                  ),
                ],
              ),
              if (_granularity == ReportGranularity.custom)
                InkWell(
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2050),
                      initialDateRange: _customRange,
                    );
                    if (picked != null) {
                      setState(() => _customRange = picked);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      isThai ? 'เปลี่ยนวันที่' : 'Change',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 26),
                color: isNavDisabled ? secondaryText.withValues(alpha: 0.3) : primaryText,
                onPressed: isNavDisabled ? null : _previousPeriod,
              ),
              Expanded(
                child: Text(
                  _formatPeriodTitle(isThai),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 26),
                color: isNavDisabled ? secondaryText.withValues(alpha: 0.3) : primaryText,
                onPressed: isNavDisabled ? null : _nextPeriod,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDualIncomeExpenseCards(BuildContext context, _PeriodReportData data, bool isLumi) {
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
                if (data.accruedIncomeSatang > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+ค้างรับ ฿${Money(data.accruedIncomeSatang).format(symbol: '')}',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 11,
                      color: isLumi ? const Color(0xFF286E24) : VaultTheme.accent(context),
                    ),
                  ),
                ],
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
              color: isLumi ? const Color(0xFFFDF2F4) : VaultTheme.surface(context),
              borderRadius: BorderRadius.circular(isLumi ? 20 : 14),
              border: Border.all(
                color: isLumi ? const Color(0xFFFFD5DE) : VaultTheme.border(context),
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
                    color: isLumi ? const Color(0xFF912B43) : VaultTheme.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE84368),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward_rounded, size: 16, color: Colors.white),
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
                          color: isLumi ? const Color(0xFF751C33) : VaultTheme.negative(context),
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

  Widget _buildSavingsCard(BuildContext context, _PeriodReportData data, bool isLumi) {
    final momText = data.savingsMoMPercent != null
        ? (data.savingsMoMPercent! >= 0
            ? '↑ ${data.savingsMoMPercent}% จากเดือนที่แล้ว'
            : '↓ ${data.savingsMoMPercent!.abs()}% จากเดือนที่แล้ว')
        : 'อัตราการออม ${data.savingsRatePercent.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLumi ? const Color(0xFFEBF5FC) : VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(isLumi ? 20 : 14),
        border: Border.all(
          color: isLumi ? const Color(0xFFBFE9FF) : VaultTheme.border(context),
          width: 0.75,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เงินออมสุทธิ',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isLumi ? const Color(0xFF1F4E6E) : VaultTheme.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Money(data.savingsSatang).format(symbol: '฿'),
                  style: VaultTheme.tabular(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: data.savingsSatang >= 0
                        ? (isLumi ? const Color(0xFF13364C) : VaultTheme.positive(context))
                        : VaultTheme.negative(context),
                  ),
                ),
                const SizedBox(height: 4),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: data.savingsSatang >= 0
                  ? VaultTheme.positive(context).withValues(alpha: 0.15)
                  : VaultTheme.negative(context).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  '${data.savingsRatePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: data.savingsSatang >= 0 ? VaultTheme.positive(context) : VaultTheme.negative(context),
                  ),
                ),
                Text(
                  'Savings Rate',
                  style: TextStyle(fontSize: 10, color: VaultTheme.secondaryText(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseBarChart(BuildContext context, _PeriodReportData data, bool isThai) {
    final surface = VaultTheme.surface(context);
    final border = VaultTheme.border(context);
    final primaryText = VaultTheme.primaryText(context);
    final secondaryText = VaultTheme.secondaryText(context);

    final incomeThb = data.incomeSatang / 100.0;
    final expenseThb = data.expenseSatang / 100.0;
    final maxVal = (incomeThb > expenseThb ? incomeThb : expenseThb);
    final maxY = maxVal > 0 ? (maxVal * 1.25) : 1000.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isThai ? 'เปรียบเทียบ รายรับ vs รายจ่าย' : 'Income vs Expense',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF38A130), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(isThai ? 'รับ' : 'Income', style: TextStyle(fontSize: 11, color: secondaryText)),
                  const SizedBox(width: 10),
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFE84368), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(isThai ? 'จ่าย' : 'Expense', style: TextStyle(fontSize: 11, color: secondaryText)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => surface,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final isInc = rodIndex == 0;
                      final label = isInc ? (isThai ? 'รายรับ' : 'Income') : (isThai ? 'รายจ่าย' : 'Expense');
                      return BarTooltipItem(
                        '$label\n฿${NumberFormat("#,##0").format(rod.toY)}',
                        TextStyle(
                          color: isInc ? const Color(0xFF38A130) : const Color(0xFFE84368),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      getTitlesWidget: (val, meta) {
                        if (val == 0) return const SizedBox.shrink();
                        String formatted;
                        if (val >= 1000000) {
                          formatted = '${(val / 1000000).toStringAsFixed(1)}M';
                        } else if (val >= 1000) {
                          formatted = '${(val / 1000).toStringAsFixed(0)}k';
                        } else {
                          formatted = val.toStringAsFixed(0);
                        }
                        return Text(formatted, style: TextStyle(fontSize: 10, color: secondaryText));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            isThai ? 'ยอดรวมช่วงเวลานี้' : 'Total Period',
                            style: TextStyle(fontSize: 11, color: secondaryText, fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: border.withValues(alpha: 0.5),
                    strokeWidth: 0.75,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barsSpace: 12,
                    barRods: [
                      BarChartRodData(
                        toY: incomeThb,
                        color: const Color(0xFF38A130),
                        width: 32,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                      BarChartRodData(
                        toY: expenseThb,
                        color: const Color(0xFFE84368),
                        width: 32,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTrendCard(
    BuildContext context,
    _PeriodReportData data,
    bool isLumi,
    bool isThai,
  ) {
    final spots = <FlSpot>[];
    double maxVal = 1000.0;

    data.cumulativeExpensesByDay.forEach((day, amount) {
      spots.add(FlSpot(day.toDouble(), amount));
      if (amount > maxVal) maxVal = amount;
    });

    final roundedMax = ((maxVal * 1.25) / 1000).ceil() * 1000.0;
    final themeColor = isLumi ? const Color(0xFFFF5C9D) : VaultTheme.accent(context);

    return Container(
      padding: const EdgeInsets.all(16),
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
                isThai ? 'แนวโน้มการใช้จ่ายสะสมในเดือน' : 'Cumulative Spending Trend',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: VaultTheme.primaryText(context),
                ),
              ),
              Text(
                '฿${NumberFormat("#,##0").format(data.expenseSatang / 100.0)}',
                style: VaultTheme.tabular(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: themeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: data.daysInMonth.toDouble(),
                minY: 0,
                maxY: roundedMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: VaultTheme.border(context).withValues(alpha: 0.5),
                    strokeWidth: 0.75,
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
                        return Text('${k}k', style: TextStyle(fontSize: 10, color: VaultTheme.secondaryText(context)));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 7,
                      getTitlesWidget: (val, meta) {
                        final day = val.toInt();
                        if (day == 1 || day == 8 || day == 15 || day == 22 || day == data.daysInMonth) {
                          return Text('$day', style: TextStyle(fontSize: 10, color: VaultTheme.secondaryText(context)));
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
                    color: themeColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: themeColor.withValues(alpha: 0.12),
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

  Widget _buildCategoryBreakdownCard(BuildContext context, _PeriodReportData data, bool isThai) {
    final surface = VaultTheme.surface(context);
    final border = VaultTheme.border(context);
    final primaryText = VaultTheme.primaryText(context);
    final secondaryText = VaultTheme.secondaryText(context);

    final list = _showIncomeCategories ? data.incomeCategories : data.expenseCategories;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.75),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showIncomeCategories
                    ? (isThai ? 'รายรับแยกตามหมวดหมู่' : 'Income by Category')
                    : (isThai ? 'รายจ่ายแยกตามหมวดหมู่' : 'Expense by Category'),
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              SegmentedButton<bool>(
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(isThai ? 'รายจ่าย' : 'Expense', style: const TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(isThai ? 'รายรับ' : 'Income', style: const TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {_showIncomeCategories},
                onSelectionChanged: (set) => setState(() => _showIncomeCategories = set.first),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  isThai ? 'ไม่มีรายการในหมวดหมู่นี้' : 'No transactions found for this period',
                  style: TextStyle(fontSize: 13, color: secondaryText),
                ),
              ),
            )
          else
            ...list.map((item) {
              final color = _showIncomeCategories
                  ? const Color(0xFF38A130)
                  : const Color(0xFFE84368);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(
                            CategoryIconHelper.getIcon(item.icon),
                            size: 15,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontFamily: VaultTheme.fontFamily,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${item.percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: secondaryText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          Money(item.totalSatang).format(symbol: '฿'),
                          style: VaultTheme.tabular(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (item.percentage / 100.0).clamp(0.0, 1.0),
                        backgroundColor: border.withValues(alpha: 0.4),
                        color: color,
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
