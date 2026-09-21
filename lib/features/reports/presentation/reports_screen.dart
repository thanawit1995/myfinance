import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/export_excel_service.dart';
import '../../../core/services/export_pdf_service.dart';
import '../../../core/services/financial_reports_service.dart';
import '../../../core/theme/vault_theme.dart';
import '../../financial_health/domain/models/health_metric_result.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _selectedReportIndex = 0;
  final _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  // Filter parameters
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();

  bool _isLoading = false;

  MonthlySummaryReport? _monthlyReport;
  AnnualSummaryReport? _annualReport;
  CashFlowStatementReport? _cashFlowReport;
  PersonalBalanceSheetReport? _balanceSheetReport;
  InvestmentPortfolioReport? _portfolioReport;
  TaxPreparationReport? _taxReport;
  FinancialHealthSummary? _healthReport;

  final _reportTitles = [
    '1. สรุปรายเดือน',
    '2. สรุปรายปี',
    '3. งบกระแสเงินสด',
    '4. งบดุลส่วนบุคคล',
    '5. พอร์ตการลงทุน',
    '6. ชุดเตรียมยื่นภาษี',
    '7. สุขภาพการเงิน',
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedReport();
  }

  Future<void> _loadSelectedReport() async {
    setState(() => _isLoading = true);
    final service = ref.read(financialReportsServiceProvider);

    try {
      switch (_selectedReportIndex) {
        case 0:
          _monthlyReport = await service.generateMonthlySummary(_selectedYear, _selectedMonth);
          break;
        case 1:
          _annualReport = await service.generateAnnualSummary(_selectedYear);
          break;
        case 2:
          _cashFlowReport = await service.generateCashFlowStatement(_startDate, _endDate);
          break;
        case 3:
          _balanceSheetReport = await service.generatePersonalBalanceSheet(_endDate);
          break;
        case 4:
          _portfolioReport = await service.generateInvestmentPortfolioReport();
          break;
        case 5:
          _taxReport = await service.generateTaxPreparationReport(_selectedYear);
          break;
        case 6:
          _healthReport = await service.generateFinancialHealthReport();
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดรายงาน: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportExcel() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กำลังสร้างไฟล์ Excel รวมทุกรายงานพร้อมสูตรคำนวณ...')),
      );

      final service = ref.read(financialReportsServiceProvider);
      // Fetch all reports to package into Excel sheets
      final m = _monthlyReport ?? await service.generateMonthlySummary(_selectedYear, _selectedMonth);
      final a = _annualReport ?? await service.generateAnnualSummary(_selectedYear);
      final c = _cashFlowReport ?? await service.generateCashFlowStatement(_startDate, _endDate);
      final b = _balanceSheetReport ?? await service.generatePersonalBalanceSheet(_endDate);
      final p = _portfolioReport ?? await service.generateInvestmentPortfolioReport();
      final t = _taxReport ?? await service.generateTaxPreparationReport(_selectedYear);

      final file = await ExportExcelService.exportComprehensiveReport(
        monthly: m,
        annual: a,
        cashFlow: c,
        balanceSheet: b,
        portfolio: p,
        taxReport: t,
      );

      if (mounted) {
        await ExportExcelService.shareFile(context, file, subject: 'MyFinance Comprehensive Report');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ส่งออก Excel ล้มเหลว: $e')));
      }
    }
  }

  Future<void> _exportPdf() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กำลังสร้างไฟล์ PDF ฝังฟอนต์ไทย...')),
      );

      if (_selectedReportIndex == 0 && _monthlyReport != null) {
        final file = await ExportPdfService.exportMonthlySummaryToPdf(_monthlyReport!);
        if (mounted) await ExportPdfService.shareFile(context, file, subject: 'Monthly Summary Report');
      } else if (_selectedReportIndex == 3 && _balanceSheetReport != null) {
        final file = await ExportPdfService.exportBalanceSheetToPdf(_balanceSheetReport!);
        if (mounted) await ExportPdfService.shareFile(context, file, subject: 'Balance Sheet Report');
      } else if (_selectedReportIndex == 5 && _taxReport != null) {
        final file = await ExportPdfService.exportTaxReportToPdf(_taxReport!);
        if (mounted) await ExportPdfService.shareFile(context, file, subject: 'Tax Preparation Report');
      } else {
        // Default to tax or monthly PDF
        final service = ref.read(financialReportsServiceProvider);
        final report = await service.generateTaxPreparationReport(_selectedYear);
        final file = await ExportPdfService.exportTaxReportToPdf(report);
        if (mounted) await ExportPdfService.shareFile(context, file, subject: 'MyFinance Report');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ส่งออก PDF ล้มเหลว: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ระบบรายงานการเงิน (7 Reports)'),
        actions: [
          IconButton(
            icon: Icon(Icons.table_chart_outlined, color: VaultTheme.positive(context)),
            tooltip: 'ส่งออก Excel รวม (.xlsx)',
            onPressed: _exportExcel,
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf_outlined, color: VaultTheme.negative(context)),
            tooltip: 'ส่งออก PDF (A4)',
            onPressed: _exportPdf,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSelectedReport,
          ),
        ],
      ),
      body: Column(
        children: [
          // Report Selector Tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: VaultTheme.surfaceSubtle(context),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: List.generate(_reportTitles.length, (index) {
                  final isSelected = _selectedReportIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_reportTitles[index]),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedReportIndex = index);
                          _loadSelectedReport();
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
          ),

          // Date Filter Toolbar
          _buildFilterToolbar(),

          // Main Report Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildReportContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToolbar() {
    final bg = VaultTheme.surface(context);
    final borderColor = VaultTheme.border(context);
    final textColor = VaultTheme.primaryText(context);
    final muted = VaultTheme.mutedText(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.75)),
      ),
      child: Row(
        children: [
          if (_selectedReportIndex == 0) ...[
            // Month & Year Filter
            Icon(Icons.calendar_today, size: 16, color: muted),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: _selectedMonth,
              dropdownColor: bg,
              style: TextStyle(color: textColor, fontFamily: VaultTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600),
              underline: const SizedBox.shrink(),
              isDense: true,
              items: List.generate(
                12,
                (i) => DropdownMenuItem(value: i + 1, child: Text('เดือน ${i + 1}')),
              ),
              onChanged: (m) {
                if (m != null) {
                  setState(() => _selectedMonth = m);
                  _loadSelectedReport();
                }
              },
            ),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: _selectedYear,
              dropdownColor: bg,
              style: TextStyle(color: textColor, fontFamily: VaultTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600),
              underline: const SizedBox.shrink(),
              isDense: true,
              items: const [
                DropdownMenuItem(value: 2024, child: Text('2024')),
                DropdownMenuItem(value: 2025, child: Text('2025')),
                DropdownMenuItem(value: 2026, child: Text('2026')),
              ],
              onChanged: (y) {
                if (y != null) {
                  setState(() => _selectedYear = y);
                  _loadSelectedReport();
                }
              },
            ),
          ] else if (_selectedReportIndex == 1 || _selectedReportIndex == 5) ...[
            // Year only filter
            Icon(Icons.calendar_today, size: 16, color: muted),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: _selectedYear,
              dropdownColor: bg,
              style: TextStyle(color: textColor, fontFamily: VaultTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600),
              underline: const SizedBox.shrink(),
              isDense: true,
              items: const [
                DropdownMenuItem(value: 2024, child: Text('ปี 2024')),
                DropdownMenuItem(value: 2025, child: Text('ปี 2025')),
                DropdownMenuItem(value: 2026, child: Text('ปี 2026')),
              ],
              onChanged: (y) {
                if (y != null) {
                  setState(() => _selectedYear = y);
                  _loadSelectedReport();
                }
              },
            ),
          ] else if (_selectedReportIndex == 2) ...[
            // Arbitrary Date Range Filter
            Icon(Icons.date_range, size: 16, color: muted),
            const SizedBox(width: 8),
            Text(
              '${DateFormat('dd/MM/yy').format(_startDate)} - ${DateFormat('dd/MM/yy').format(_endDate)}',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor),
            ),
            const Spacer(),
            TextButton.icon(
              icon: Icon(Icons.edit_calendar, size: 16, color: VaultTheme.accent(context)),
              label: Text('เลือกช่วงเวลา', style: TextStyle(color: VaultTheme.accent(context))),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
                );
                if (picked != null) {
                  setState(() {
                    _startDate = picked.start;
                    _endDate = picked.end;
                  });
                  _loadSelectedReport();
                }
              },
            ),
          ] else ...[
            Icon(Icons.info_outline, size: 16, color: muted),
            const SizedBox(width: 8),
            Text(
              'ข้อมูลสถานะปัจจุบัน ณ วันที่ ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
              style: TextStyle(fontSize: 12.5, color: VaultTheme.secondaryText(context)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    switch (_selectedReportIndex) {
      case 0:
        return _buildMonthlyView();
      case 1:
        return _buildAnnualView();
      case 2:
        return _buildCashFlowView();
      case 3:
        return _buildBalanceSheetView();
      case 4:
        return _buildPortfolioView();
      case 5:
        return _buildTaxView();
      case 6:
        return _buildHealthView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMonthlyView() {
    final r = _monthlyReport;
    if (r == null) return const Center(child: Text('ไม่มีข้อมูล'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMetricCards(
          'รายได้รวม: ฿${_currencyFormat.format(r.totalIncomeSatang / 100.0)}',
          'รายจ่ายรวม: ฿${_currencyFormat.format(r.totalExpenseSatang / 100.0)}',
          'เงินออมสุทธิ: ฿${_currencyFormat.format(r.netSavingsSatang / 100.0)} (${r.savingsRatePercent.toStringAsFixed(1)}%)',
        ),
        const SizedBox(height: 16),
        const Text('เปรียบเทียบค่าใช้จ่ายกับงบประมาณรายหมวดหมู่', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: VaultTheme.border(context), width: 0.75),
          ),
          color: VaultTheme.surface(context),
          child: Column(
            children: r.categories.map((c) {
              return ListTile(
                title: Text(c.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('งบประมาณ: ฿${_currencyFormat.format(c.budgetSatang / 100.0)} (${c.percentOfBudget.toStringAsFixed(0)}%)'),
                trailing: Text(
                  '฿${_currencyFormat.format(c.actualSatang / 100.0)}',
                  style: VaultTheme.tabular(
                    fontWeight: FontWeight.bold,
                    color: c.varianceSatang < 0 ? VaultTheme.negative(context) : VaultTheme.positive(context),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnualView() {
    final r = _annualReport;
    if (r == null) return const Center(child: Text('ไม่มีข้อมูล'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMetricCards(
          'รายได้ทั้งปี: ฿${_currencyFormat.format(r.totalIncomeSatang / 100.0)}',
          'รายจ่ายทั้งปี: ฿${_currencyFormat.format(r.totalExpenseSatang / 100.0)}',
          'เงินออมสุทธิ: ฿${_currencyFormat.format(r.netSavingsSatang / 100.0)}',
        ),
        const SizedBox(height: 16),
        const Text('สรุป 12 เดือนเรียงกัน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: VaultTheme.border(context), width: 0.75),
          ),
          color: VaultTheme.surface(context),
          child: Column(
            children: r.months.map((m) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: VaultTheme.surfaceSubtle(context),
                  child: Text('${m.month}', style: TextStyle(color: VaultTheme.primaryText(context), fontWeight: FontWeight.bold)),
                ),
                title: Text('เดือนที่ ${m.month}'),
                subtitle: Text('รายได้: ฿${_currencyFormat.format(m.incomeSatang / 100.0)} | จ่าย: ฿${_currencyFormat.format(m.expenseSatang / 100.0)}'),
                trailing: Text(
                  '฿${_currencyFormat.format(m.netSatang / 100.0)}',
                  style: VaultTheme.tabular(
                    fontWeight: FontWeight.bold,
                    color: m.netSatang >= 0 ? VaultTheme.positive(context) : VaultTheme.negative(context),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCashFlowView() {
    final r = _cashFlowReport;
    if (r == null) return const Center(child: Text('ไม่มีข้อมูล'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VaultTheme.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: VaultTheme.border(context), width: 0.75),
          ),
          child: Column(
            children: [
              Text(
                'กระแสเงินสดสุทธิ (Net Cash Flow)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: VaultTheme.secondaryText(context)),
              ),
              const SizedBox(height: 8),
              Text(
                '฿${_currencyFormat.format(r.netCashFlowSatang / 100.0)}',
                style: VaultTheme.tabular(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: r.netCashFlowSatang >= 0 ? VaultTheme.positive(context) : VaultTheme.negative(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard('กิจกรรมดำเนินงาน (Operating Activities)', r.netOperatingSatang, r.operatingItems),
        const SizedBox(height: 12),
        _buildSectionCard('กิจกรรมลงทุน (Investing Activities)', r.netInvestingSatang, r.investingItems),
        const SizedBox(height: 12),
        _buildSectionCard('กิจกรรมจัดหาเงิน (Financing Activities)', r.netFinancingSatang, r.financingItems),
      ],
    );
  }

  Widget _buildBalanceSheetView() {
    final r = _balanceSheetReport;
    if (r == null) return const Center(child: Text('ไม่มีข้อมูล'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VaultTheme.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: VaultTheme.border(context), width: 0.75),
          ),
          child: Column(
            children: [
              Text(
                'ความมั่งคั่งสุทธิ (Net Worth)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: VaultTheme.secondaryText(context)),
              ),
              const SizedBox(height: 8),
              Text(
                '฿${_currencyFormat.format(r.netWorthSatang / 100.0)}',
                style: VaultTheme.tabular(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: VaultTheme.accent(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'สินทรัพย์รวม: ฿${_currencyFormat.format(r.totalAssetsSatang / 100.0)} | หนี้สินรวม: ฿${_currencyFormat.format(r.totalLiabilitiesSatang / 100.0)}',
                style: TextStyle(fontSize: 12, color: VaultTheme.secondaryText(context)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('สินทรัพย์ (Assets)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: VaultTheme.positive(context))),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: VaultTheme.border(context), width: 0.75),
          ),
          color: VaultTheme.surface(context),
          child: Column(
            children: r.assetItems.map((a) => ListTile(
              title: Text(a.name),
              subtitle: Text(a.category),
              trailing: Text('฿${_currencyFormat.format(a.valueSatang / 100.0)}', style: VaultTheme.tabular(fontWeight: FontWeight.bold)),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Text('หนี้สิน (Liabilities)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: VaultTheme.negative(context))),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: VaultTheme.border(context), width: 0.75),
          ),
          color: VaultTheme.surface(context),
          child: Column(
            children: r.liabilityItems.map((l) => ListTile(
              title: Text(l.name),
              subtitle: Text(l.category),
              trailing: Text('฿${_currencyFormat.format(l.valueSatang / 100.0)}', style: VaultTheme.tabular(fontWeight: FontWeight.bold)),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioView() {
    final r = _portfolioReport;
    if (r == null) return const Center(child: Text('ไม่มีข้อมูล'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMetricCards(
          'มูลค่าตลาดรวม: ฿${_currencyFormat.format(r.totalMarketValueSatang / 100.0)}',
          'ต้นทุนรวม: ฿${_currencyFormat.format(r.totalCostSatang / 100.0)}',
          'กำไร/ขาดทุนพอร์ต: ฿${_currencyFormat.format(r.unrealizedGainLossSatang / 100.0)} (${r.unrealizedReturnPercent.toStringAsFixed(2)}%)',
        ),
        const SizedBox(height: 16),
        const Text('รายการสินทรัพย์ที่ถือครอง', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: VaultTheme.border(context), width: 0.75),
          ),
          color: VaultTheme.surface(context),
          child: Column(
            children: r.holdings.map((h) {
              return ListTile(
                title: Text('${h.symbol} — ${h.name}'),
                subtitle: Text('${h.units} หน่วย (${h.assetType})'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('฿${_currencyFormat.format(h.marketValueSatang / 100.0)}', style: VaultTheme.tabular(fontWeight: FontWeight.bold)),
                    Text(
                      '${h.returnPercent >= 0 ? "+" : ""}${h.returnPercent.toStringAsFixed(1)}%',
                      style: VaultTheme.tabular(
                        fontSize: 12,
                        color: h.returnPercent >= 0 ? VaultTheme.positive(context) : VaultTheme.negative(context),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxView() {
    final r = _taxReport;
    if (r == null) return const Center(child: Text('ไม่มีข้อมูล'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VaultTheme.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: r.isRefund
                  ? VaultTheme.positive(context).withValues(alpha: 0.5)
                  : VaultTheme.negative(context).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                r.isRefund ? 'ยอดภาษีที่ขอคืนได้' : 'ยอดภาษีที่ต้องชำระเพิ่ม',
                style: TextStyle(fontWeight: FontWeight.bold, color: VaultTheme.primaryText(context)),
              ),
              const SizedBox(height: 6),
              Text(
                '฿${_currencyFormat.format(r.netTaxDueSatang.abs() / 100.0)}',
                style: VaultTheme.tabular(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: r.isRefund ? VaultTheme.positive(context) : VaultTheme.negative(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: VaultTheme.border(context), width: 0.75),
          ),
          color: VaultTheme.surface(context),
          child: Column(
            children: [
              ListTile(title: const Text('เงินได้พึงประเมินรวม'), trailing: Text('฿${_currencyFormat.format(r.totalGrossIncomeSatang / 100.0)}', style: VaultTheme.tabular())),
              ListTile(title: const Text('หักค่าใช้จ่ายตามกฎหมาย'), trailing: Text('- ฿${_currencyFormat.format(r.totalExpenseDeductionsSatang / 100.0)}', style: VaultTheme.tabular())),
              ListTile(title: const Text('หักค่าลดหย่อนรวม'), trailing: Text('- ฿${_currencyFormat.format(r.totalAllowancesSatang / 100.0)}', style: VaultTheme.tabular())),
              ListTile(title: const Text('เงินได้สุทธิ (Net Taxable)'), trailing: Text('฿${_currencyFormat.format(r.netTaxableIncomeSatang / 100.0)}', style: VaultTheme.tabular(fontWeight: FontWeight.bold))),
              ListTile(title: const Text('ภาษีขั้นบันได'), trailing: Text('฿${_currencyFormat.format(r.computedTaxSatang / 100.0)}', style: VaultTheme.tabular())),
              ListTile(title: const Text('หักภาษี ณ ที่จ่าย (WHT)'), trailing: Text('- ฿${_currencyFormat.format(r.totalWithholdingTaxSatang / 100.0)}', style: VaultTheme.tabular())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthView() {
    final r = _healthReport;
    if (r == null) return const Center(child: Text('ไม่มีข้อมูล'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VaultTheme.surface(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: VaultTheme.border(context), width: 0.75),
          ),
          child: Column(
            children: [
              Text(
                'คะแนนสุขภาพการเงินรวม (0 - 100 คะแนน)',
                style: TextStyle(fontWeight: FontWeight.bold, color: VaultTheme.secondaryText(context)),
              ),
              const SizedBox(height: 6),
              Text(
                '${r.totalScore} / 100',
                style: VaultTheme.tabular(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: VaultTheme.accent(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'สถานะ: ${r.overallStatus == HealthStatus.pass ? "ดีเยี่ยม (Pass)" : (r.overallStatus == HealthStatus.warning ? "ควรระวัง (Warning)" : "ต้องปรับปรุง (Fail)")}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: r.overallStatus == HealthStatus.pass
                      ? VaultTheme.positive(context)
                      : (r.overallStatus == HealthStatus.warning
                          ? VaultTheme.accent(context)
                          : VaultTheme.negative(context)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...r.metrics.map((m) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: VaultTheme.border(context), width: 0.75),
            ),
            color: VaultTheme.surface(context),
            child: ListTile(
              title: Text('${m.metricIndex}. ${m.title}', style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${m.subtitle}\nเป้าหมาย: ${m.targetThreshold}'),
              trailing: Text('${m.score} / ${m.maxScore} คะแนน', style: VaultTheme.tabular(fontWeight: FontWeight.bold)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMetricCards(String c1, String c2, String c3) {
    return Container(
      decoration: BoxDecoration(
        color: VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: VaultTheme.border(context), width: 0.75),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c1, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: VaultTheme.primaryText(context))),
          const SizedBox(height: 6),
          Text(c2, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: VaultTheme.secondaryText(context))),
          const SizedBox(height: 6),
          Text(c3, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: VaultTheme.accent(context))),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, int netSatang, List<CashFlowItem> items) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: VaultTheme.border(context), width: 0.75),
      ),
      color: VaultTheme.surface(context),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
        subtitle: Text(
          'สุทธิ: ฿${_currencyFormat.format(netSatang / 100.0)}',
          style: VaultTheme.tabular(
            fontWeight: FontWeight.w600,
            color: netSatang >= 0 ? VaultTheme.positive(context) : VaultTheme.negative(context),
          ),
        ),
        children: items.map((i) {
          return ListTile(
            dense: true,
            title: Text(i.label),
            trailing: Text(
              '${i.isInflow ? "+" : "-"}฿${_currencyFormat.format(i.amountSatang / 100.0)}',
              style: VaultTheme.tabular(
                color: i.isInflow ? VaultTheme.positive(context) : VaultTheme.negative(context),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
