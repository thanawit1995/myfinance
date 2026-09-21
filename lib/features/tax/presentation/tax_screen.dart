import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/services/export_excel_service.dart';
import '../../../core/services/export_pdf_service.dart';
import '../../../core/services/financial_reports_service.dart';
import 'tax_rules_edit_dialog.dart';

class TaxScreen extends ConsumerStatefulWidget {
  const TaxScreen({super.key});

  @override
  ConsumerState<TaxScreen> createState() => _TaxScreenState();
}

class _TaxScreenState extends ConsumerState<TaxScreen> {
  int _selectedTaxYear = DateTime.now().year;
  bool _isLoading = false;
  TaxPreparationReport? _taxReport;
  final _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    _loadTaxData();
  }

  Future<void> _loadTaxData() async {
    setState(() => _isLoading = true);
    try {
      final reportsService = ref.read(financialReportsServiceProvider);
      final report = await reportsService.generateTaxPreparationReport(_selectedTaxYear);
      if (mounted) {
        setState(() {
          _taxReport = report;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูลภาษี: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportPdf() async {
    if (_taxReport == null) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กำลังสร้างไฟล์ PDF ฝังฟอนต์ภาษาไทย...')),
      );
      final file = await ExportPdfService.exportTaxReportToPdf(_taxReport!);
      if (mounted) {
        await ExportPdfService.shareFile(context, file, subject: 'MyFinance Tax Report $_selectedTaxYear');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ส่งออก PDF ล้มเหลว: $e')));
      }
    }
  }

  Future<void> _exportExcel() async {
    if (_taxReport == null) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กำลังสร้างไฟล์ Excel หลาย Sheet พร้อมสูตรคำนวณ...')),
      );
      final file = await ExportExcelService.exportComprehensiveReport(taxReport: _taxReport!);
      if (mounted) {
        await ExportExcelService.shareFile(context, file, subject: 'MyFinance Tax Report $_selectedTaxYear');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ส่งออก Excel ล้มเหลว: $e')));
      }
    }
  }

  List<int> _availableTaxYears() {
    final currentYear = DateTime.now().year;
    final maxYear = currentYear; // Do not show future tax years until arrived
    final minYear = 2024;
    return List.generate(maxYear - minYear + 1, (i) => maxYear - i);
  }

  @override
  Widget build(BuildContext context) {
    final report = _taxReport;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      appBar: AppBar(
        title: Text(isThai ? 'วางแผนภาษี (ภ.ง.ด. 90/91)' : 'Tax Planning (P.N.D. 90/91)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: isThai ? 'แก้ไขกฎภาษีและค่าลดหย่อน' : 'Tax Rules & Deductions',
            onPressed: () async {
              final rule = await ref.read(taxDaoProvider).getTaxRule(_selectedTaxYear);
              if (context.mounted) {
                TaxRulesEditDialog.show(
                  context,
                  taxYear: _selectedTaxYear,
                  existingRule: rule,
                  onSaved: _loadTaxData,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isThai ? 'รีเฟรช' : 'Refresh',
            onPressed: _loadTaxData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : report == null
              ? Center(child: Text(isThai ? 'ไม่พบข้อมูลสำหรับปีภาษีนี้' : 'No data found for this tax year'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Tax Year Selector Card (Moved from AppBar for clean mobile view)
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_outlined, size: 22, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 10),
                            Text(
                              isThai ? 'ปีภาษี' : 'Tax Year',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const Spacer(),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _selectedTaxYear,
                                dropdownColor: Theme.of(context).cardColor,
                                items: _availableTaxYears().map((y) {
                                  final beYear = y + 543;
                                  return DropdownMenuItem(
                                    value: y,
                                    child: Text(
                                      isThai ? 'ค.ศ. $y (พ.ศ. $beYear)' : 'CE $y (B.E. $beYear)',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (y) {
                                  if (y != null && y != _selectedTaxYear) {
                                    setState(() => _selectedTaxYear = y);
                                    _loadTaxData();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Legal Disclaimer Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2E2412) : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isDark ? Colors.amber.shade700 : Colors.amber.shade400),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: isDark ? Colors.amber.shade400 : Colors.amber.shade800),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isThai
                                  ? 'คำเตือน: โปรแกรมนี้เป็นเครื่องมือคำนวณและประมาณการเพื่อเตรียมเอกสารยื่นภาษีเท่านั้น ไม่ถือเป็นคำแนะนำทางภาษีหรือเอกสารรับรองของทางราชการ โปรดตรวจสอบรายละเอียดกับกรมสรรพากรก่อนยื่นแบบจริง'
                                  : 'Disclaimer: This tool calculates and estimates tax figures for filing preparation only. It does not constitute official tax advice. Please verify with the Revenue Department before filing.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark ? Colors.amber.shade100 : Colors.brown,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Top Summary Card (Net Tax Due or Refund)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: report.isRefund
                          ? (isDark ? const Color(0xFF0F3823) : Colors.green.shade50)
                          : (isDark ? const Color(0xFF3B1717) : Colors.red.shade50),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              report.isRefund
                                  ? (isThai ? 'ยอดที่ขอคืนภาษีได้ (Tax Refund)' : 'Estimated Tax Refund')
                                  : (isThai ? 'ยอดที่ต้องชำระภาษีเพิ่มเติม (Tax Due)' : 'Estimated Tax Due'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: report.isRefund
                                    ? (isDark ? Colors.green.shade300 : Colors.green.shade800)
                                    : (isDark ? Colors.red.shade300 : Colors.red.shade800),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '฿${_currencyFormat.format(report.netTaxDueSatang.abs() / 100.0)}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: report.isRefund
                                    ? (isDark ? Colors.green.shade200 : Colors.green.shade900)
                                    : (isDark ? Colors.red.shade200 : Colors.red.shade900),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildSummaryPill(
                                  isThai ? 'ภาษีขั้นบันได' : 'Progressive Tax',
                                  '฿${_currencyFormat.format(report.computedTaxSatang / 100.0)}',
                                  isDark: isDark,
                                ),
                                _buildSummaryPill(
                                  isThai ? 'หัก ณ ที่จ่าย (WHT)' : 'Withheld (WHT)',
                                  '฿${_currencyFormat.format(report.totalWithholdingTaxSatang / 100.0)}',
                                  isDark: isDark,
                                ),
                                if (report.totalDividendTaxCreditSatang > 0)
                                  _buildSummaryPill(
                                    isThai ? 'เครดิตปันผล' : 'Dividend Credit',
                                    '฿${_currencyFormat.format(report.totalDividendTaxCreditSatang / 100.0)}',
                                    isDark: isDark,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dividend Strategy Comparison Card
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.analytics_outlined, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  isThai ? 'เปรียบเทียบกลยุทธ์เงินปันผลหุ้นไทย' : 'Thai Stock Dividend Strategy Comparison',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              report.dividendOptimization.isFinalTaxBetter
                                  ? (isThai
                                      ? '💡 คำแนะนำ: เลือก Final Tax 10% ประหยัดกว่าการนำมารวมคำนวณ เป็นเงิน ฿${_currencyFormat.format(report.dividendOptimization.taxDifferenceSatang / 100.0)}'
                                      : '💡 Recommendation: Final Tax 10% saves ฿${_currencyFormat.format(report.dividendOptimization.taxDifferenceSatang / 100.0)} vs combining into progressive income')
                                  : (isThai
                                      ? '💡 คำแนะนำ: รวมปันผลเพื่อขอเครดิตภาษี คุ้มกว่า Final Tax 10% ได้รับเงินคืนเพิ่ม ฿${_currencyFormat.format(report.dividendOptimization.taxDifferenceSatang / 100.0)}'
                                      : '💡 Recommendation: Combine dividends for tax credit, saving/refund ฿${_currencyFormat.format(report.dividendOptimization.taxDifferenceSatang / 100.0)} vs Final Tax 10%'),
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.blue.shade200 : Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Step-by-Line Breakdown Table
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isThai ? 'สรุปรายการภาษี ภ.ง.ด.' : 'Tax Filing Summary (P.N.D.)',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            _buildDataRow(
                              isThai ? '1. เงินได้พึงประเมินรวม (Gross Income)' : '1. Total Assessable Gross Income',
                              report.totalGrossIncomeSatang,
                            ),
                            _buildDataRow(
                              isThai ? '2. หัก ค่าใช้จ่ายตามกฎหมาย' : '2. Less Standard Expense Deduction',
                              -report.totalExpenseDeductionsSatang,
                              isDeduction: true,
                            ),
                            _buildDataRow(
                              isThai ? '3. เงินได้หลังหักค่าใช้จ่าย' : '3. Income after Expense Deductions',
                              report.totalGrossIncomeSatang - report.totalExpenseDeductionsSatang,
                            ),
                            _buildDataRow(
                              isThai ? '4. หัก ค่าลดหย่อนรวม' : '4. Less Total Personal & Other Allowances',
                              -report.totalAllowancesSatang,
                              isDeduction: true,
                            ),
                            const Divider(),
                            _buildDataRow(
                              isThai ? '5. เงินได้สุทธิ (Net Taxable Income)' : '5. Net Taxable Income',
                              report.netTaxableIncomeSatang,
                              isBold: true,
                            ),
                            _buildDataRow(
                              isThai ? '6. ภาษีคำนวณตามขั้นบันได (Progressive Tax)' : '6. Progressive Bracket Tax',
                              report.computedTaxSatang,
                            ),
                            _buildDataRow(
                              isThai ? '7. หัก ภาษีหัก ณ ที่จ่ายรวม (WHT)' : '7. Less Total Withholding Tax (WHT)',
                              -report.totalWithholdingTaxSatang,
                              isDeduction: true,
                            ),
                            _buildDataRow(
                              isThai ? '8. หัก เครดิตภาษีเงินปันผล' : '8. Less Dividend Tax Credit',
                              -report.totalDividendTaxCreditSatang,
                              isDeduction: true,
                            ),
                            const Divider(thickness: 1.5),
                            _buildDataRow(
                              report.isRefund
                                  ? (isThai ? 'ยอดเงินคืนภาษี' : 'Net Tax Refund')
                                  : (isThai ? 'ยอดภาษีที่ต้องชำระเพิ่ม' : 'Net Tax Due'),
                              report.netTaxDueSatang.abs(),
                              isBold: true,
                              textColor: report.isRefund ? Colors.green.shade800 : Colors.red.shade800,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Expandable Line-by-Line Steps
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ExpansionTile(
                        leading: const Icon(Icons.format_list_numbered, color: Colors.teal),
                        title: Text(isThai ? 'ขั้นตอนการคำนวณทีละบรรทัด (Audit Trail)' : 'Step-by-Step Calculation (Audit Trail)'),
                        subtitle: Text(isThai ? 'ตรวจสอบสูตร ตัวเลข และขั้นบันไดภาษีอย่างละเอียด' : 'Detailed formulas, numbers and tax brackets'),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: report.calculationSteps
                                  .map((s) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          s,
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12.5,
                                            color: s.startsWith('===')
                                                ? (isDark ? Colors.blue.shade200 : Colors.blue.shade900)
                                                : (isDark ? Colors.white70 : Colors.black87),
                                            fontWeight: s.startsWith('===') || s.startsWith('7.') ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Expandable Income Audit (ราย Transaction พร้อมวันที่และ หัก ณ ที่จ่าย)
                    _buildIncomeAuditCard(context, report, isDark),
                    const SizedBox(height: 16),

                    // Expandable Remittances Audit (การนำเงินเข้าไทย: กำไร/เงินต้น)
                    _buildRemittancesAuditCard(context, report, isDark),
                    const SizedBox(height: 24),

                    // Export Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.table_chart_outlined),
                            label: Text(isThai ? 'ส่งออก Excel (.xlsx)' : 'Export Excel'),
                            onPressed: _exportExcel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: Text(isThai ? 'ส่งออก PDF (A4)' : 'Export PDF'),
                            onPressed: _exportPdf,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
    );
  }

  Widget _buildIncomeAuditCard(BuildContext context, TaxPreparationReport report, bool isDark) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        leading: const Icon(Icons.receipt_long, color: Colors.indigo),
        title: Text(isThai ? 'ตรวจสอบรายการเงินได้ (ราย Transaction)' : 'Income Audit (Per Transaction)'),
        subtitle: Text(
          report.incomeTransactions.isEmpty
              ? (isThai ? 'ไม่มีรายการเงินได้ในปีนี้' : 'No income transactions this year')
              : (isThai
                  ? 'ทั้งหมด ${report.incomeTransactions.length} รายการ (มีวันที่และหัก ณ ที่จ่ายชัดเจน)'
                  : '${report.incomeTransactions.length} transactions (dated with WHT details)'),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
            width: double.infinity,
            child: report.incomeTransactions.isEmpty
                ? Text(
                    isThai ? 'ไม่พบรายการเงินได้ในปีภาษีนี้' : 'No income recorded for this tax year',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  )
                : Column(
                    children: report.incomeTransactions.map((tx) {
                      final dateStr = DateFormat('yyyy-MM-dd').format(tx.transactionDate);
                      final amtStr = _currencyFormat.format(tx.amountThbSatang / 100.0);
                      final whtStr = _currencyFormat.format(tx.withholdingTaxSatang / 100.0);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatTaxCategory(tx.taxCategory),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  if (tx.description.isNotEmpty)
                                    Text(
                                      tx.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '+ ฿$amtStr',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                if (tx.withholdingTaxSatang > 0)
                                  Text(
                                    '${isThai ? "หัก ณ ที่จ่าย" : "WHT"} ฿$whtStr',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.orange.shade300 : Colors.orange.shade800,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemittancesAuditCard(BuildContext context, TaxPreparationReport report, bool isDark) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final totalRemit = _currencyFormat.format(report.totalRemittanceSatang / 100.0);
    final taxable = _currencyFormat.format(report.totalRemittanceTaxableSatang / 100.0);
    final principal = _currencyFormat.format(report.totalRemittancePrincipalSatang / 100.0);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        leading: const Icon(Icons.flight_land, color: Colors.teal),
        title: Text(isThai ? 'ตรวจสอบเงินโอนกลับเข้าไทย (FIFO / เงินต้น / กำไร)' : 'Foreign Remittance Audit (FIFO / Principal / Profit)'),
        subtitle: Text(
          report.remittances.isEmpty
              ? (isThai ? 'ไม่มีการโอนเงินกลับเข้าไทยในปีนี้' : 'No foreign remittances this year')
              : (isThai
                  ? 'นำเข้าสุทธิ ฿$totalRemit (กำไร ฿$taxable / เงินต้นยกเว้น ฿$principal)'
                  : 'Net inward ฿$totalRemit (Profit ฿$taxable / Exempt ฿$principal)'),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
            width: double.infinity,
            child: report.remittances.isEmpty
                ? Text(
                    isThai ? 'ไม่พบรายการโอนเงินกลับเข้าไทยในปีภาษีนี้' : 'No remittances recorded for this tax year',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _buildRemittanceStat('ยอดโอนเงินกลับเข้าไทยรวม:', '฿$totalRemit', isDark),
                            const Divider(height: 12),
                            _buildRemittanceStat('ส่วนที่เป็นเงินต้นเดิม (ยกเว้นภาษี):', '฿$principal', isDark, isGreen: true),
                            const SizedBox(height: 4),
                            _buildRemittanceStat('ส่วนกำไร/ผลตอบแทน (ต้องนำมาคำนวณภาษี):', '฿$taxable', isDark, isOrange: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'รายการโอนเงินกลับเข้าไทย:',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      ...report.remittances.map((remit) {
                        final dateStr = DateFormat('yyyy-MM-dd').format(remit.remittanceDate);
                        final amtStr = _currencyFormat.format(remit.amountThbSatang / 100.0);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(dateStr, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${remit.currency} (${remit.statusLabel})',
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              ),
                              Text(
                                '฿$amtStr',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: remit.isTaxable
                                      ? (isDark ? Colors.orange.shade900.withValues(alpha: 0.4) : Colors.orange.shade100)
                                      : (isDark ? Colors.green.shade900.withValues(alpha: 0.4) : Colors.green.shade100),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  remit.isTaxable ? 'คิดภาษี' : 'เงินต้นยกเว้น',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: remit.isTaxable ? Colors.orange.shade800 : Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemittanceStat(String label, String value, bool isDark, {bool isGreen = false, bool isOrange = false}) {
    Color? valColor;
    if (isGreen) valColor = Colors.green;
    if (isOrange) valColor = isDark ? Colors.orange.shade300 : Colors.orange.shade800;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: valColor,
          ),
        ),
      ],
    );
  }

  String _formatTaxCategory(String? cat) {
    switch (cat) {
      case 'salary_40_1':
        return 'เงินเดือน/โบนัส (40(1))';
      case 'hire_40_2':
        return 'รับจ้าง/ฟรีแลนซ์ (40(2))';
      case 'dividend_40_4a':
        return 'เงินปันผล/ดอกเบี้ย (40(4))';
      case 'capital_gain_foreign':
        return 'กำไรหุ้นต่างประเทศนำเข้าไทย (40(4)(ก))';
      case 'commercial_40_8':
        return 'ธุรกิจ/พาณิชย์/อื่นๆ (40(8))';
      default:
        return cat ?? 'เงินได้ทั่วไป';
    }
  }

  Widget _buildSummaryPill(String label, String value, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, int amountSatang, {bool isBold = false, bool isDeduction = false, Color? textColor}) {
    final amtStr = _currencyFormat.format((amountSatang.abs()) / 100.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
          Text(
            isDeduction ? '- ฿$amtStr' : '฿$amtStr',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
