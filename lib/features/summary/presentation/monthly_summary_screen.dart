import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../../../core/widgets/category_icon_helper.dart';
import '../../transactions/presentation/transaction_list_screen.dart';

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
  final int incomeSatang; // Living / Operating Income
  final int livingIncomeSatang;
  final int accruedIncomeSatang;
  final int expenseSatang;
  final int investmentSatang;
  final int assetSaleProceedsSatang;
  final int assetYieldSatang;
  final int dividendSatang;
  final int interestSatang;
  final int realizedGainLossSatang;
  final int netInvestmentFlowSatang;
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
    required this.livingIncomeSatang,
    required this.accruedIncomeSatang,
    required this.expenseSatang,
    this.investmentSatang = 0,
    this.assetSaleProceedsSatang = 0,
    this.assetYieldSatang = 0,
    this.dividendSatang = 0,
    this.interestSatang = 0,
    this.realizedGainLossSatang = 0,
    this.netInvestmentFlowSatang = 0,
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
  static const int _basePageIndex = 1000;
  late final PageController _pageController;
  late final DateTime _initialAnchorDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _cursorDate = widget.initialMonth ?? DateTime(now.year, now.month, now.day);
    _initialAnchorDate = _cursorDate;
    _pageController = PageController(initialPage: _basePageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _calculateDateForPageIndex(int index) {
    final offset = index - _basePageIndex;
    switch (_granularity) {
      case ReportGranularity.daily:
        return _initialAnchorDate.add(Duration(days: offset));
      case ReportGranularity.weekly:
        return _initialAnchorDate.add(Duration(days: offset * 7));
      case ReportGranularity.monthly:
        return DateTime(_initialAnchorDate.year, _initialAnchorDate.month + offset, 1);
      case ReportGranularity.quarterly:
        return DateTime(_initialAnchorDate.year, _initialAnchorDate.month + (offset * 3), 1);
      case ReportGranularity.yearly:
        return DateTime(_initialAnchorDate.year + offset, 1, 1);
      case ReportGranularity.all:
      case ReportGranularity.custom:
        return _initialAnchorDate;
    }
  }

  void _previousPeriod() {
    if (_granularity == ReportGranularity.all || _granularity == ReportGranularity.custom) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextPeriod() {
    if (_granularity == ReportGranularity.all || _granularity == ReportGranularity.custom) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  ({DateTime start, DateTime end}) _computeDateRange({DateTime? targetDate}) {
    final d = targetDate ?? _cursorDate;
    switch (_granularity) {
      case ReportGranularity.daily:
        final s = DateTime(d.year, d.month, d.day, 0, 0, 0);
        final e = DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.weekly:
        final weekday = d.weekday; // 1 = Monday, 7 = Sunday
        final monday = d.subtract(Duration(days: weekday - 1));
        final s = DateTime(monday.year, monday.month, monday.day, 0, 0, 0);
        final sunday = monday.add(const Duration(days: 6));
        final e = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.monthly:
        final s = DateTime(d.year, d.month, 1, 0, 0, 0);
        final days = DateTime(d.year, d.month + 1, 0).day;
        final e = DateTime(d.year, d.month, days, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.quarterly:
        final q = ((d.month - 1) ~/ 3) + 1; // 1..4
        final startMonth = (q - 1) * 3 + 1;
        final endMonth = startMonth + 2;
        final s = DateTime(d.year, startMonth, 1, 0, 0, 0);
        final days = DateTime(d.year, endMonth + 1, 0).day;
        final e = DateTime(d.year, endMonth, days, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.yearly:
        final s = DateTime(d.year, 1, 1, 0, 0, 0);
        final e = DateTime(d.year, 12, 31, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.all:
        final s = DateTime(2020, 1, 1, 0, 0, 0);
        final e = DateTime(2050, 12, 31, 23, 59, 59, 999);
        return (start: s, end: e);

      case ReportGranularity.custom:
        final s = _customRange?.start ?? DateTime(d.year, d.month, 1);
        final rawEnd = _customRange?.end ?? d;
        final e = DateTime(rawEnd.year, rawEnd.month, rawEnd.day, 23, 59, 59, 999);
        return (start: s, end: e);
    }
  }

  String _formatPeriodTitle(bool isThai, {DateTime? targetDate}) {
    final d = targetDate ?? _cursorDate;
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
        final m = isThai ? thaiShortMonths[d.month - 1] : DateFormat('MMM').format(d);
        return '${d.day} $m ${d.year}';

      case ReportGranularity.weekly:
        final range = _computeDateRange(targetDate: d);
        final s = range.start;
        final e = range.end;
        final sm = isThai ? thaiShortMonths[s.month - 1] : DateFormat('MMM').format(s);
        final em = isThai ? thaiShortMonths[e.month - 1] : DateFormat('MMM').format(e);
        return '${s.day} $sm - ${e.day} $em ${e.year}';

      case ReportGranularity.monthly:
        final m = isThai ? thaiMonths[d.month - 1] : DateFormat('MMMM').format(d);
        return '$m ${d.year}';

      case ReportGranularity.quarterly:
        final q = ((d.month - 1) ~/ 3) + 1;
        return 'Q$q ${d.year}';

      case ReportGranularity.yearly:
        return isThai ? 'ปี ${d.year}' : 'Year ${d.year}';

      case ReportGranularity.all:
        return isThai ? 'ข้อมูลทั้งหมด (All Time)' : 'All Time History';

      case ReportGranularity.custom:
        final range = _computeDateRange(targetDate: d);
        final s = range.start;
        final e = range.end;
        final sm = isThai ? thaiShortMonths[s.month - 1] : DateFormat('MMM').format(s);
        final em = isThai ? thaiShortMonths[e.month - 1] : DateFormat('MMM').format(e);
        return '${s.day} $sm ${s.year} - ${e.day} $em ${e.year}';
    }
  }

  Future<_PeriodReportData> _loadData({DateTime? targetDate}) async {
    final range = _computeDateRange(targetDate: targetDate);
    final start = range.start;
    final end = range.end;

    final txsDao = ref.read(transactionsDaoProvider);
    final currentTxs = await txsDao.searchTransactions(startDate: start, endDate: end);
    final allCats = await ref.read(categoriesDaoProvider).getAllCategories();
    final catMap = {for (final c in allCats) c.id: c};

    int livingIncomeSatang = 0;
    int accruedIncomeSatang = 0;
    int expenseSatang = 0;
    int investmentSatang = 0;
    int assetSaleProceedsSatang = 0;
    int dividendSatang = 0;
    int interestSatang = 0;

    final Map<String, int> expenseByCat = {};
    final Map<String, int> incomeByCat = {};

    for (final t in currentTxs) {
      if (t.transactionType == 'income') {
        final isAssetSale = (t.tag != null && t.tag!.startsWith('investment_sell:')) ||
            (t.categoryId == 'cat-inc-0000-4000-8000-000000000099');
        final isYield = (t.categoryId == 'cat-inc-0000-4000-8000-000000000003') ||
            (t.tag != null && (t.tag!.startsWith('dividend:') || t.tag!.startsWith('interest:')));

        if (isAssetSale) {
          if (t.isCleared) {
            assetSaleProceedsSatang += t.amountThbSatang;
          }
        } else if (isYield) {
          if (t.isCleared) {
            final noteLower = (t.note ?? '').toLowerCase();
            final tagLower = (t.tag ?? '').toLowerCase();
            if (tagLower.startsWith('dividend:') || noteLower.contains('dividend') || noteLower.contains('ปันผล')) {
              dividendSatang += t.amountThbSatang;
            } else {
              interestSatang += t.amountThbSatang;
            }
          }
        } else {
          if (t.isCleared) {
            livingIncomeSatang += t.amountThbSatang;
            final catId = t.categoryId ?? 'uncategorized';
            incomeByCat[catId] = (incomeByCat[catId] ?? 0) + t.amountThbSatang;
          } else {
            accruedIncomeSatang += t.amountThbSatang;
          }
        }
      } else if (t.transactionType == 'expense' || t.transactionType == 'invest_buy') {
        final isInvest = t.transactionType == 'invest_buy' ||
            (t.tag != null && t.tag!.startsWith('investment_buy:')) ||
            (t.categoryId == 'cat-exp-0000-4000-8000-000000000099');
        final cost = t.amountThbSatang + t.feeThbSatang;
        if (isInvest) {
          investmentSatang += cost;
        } else {
          expenseSatang += cost;
          final catId = t.categoryId ?? 'uncategorized';
          expenseByCat[catId] = (expenseByCat[catId] ?? 0) + cost;
        }
      }
    }

    final assetYieldSatang = dividendSatang + interestSatang;
    final incomeSatang = livingIncomeSatang;
    final savingsSatang = livingIncomeSatang - expenseSatang;
    final savingsRatePercent = livingIncomeSatang > 0
        ? ((savingsSatang / livingIncomeSatang) * 100.0).clamp(-100.0, 100.0)
        : 0.0;
    final netInvestmentFlowSatang = assetSaleProceedsSatang - investmentSatang;

    // คำนวณกำไร/ขาดทุนจากการขายที่รับรู้จริง (Realized Gain/Loss) จาก InvestmentsDao
    final invDao = ref.read(investmentsDaoProvider);
    final realizedSummary = await invDao.getRealizedGainLossForPeriod(start, end);
    final realizedGainLossSatang = realizedSummary.totalRealizedGainLossThbSatang;

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
      int prevInvest = 0;
      for (final t in prevTxs) {
        if (t.transactionType == 'income' && t.isCleared) {
          prevIncome += t.amountThbSatang;
        } else if (t.transactionType == 'expense' || t.transactionType == 'invest_buy') {
          final isInvest = t.transactionType == 'invest_buy' ||
              (t.tag != null && t.tag!.startsWith('investment_buy'));
          final cost = t.amountThbSatang + t.feeThbSatang;
          if (isInvest) {
            prevInvest += cost;
          } else {
            prevExpense += cost;
          }
        }
      }
      final prevSavings = prevIncome - prevExpense - prevInvest;
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
          !(t.tag != null && t.tag!.startsWith('investment_buy')) &&
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
      livingIncomeSatang: livingIncomeSatang,
      accruedIncomeSatang: accruedIncomeSatang,
      expenseSatang: expenseSatang,
      investmentSatang: investmentSatang,
      assetSaleProceedsSatang: assetSaleProceedsSatang,
      assetYieldSatang: assetYieldSatang,
      dividendSatang: dividendSatang,
      interestSatang: interestSatang,
      realizedGainLossSatang: realizedGainLossSatang,
      netInvestmentFlowSatang: netInvestmentFlowSatang,
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
    ref.watch(transactionsVersionProvider);
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  // 1. Granularity Selector (Day, Week, Month, Quarter, Year, All, Custom)
                  _buildGranularitySelector(context, isThai),
                  const SizedBox(height: 10),

                  // 2. Navigation Header with Date Title
                  _buildNavigationHeader(context, isLumi, isThai),
                ],
              ),
            ),

            // 3. Finger-Following Interactive PageView (เลื่อนติดนิ้ว)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: _granularity == ReportGranularity.all || _granularity == ReportGranularity.custom
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                onPageChanged: (index) {
                  final newDate = _calculateDateForPageIndex(index);
                  setState(() {
                    _cursorDate = newDate;
                  });
                },
                itemBuilder: (context, index) {
                  final pageDate = _calculateDateForPageIndex(index);
                  return FutureBuilder<_PeriodReportData>(
                    future: _loadData(targetDate: pageDate),
                    builder: (context, snapshot) {
                      final data = snapshot.data ??
                          _PeriodReportData(
                            startDate: pageDate,
                            endDate: pageDate,
                            incomeSatang: 0,
                            livingIncomeSatang: 0,
                            accruedIncomeSatang: 0,
                            expenseSatang: 0,
                            investmentSatang: 0,
                            assetSaleProceedsSatang: 0,
                            assetYieldSatang: 0,
                            dividendSatang: 0,
                            interestSatang: 0,
                            realizedGainLossSatang: 0,
                            netInvestmentFlowSatang: 0,
                            savingsSatang: 0,
                            savingsRatePercent: 0.0,
                            savingsMoMPercent: null,
                            cumulativeExpensesByDay: {1: 0, 8: 0, 15: 0, 22: 0, 30: 0},
                            daysInMonth: 30,
                            expenseCategories: [],
                            incomeCategories: [],
                          );

                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        children: [
                          // Unified Financial Summary Card
                          _buildUnifiedSummaryCard(context, data, isLumi, isThai),
                          const SizedBox(height: 16),

                          // Investment Portfolio Activities & Asset Yields Card
                          _buildInvestmentActivitiesCard(context, data, isLumi, isThai),
                          const SizedBox(height: 16),

                          // Cumulative Expense Trend Chart (if Monthly)
                          if (_granularity == ReportGranularity.monthly) ...[
                            _buildExpenseTrendCard(context, data, isLumi, isThai),
                            const SizedBox(height: 16),
                          ],

                          // Category Breakdown Section
                          _buildCategoryBreakdownCard(context, data, isThai),
                          const SizedBox(height: 36),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.75),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 26),
            color: isNavDisabled ? secondaryText.withValues(alpha: 0.3) : primaryText,
            onPressed: isNavDisabled ? null : _previousPeriod,
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _granularity == ReportGranularity.custom
                  ? () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2050),
                        initialDateRange: _customRange,
                      );
                      if (picked != null) {
                        setState(() => _customRange = picked);
                      }
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _formatPeriodTitle(isThai),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_granularity == ReportGranularity.custom) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.edit_calendar_outlined, size: 16, color: accent),
                    ],
                  ],
                ),
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
    );
  }

  Widget _buildUnifiedSummaryCard(
    BuildContext context,
    _PeriodReportData data,
    bool isLumi,
    bool isThai,
  ) {
    final surface = VaultTheme.surface(context);
    final border = VaultTheme.border(context);
    final primaryText = VaultTheme.primaryText(context);
    final secondaryText = VaultTheme.secondaryText(context);
    final negative = VaultTheme.negative(context);

    // Color theme
    const incomeColor = Color(0xFF16A34A);
    const expenseColor = Color(0xFFE11D48);
    const investColor = Color(0xFF6366F1);
    const savingsColor = Color(0xFF0D9488);

    final momText = data.savingsMoMPercent != null
        ? (data.savingsMoMPercent! >= 0
            ? '↑ ${data.savingsMoMPercent}% vs เดือนก่อน'
            : '↓ ${data.savingsMoMPercent!.abs()}% vs เดือนก่อน')
        : null;

    final isSavingsPositive = data.savingsSatang >= 0;

    // Ratios for horizontal bars
    final maxFlow = [
      data.incomeSatang,
      data.expenseSatang,
      data.investmentSatang,
      data.savingsSatang > 0 ? data.savingsSatang : 0,
    ].reduce(max);
    final safeMax = maxFlow > 0 ? maxFlow : 1;

    final incomeRatio = (data.incomeSatang / safeMax).clamp(0.0, 1.0);
    final expenseRatio = (data.expenseSatang / safeMax).clamp(0.0, 1.0);
    final investRatio = (data.investmentSatang / safeMax).clamp(0.0, 1.0);
    final savingsRatio = (isSavingsPositive ? data.savingsSatang / safeMax : 0.0).clamp(0.0, 1.0);

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
          // 1. Header with Title & Savings Rate Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.pie_chart_outline_rounded, size: 20, color: VaultTheme.accent(context)),
                  const SizedBox(width: 8),
                  Text(
                    isThai ? 'สรุปภาพรวมการเงิน' : 'Financial Summary',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isSavingsPositive ? incomeColor : negative).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isSavingsPositive ? incomeColor : negative).withValues(alpha: 0.3),
                    width: 0.75,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSavingsPositive ? Icons.savings_outlined : Icons.warning_amber_rounded,
                      size: 14,
                      color: isSavingsPositive ? incomeColor : negative,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${isThai ? "ออมได้" : "Savings"} ${data.savingsRatePercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSavingsPositive ? incomeColor : negative,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Metrics in 2x2 Grid (Income, Expense, Investment, Net Savings)
          Row(
            children: [
              // Income
              Expanded(
                child: _buildMetricTile(
                  label: isThai ? 'รายรับ' : 'Income',
                  amountSatang: data.incomeSatang,
                  color: incomeColor,
                  icon: Icons.arrow_downward_rounded,
                  badgeText: data.accruedIncomeSatang > 0
                      ? '+ค้างรับ ฿${Money(data.accruedIncomeSatang).format(symbol: "")}'
                      : null,
                  context: context,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TransactionListScreen(
                          initialTransactionType: 'income',
                          initialDateRange: DateTimeRange(start: data.startDate, end: data.endDate),
                          title: isThai ? 'รายรับ (${_formatPeriodTitle(isThai)})' : 'Income (${_formatPeriodTitle(isThai)})',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Expense
              Expanded(
                child: _buildMetricTile(
                  label: isThai ? 'รายจ่าย' : 'Expense',
                  amountSatang: data.expenseSatang,
                  color: expenseColor,
                  icon: Icons.arrow_upward_rounded,
                  context: context,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TransactionListScreen(
                          initialTransactionType: 'expense',
                          initialDateRange: DateTimeRange(start: data.startDate, end: data.endDate),
                          title: isThai ? 'รายจ่าย (${_formatPeriodTitle(isThai)})' : 'Expense (${_formatPeriodTitle(isThai)})',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Investment
              Expanded(
                child: _buildMetricTile(
                  label: isThai ? 'เงินลงทุน' : 'Investments',
                  amountSatang: data.investmentSatang,
                  color: investColor,
                  icon: Icons.trending_up_rounded,
                  context: context,
                ),
              ),
              const SizedBox(width: 10),
              // Net Savings
              Expanded(
                child: _buildMetricTile(
                  label: isThai ? 'เงินออมสุทธิ' : 'Net Savings',
                  amountSatang: data.savingsSatang,
                  color: isSavingsPositive ? savingsColor : negative,
                  icon: Icons.savings_outlined,
                  badgeText: momText,
                  context: context,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: border.withValues(alpha: 0.6), height: 1, thickness: 0.75),
          const SizedBox(height: 14),

          // 3. Horizontal Bar Chart Section (Compact and saves vertical space)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isThai ? 'แผนภูมิเปรียบเทียบสัดส่วน' : 'Comparison Chart',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: secondaryText,
                ),
              ),
              Text(
                isThai ? 'สัดส่วนกระแสเงินสด' : 'Cash Flow Ratio',
                style: TextStyle(fontSize: 11, color: secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal Bars
          _buildHorizontalBar(
            label: isThai ? 'รายรับ' : 'Income',
            amountSatang: data.incomeSatang,
            color: incomeColor,
            ratio: incomeRatio,
            context: context,
          ),
          const SizedBox(height: 8),
          _buildHorizontalBar(
            label: isThai ? 'รายจ่าย' : 'Expense',
            amountSatang: data.expenseSatang,
            color: expenseColor,
            ratio: expenseRatio,
            context: context,
          ),
          const SizedBox(height: 8),
          _buildHorizontalBar(
            label: isThai ? 'เงินลงทุน' : 'Invest',
            amountSatang: data.investmentSatang,
            color: investColor,
            ratio: investRatio,
            context: context,
          ),
          const SizedBox(height: 8),
          _buildHorizontalBar(
            label: isThai ? 'เงินออม' : 'Savings',
            amountSatang: data.savingsSatang,
            color: isSavingsPositive ? savingsColor : negative,
            ratio: savingsRatio,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentActivitiesCard(
    BuildContext context,
    _PeriodReportData data,
    bool isLumi,
    bool isThai,
  ) {
    final surface = VaultTheme.surface(context);
    final border = VaultTheme.border(context);
    final primaryText = VaultTheme.primaryText(context);
    final secondaryText = VaultTheme.secondaryText(context);
    const positive = Color(0xFF16A34A);
    final negative = VaultTheme.negative(context);

    // ผลตอบแทนรวมจากสินทรัพย์ (ปันผล/ดอกเบี้ย + Realized Gain)
    final totalPortfolioGainSatang = data.assetYieldSatang + data.realizedGainLossSatang;
    final isTotalGainPositive = totalPortfolioGainSatang >= 0;
    final isRealizedPositive = data.realizedGainLossSatang >= 0;
    final isNetFlowPositive = data.netInvestmentFlowSatang >= 0;

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
          // 1. Header with Title & Total Yield Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart_rounded, size: 20, color: const Color(0xFF6366F1)),
                  const SizedBox(width: 8),
                  Text(
                    isThai ? 'กิจกรรมและผลผลิตจากการลงทุน' : 'Investment Activities & Yields',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryText,
                    ),
                  ),
                ],
              ),
              if (totalPortfolioGainSatang != 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isTotalGainPositive ? positive : negative).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isTotalGainPositive ? positive : negative).withValues(alpha: 0.3),
                      width: 0.75,
                    ),
                  ),
                  child: Text(
                    '${isTotalGainPositive ? "+" : ""}${Money(totalPortfolioGainSatang).format(symbol: "฿")}',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isTotalGainPositive ? positive : negative,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Section 1: ผลผลิตจากสินทรัพย์ (Asset Yield & Realized Gain/Loss)
          Text(
            isThai ? 'ผลผลิตและผลตอบแทนจากสินทรัพย์' : 'Asset Yields & Capital Gains',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // ปันผล & ดอกเบี้ยรับ
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: VaultTheme.surfaceSubtle(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border.withValues(alpha: 0.5), width: 0.75),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 14, color: positive),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              isThai ? 'ปันผล & ดอกเบี้ย' : 'Dividends & Interest',
                              style: TextStyle(fontSize: 11, color: secondaryText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Money(data.assetYieldSatang).format(symbol: '฿'),
                        style: VaultTheme.tabular(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: data.assetYieldSatang > 0 ? positive : primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (data.dividendSatang > 0 || data.interestSatang > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          isThai
                              ? 'ปันผล ฿${Money(data.dividendSatang).format(symbol: "")} • ดอกเบี้ย ฿${Money(data.interestSatang).format(symbol: "")}'
                              : 'Div ฿${Money(data.dividendSatang).format(symbol: "")} • Int ฿${Money(data.interestSatang).format(symbol: "")}',
                          style: TextStyle(fontSize: 9.5, color: secondaryText.withValues(alpha: 0.8)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // กำไร/ขาดทุนที่รับรู้จริง
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: VaultTheme.surfaceSubtle(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border.withValues(alpha: 0.5), width: 0.75),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isRealizedPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                            size: 14,
                            color: data.realizedGainLossSatang != 0
                                ? (isRealizedPositive ? positive : negative)
                                : secondaryText,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              isThai ? 'กำไรขายที่รับรู้' : 'Realized Gain/Loss',
                              style: TextStyle(fontSize: 11, color: secondaryText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data.realizedGainLossSatang != 0
                            ? '${isRealizedPositive ? "+" : ""}${Money(data.realizedGainLossSatang).format(symbol: "฿")}'
                            : '฿0.00',
                        style: VaultTheme.tabular(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: data.realizedGainLossSatang != 0
                              ? (isRealizedPositive ? positive : negative)
                              : primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isThai ? '(ไม่รวมในภาษีทั่วไป)' : '(Excluded from regular tax)',
                        style: TextStyle(fontSize: 9.5, color: secondaryText.withValues(alpha: 0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3. Section 2: การเคลื่อนย้ายเงินสดในพอร์ต (Capital Movements)
          Divider(color: border.withValues(alpha: 0.5), height: 1, thickness: 0.75),
          const SizedBox(height: 12),
          Text(
            isThai ? 'การเคลื่อนย้ายเงินสดในพอร์ต (Capital Flow)' : 'Portfolio Capital Movements',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: secondaryText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMovementItem(
                label: isThai ? 'เงินลงทุนเพิ่ม (ซื้อ)' : 'Invested (Buy)',
                amountSatang: data.investmentSatang,
                prefix: '-',
                color: const Color(0xFF6366F1),
                context: context,
              ),
              _buildMovementItem(
                label: isThai ? 'เงินสดที่ได้คืน (ขาย)' : 'Liquidated (Sell)',
                amountSatang: data.assetSaleProceedsSatang,
                prefix: '+',
                color: const Color(0xFF0284C7),
                context: context,
              ),
              _buildMovementItem(
                label: isThai ? 'กระแสเงินสดสุทธิ' : 'Net Flow',
                amountSatang: data.netInvestmentFlowSatang.abs(),
                prefix: isNetFlowPositive ? '+' : '-',
                color: data.netInvestmentFlowSatang != 0
                    ? (isNetFlowPositive ? positive : secondaryText)
                    : primaryText,
                context: context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovementItem({
    required String label,
    required int amountSatang,
    required String prefix,
    required Color color,
    required BuildContext context,
  }) {
    final secondaryText = VaultTheme.secondaryText(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: VaultTheme.fontFamily,
              fontSize: 11,
              color: secondaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            amountSatang > 0 ? '$prefix${Money(amountSatang).format(symbol: "฿")}' : '฿0.00',
            style: VaultTheme.tabular(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required int amountSatang,
    required Color color,
    required IconData icon,
    String? badgeText,
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    final surfaceSubtle = VaultTheme.surfaceSubtle(context);
    final border = VaultTheme.border(context);
    final secondaryText = VaultTheme.secondaryText(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: surfaceSubtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 13, color: color),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: secondaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null)
                    Icon(Icons.chevron_right_rounded, size: 14, color: secondaryText.withValues(alpha: 0.6)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                Money(amountSatang).format(symbol: '฿'),
                style: VaultTheme.tabular(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (badgeText != null) ...[
                const SizedBox(height: 2),
                Text(
                  badgeText,
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalBar({
    required String label,
    required int amountSatang,
    required Color color,
    required double ratio,
    required BuildContext context,
  }) {
    final secondaryText = VaultTheme.secondaryText(context);
    final primaryText = VaultTheme.primaryText(context);

    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: VaultTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: secondaryText,
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * ratio.clamp(0.02, 1.0);
              return Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    width: barWidth,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 82,
          child: Text(
            Money(amountSatang).format(symbol: '฿'),
            textAlign: TextAlign.end,
            style: VaultTheme.tabular(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey<bool>(_showIncomeCategories),
              child: Column(
                children: [
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

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TransactionListScreen(
                                  initialTransactionType: _showIncomeCategories ? 'income' : 'expense',
                                  initialCategoryId: item.categoryId,
                                  initialDateRange: DateTimeRange(start: data.startDate, end: data.endDate),
                                  title: '${item.name} (${_formatPeriodTitle(isThai)})',
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: secondaryText.withValues(alpha: 0.5),
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
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
