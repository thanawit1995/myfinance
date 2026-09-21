import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'financial_reports_service.dart';

class ExportPdfService {
  static final _currencyFormat = NumberFormat('#,##0.00', 'en_US');

  static String _formatSatang(int satang) {
    return _currencyFormat.format(satang / 100.0);
  }

  /// Builds the common document theme with embedded Noto Sans Thai fonts.
  static Future<pw.ThemeData> _buildThaiTheme() async {
    final regularFont = await PdfGoogleFonts.notoSansThaiRegular();
    final boldFont = await PdfGoogleFonts.notoSansThaiBold();

    return pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
    );
  }

  /// 1. Export Tax Preparation Bundle to A4 PDF
  static Future<File> exportTaxReportToPdf(TaxPreparationReport report) async {
    final pdf = pw.Document();
    final theme = await _buildThaiTheme();

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(now);
    final beYear = report.taxYear + 543;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.only(bottom: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('MyFinance — สรุปข้อมูลเตรียมยื่นภาษี', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
              pw.Text('พิมพ์เมื่อ: $dateStr', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 12),
          padding: const pw.EdgeInsets.only(top: 6),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.8)),
          ),
          child: pw.Text(
            'หน้า ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          // Title
          pw.Center(
            child: pw.Text(
              'ชุดเอกสารเตรียมยื่นภาษีเงินได้บุคคลธรรมดา (ภ.ง.ด. 90/91)',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
          ),
          pw.Center(
            child: pw.Text(
              'ประจำปีภาษี ค.ศ. ${report.taxYear} (พ.ศ. $beYear) | จำนวนวันในไทย: ${report.daysInThailand} วัน',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
            ),
          ),
          pw.SizedBox(height: 12),

          // Legal Disclaimer Alert Box
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.amber50,
              border: pw.Border.all(color: PdfColors.amber600, width: 0.8),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'คำเตือน: เอกสารนี้เป็นเพียงการรวบรวมข้อมูลและประมาณการภาษีเพื่ออำนวยความสะดวกในการยื่นแบบ ภ.ง.ด. เท่านั้น ไม่ใช่คำแนะนำทางกฎหมายภาษีหรือเอกสารรับรองของทางราชการ ผู้เสียภาษีมีหน้าที่ตรวจสอบความถูกต้องและหลักเกณฑ์ล่าสุดกับกรมสรรพากรก่อนยื่นแบบจริง',
              style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.brown900),
            ),
          ),
          pw.SizedBox(height: 14),

          // Summary Section
          pw.Text('1. สรุปการคำนวณภาษีสุทธิ', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              _buildTableRow('เงินได้พึงประเมินรวม (Gross Income)', '฿${_formatSatang(report.totalGrossIncomeSatang)}', isHeader: false),
              _buildTableRow('หัก: ค่าใช้จ่ายตามกฎหมาย', '฿${_formatSatang(report.totalExpenseDeductionsSatang)}', isHeader: false),
              _buildTableRow('เงินได้หลังหักค่าใช้จ่าย', '฿${_formatSatang(report.totalGrossIncomeSatang - report.totalExpenseDeductionsSatang)}', isHeader: false),
              _buildTableRow('หัก: ค่าลดหย่อนรวม (Allowances)', '฿${_formatSatang(report.totalAllowancesSatang)}', isHeader: false),
              _buildTableRow('เงินได้สุทธิ (Net Taxable Income)', '฿${_formatSatang(report.netTaxableIncomeSatang)}', isHeader: false, isBold: true),
              _buildTableRow('ภาษีคำนวณตามขั้นบันได (Progressive Tax)', '฿${_formatSatang(report.computedTaxSatang)}', isHeader: false),
              _buildTableRow('หัก: ภาษีหัก ณ ที่จ่ายรวม (WHT)', '฿${_formatSatang(report.totalWithholdingTaxSatang)}', isHeader: false),
              _buildTableRow('หัก: เครดิตภาษีเงินปันผล', '฿${_formatSatang(report.totalDividendTaxCreditSatang)}', isHeader: false),
              _buildTableRow(
                report.isRefund ? 'ยอดภาษีที่ขอคืนได้ (Tax Refund)' : 'ยอดภาษีที่ต้องชำระเพิ่มเติม (Tax Due)',
                '฿${_formatSatang(report.netTaxDueSatang.abs())}',
                isHeader: false,
                isBold: true,
                bgColor: report.isRefund ? PdfColors.green50 : PdfColors.red50,
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // Incomes Breakdown
          pw.Text('2. รายละเอียดเงินได้แยกตามหมวดมาตรา 40', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              _buildTableRow('หมวดเงินได้', 'จำนวนเงิน (บาท)', isHeader: true),
              ...report.grossByCategorySatang.entries.map((e) => _buildTableRow(
                    _formatTaxCategory(e.key),
                    '฿${_formatSatang(e.value)}',
                  )),
            ],
          ),
          if (report.incomeTransactions.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text('2.1 รายละเอียดธุรกรรมเงินได้พึงประเมิน (Audit Trail เพื่อสรรพากรตรวจสอบ)', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
            pw.SizedBox(height: 4),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.6),
                1: const pw.FlexColumnWidth(2.0),
                2: const pw.FlexColumnWidth(2.4),
                3: const pw.FlexColumnWidth(1.8),
                4: const pw.FlexColumnWidth(1.6),
              },
              children: [
                _buildTableRow5('วันที่ทำรายการ', 'หมวดเงินได้', 'รายละเอียด (Note)', 'จำนวนเงิน (บาท)', 'หัก ณ ที่จ่าย', isHeader: true),
                ...report.incomeTransactions.map((t) => _buildTableRow5(
                      DateFormat('yyyy-MM-dd').format(t.transactionDate),
                      _formatTaxCategory(t.taxCategory),
                      t.description,
                      '฿${_formatSatang(t.amountThbSatang)}',
                      t.withholdingTaxSatang > 0 ? '฿${_formatSatang(t.withholdingTaxSatang)}' : '-',
                    )),
              ],
            ),
          ],
          pw.SizedBox(height: 14),

          // Progressive Brackets Breakdown
          pw.Text('3. การคำนวณภาษีตามขั้นบันไดอัตราก้าวหน้า (5% - 35%)', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              _buildTableRow4('ขั้นเงินได้สุทธิ (บาท)', 'อัตรา', 'ฐานเงินได้ในขั้น', 'ภาษีในขั้น', isHeader: true),
              ...report.bracketRows.map((b) => _buildTableRow4(
                    b.rangeLabel,
                    '${b.ratePercent.toStringAsFixed(0)}%',
                    '฿${_formatSatang(b.taxableAmountInRangeSatang)}',
                    '฿${_formatSatang(b.taxSatang)}',
                  )),
            ],
          ),
          pw.SizedBox(height: 14),

          // Foreign Remittances
          if (report.remittances.isNotEmpty) ...[
            pw.Text('4. รายการนำเข้าเงินได้จากต่างประเทศ (คำสั่งกรมสรรพากร ป.161/2566 & ป.162/2566)', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            // Summary Strip for Remittance
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
              },
              children: [
                _buildTableRow('ยอดเงินนำเข้าไทยรวมทั้งสิ้น', '฿${_formatSatang(report.totalRemittanceSatang)}', isHeader: false, isBold: true),
                _buildTableRow('ส่วนที่เป็นเงินต้นเดิม (ได้รับยกเว้นภาษี)', '฿${_formatSatang(report.totalRemittancePrincipalSatang)}', isHeader: false),
                _buildTableRow('ส่วนที่เป็นกำไรที่ต้องนำมาคำนวณภาษี', '฿${_formatSatang(report.totalRemittanceTaxableSatang)}', isHeader: false, isBold: true, bgColor: PdfColors.amber50),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(2.0),
                2: const pw.FlexColumnWidth(1.8),
                3: const pw.FlexColumnWidth(1.3),
                4: const pw.FlexColumnWidth(2.2),
              },
              children: [
                _buildTableRow5('วันที่นำเข้า', 'เงินตราต่างประเทศ', 'จำนวนเงิน THB', 'ประเภท', 'สถานะภาษี', isHeader: true),
                ...report.remittances.map((r) => _buildTableRow5(
                      DateFormat('yyyy-MM-dd').format(r.remittanceDate),
                      '${(r.amountOriginalSatang / 100.0).toStringAsFixed(2)} ${r.currency}',
                      '฿${_formatSatang(r.amountThbSatang)}',
                      r.isPrincipal ? 'เงินต้นเดิม' : 'กำไร',
                      r.statusLabel,
                    )),
              ],
            ),
          ],
        ],
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(p.join(tempDir.path, 'MyFinance_Tax_${report.taxYear}_$timestamp.pdf'));
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// 2. Export Monthly Summary to PDF
  static Future<File> exportMonthlySummaryToPdf(MonthlySummaryReport report) async {
    final pdf = pw.Document();
    final theme = await _buildThaiTheme();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        header: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('MyFinance — สรุปรายรับ-รายจ่ายรายเดือน', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.Text('${report.year}-${report.month.toString().padLeft(2, '0')}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          ],
        ),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'รายงานสรุปรายได้และค่าใช้จ่ายประจำเดือน ${report.month}/${report.year}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
          ),
          pw.SizedBox(height: 14),

          // Overview cards
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              _buildTableRow('รายได้รวม', '฿${_formatSatang(report.totalIncomeSatang)}', isHeader: false),
              _buildTableRow('ค่าใช้จ่ายรวม', '฿${_formatSatang(report.totalExpenseSatang)}', isHeader: false),
              _buildTableRow('เงินออมสุทธิ', '฿${_formatSatang(report.netSavingsSatang)}', isHeader: false, isBold: true),
              _buildTableRow('อัตราการออม', '${report.savingsRatePercent.toStringAsFixed(1)}%', isHeader: false),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Text('เปรียบเทียบค่าใช้จ่ายรายหมวดหมู่กับงบประมาณ', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              _buildTableRow5('หมวดหมู่', 'งบประมาณ', 'ใช้จริง', 'ส่วนต่าง', 'สัดส่วนงบ', isHeader: true),
              ...report.categories.map((c) => _buildTableRow5(
                    c.categoryName,
                    '฿${_formatSatang(c.budgetSatang)}',
                    '฿${_formatSatang(c.actualSatang)}',
                    '฿${_formatSatang(c.varianceSatang)}',
                    '${c.percentOfBudget.toStringAsFixed(0)}%',
                  )),
            ],
          ),
        ],
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(p.join(tempDir.path, 'MyFinance_Monthly_${report.year}_${report.month}_$timestamp.pdf'));
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// 3. Export Personal Balance Sheet to PDF
  static Future<File> exportBalanceSheetToPdf(PersonalBalanceSheetReport report) async {
    final pdf = pw.Document();
    final theme = await _buildThaiTheme();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              'งบดุลส่วนบุคคล (Personal Balance Sheet)',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
          ),
          pw.Center(
            child: pw.Text(
              'ณ วันที่ ${report.asOfDate.toIso8601String().substring(0, 10)}',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
            ),
          ),
          pw.SizedBox(height: 14),

          pw.Text('สินทรัพย์ (Assets)', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              _buildTableRow('รายการสินทรัพย์', 'มูลค่า (บาท)', isHeader: true),
              ...report.assetItems.map((a) => _buildTableRow('${a.name} (${a.category})', '฿${_formatSatang(a.valueSatang)}')),
              _buildTableRow('รวมสินทรัพย์ทั้งหมด', '฿${_formatSatang(report.totalAssetsSatang)}', isBold: true),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Text('หนี้สิน (Liabilities)', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              _buildTableRow('รายการหนี้สิน', 'มูลค่า (บาท)', isHeader: true),
              ...report.liabilityItems.map((l) => _buildTableRow('${l.name} (${l.category})', '฿${_formatSatang(l.valueSatang)}')),
              _buildTableRow('รวมหนี้สินทั้งหมด', '฿${_formatSatang(report.totalLiabilitiesSatang)}', isBold: true),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.blue800, width: 1),
            children: [
              _buildTableRow('ความมั่งคั่งสุทธิ (Net Worth)', '฿${_formatSatang(report.netWorthSatang)}', isBold: true, bgColor: PdfColors.blue50),
            ],
          ),
        ],
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(p.join(tempDir.path, 'MyFinance_BalanceSheet_$timestamp.pdf'));
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // --- Helper Table Row Builders ---
  static pw.TableRow _buildTableRow(String col1, String col2, {bool isHeader = false, bool isBold = false, PdfColor? bgColor}) {
    final style = pw.TextStyle(
      fontSize: isHeader ? 10 : 9.5,
      fontWeight: (isHeader || isBold) ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: isHeader ? PdfColors.white : PdfColors.black,
    );

    return pw.TableRow(
      decoration: pw.BoxDecoration(color: bgColor ?? (isHeader ? PdfColors.blue800 : null)),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: pw.Text(col1, style: style),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: pw.Text(col2, style: style, textAlign: pw.TextAlign.right),
        ),
      ],
    );
  }

  static pw.TableRow _buildTableRow4(String c1, String c2, String c3, String c4, {bool isHeader = false}) {
    final style = pw.TextStyle(
      fontSize: isHeader ? 9.5 : 8.5,
      fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: isHeader ? PdfColors.white : PdfColors.black,
    );
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: isHeader ? PdfColors.blue800 : null),
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c1, style: style)),
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c2, style: style, textAlign: pw.TextAlign.center)),
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c3, style: style, textAlign: pw.TextAlign.right)),
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c4, style: style, textAlign: pw.TextAlign.right)),
      ],
    );
  }

  static pw.TableRow _buildTableRow5(String c1, String c2, String c3, String c4, String c5, {bool isHeader = false}) {
    final style = pw.TextStyle(
      fontSize: isHeader ? 9.5 : 8.5,
      fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: isHeader ? PdfColors.white : PdfColors.black,
    );
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: isHeader ? PdfColors.blue800 : null),
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c1, style: style)),
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c2, style: style, textAlign: pw.TextAlign.right)),
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c3, style: style, textAlign: pw.TextAlign.right)),
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c4, style: style, textAlign: pw.TextAlign.right)),
        pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c5, style: style, textAlign: pw.TextAlign.center)),
      ],
    );
  }

  static String _formatTaxCategory(String cat) {
    switch (cat) {
      case '40_1':
        return '40(1) เงินเดือน/โบนัส';
      case '40_2':
        return '40(2) ค่าจ้างทั่วไป/ฟรีแลนซ์';
      case '40_4_interest':
        return '40(4)(ก) ดอกเบี้ย';
      case '40_4_dividend_th':
        return '40(4)(ข) เงินปันผลหุ้นไทย';
      case '40_4_dividend_foreign':
        return '40(4) เงินปันผลต่างประเทศ';
      case '40_4_crypto':
        return '40(4) กำไรจากคริปโต';
      case '40_4_foreign_stock_gain':
        return '40(4) กำไรหุ้นต่างประเทศ';
      case '40_6_medical':
        return '40(6) วิชาชีพเวชกรรม/แพทย์';
      case '40_8':
        return '40(8) ธุรกิจ/พาณิชย์/อื่นๆ';
      case 'foreign_taxable':
        return 'เงินได้ต่างประเทศนำเข้าไทยที่เข้าเกณฑ์';
      default:
        return cat;
    }
  }

  /// Shares an exported PDF file using system share sheet.
  static Future<bool> shareFile(BuildContext context, File file, {String? subject}) async {
    try {
      final xFile = XFile(file.path, mimeType: 'application/pdf');
      final result = await Share.shareXFiles(
        [xFile],
        subject: subject ?? 'MyFinance PDF Report',
      );
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Error sharing pdf: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถแชร์ไฟล์ได้: $e')),
        );
      }
      return false;
    }
  }
}
