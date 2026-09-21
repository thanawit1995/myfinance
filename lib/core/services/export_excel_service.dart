import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'financial_reports_service.dart';

class ExportExcelService {
  /// Exports all financial reports into a single multi-sheet Excel workbook.
  static Future<File> exportComprehensiveReport({
    MonthlySummaryReport? monthly,
    AnnualSummaryReport? annual,
    CashFlowStatementReport? cashFlow,
    PersonalBalanceSheetReport? balanceSheet,
    InvestmentPortfolioReport? portfolio,
    TaxPreparationReport? taxReport,
  }) async {
    final excel = Excel.createExcel();
    // Excel starts with a default sheet called Sheet1, which we can delete or rename
    const defaultSheet = 'Sheet1';

    // 1. Monthly Sheet
    if (monthly != null) {
      final sheet = excel['สรุปรายเดือน'];
      sheet.appendRow([
        TextCellValue('รายงานสรุปรายได้และค่าใช้จ่ายประจำเดือน'),
        TextCellValue('${monthly.year}-${monthly.month.toString().padLeft(2, '0')}'),
      ]);
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('รายการสรุปภาพรวม'),
        TextCellValue('จำนวนเงิน (บาท)'),
      ]);
      sheet.appendRow([
        TextCellValue('รายได้รวม'),
        DoubleCellValue(monthly.totalIncomeSatang / 100.0),
      ]);
      sheet.appendRow([
        TextCellValue('ค่าใช้จ่ายรวม'),
        DoubleCellValue(monthly.totalExpenseSatang / 100.0),
      ]);
      sheet.appendRow([
        TextCellValue('เงินออมสุทธิ'),
        DoubleCellValue(monthly.netSavingsSatang / 100.0),
      ]);
      sheet.appendRow([
        TextCellValue('อัตราการออม (%)'),
        DoubleCellValue(monthly.savingsRatePercent),
      ]);
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('หมวดหมู่ค่าใช้จ่าย'),
        TextCellValue('งบประมาณ (บาท)'),
        TextCellValue('ใช้จ่ายจริง (บาท)'),
        TextCellValue('ส่วนต่าง (บาท)'),
        TextCellValue('สัดส่วนงบ (%)'),
      ]);
      for (final cat in monthly.categories) {
        sheet.appendRow([
          TextCellValue(cat.categoryName),
          DoubleCellValue(cat.budgetSatang / 100.0),
          DoubleCellValue(cat.actualSatang / 100.0),
          DoubleCellValue(cat.varianceSatang / 100.0),
          DoubleCellValue(cat.percentOfBudget),
        ]);
      }
    }

    // 2. Annual Sheet
    if (annual != null) {
      final sheet = excel['สรุปรายปี'];
      sheet.appendRow([
        TextCellValue('รายงานสรุปรายรับ-รายจ่าย 12 เดือน ประจำปี'),
        IntCellValue(annual.year),
      ]);
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('เดือน'),
        TextCellValue('รายได้ (บาท)'),
        TextCellValue('รายจ่าย (บาท)'),
        TextCellValue('สุทธิ (บาท)'),
      ]);
      for (final m in annual.months) {
        sheet.appendRow([
          TextCellValue('เดือนที่ ${m.month}'),
          DoubleCellValue(m.incomeSatang / 100.0),
          DoubleCellValue(m.expenseSatang / 100.0),
          DoubleCellValue(m.netSatang / 100.0),
        ]);
      }
      sheet.appendRow([
        TextCellValue('รวมทั้งปี'),
        DoubleCellValue(annual.totalIncomeSatang / 100.0),
        DoubleCellValue(annual.totalExpenseSatang / 100.0),
        DoubleCellValue(annual.netSavingsSatang / 100.0),
      ]);
    }

    // 3. Cash Flow Sheet
    if (cashFlow != null) {
      final sheet = excel['งบกระแสเงินสด'];
      sheet.appendRow([
        TextCellValue('งบกระแสเงินสด (Cash Flow Statement)'),
        TextCellValue('${cashFlow.startDate.toIso8601String().substring(0, 10)} ถึง ${cashFlow.endDate.toIso8601String().substring(0, 10)}'),
      ]);
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('กิจกรรมดำเนินงาน (Operating Activities)'),
        TextCellValue('จำนวนเงิน (บาท)'),
      ]);
      for (final item in cashFlow.operatingItems) {
        sheet.appendRow([
          TextCellValue(item.label),
          DoubleCellValue((item.isInflow ? item.amountSatang : -item.amountSatang) / 100.0),
        ]);
      }
      sheet.appendRow([
        TextCellValue('กระแสเงินสดสุทธิจากกิจกรรมดำเนินงาน'),
        DoubleCellValue(cashFlow.netOperatingSatang / 100.0),
      ]);

      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('กิจกรรมลงทุน (Investing Activities)'),
        TextCellValue('จำนวนเงิน (บาท)'),
      ]);
      for (final item in cashFlow.investingItems) {
        sheet.appendRow([
          TextCellValue(item.label),
          DoubleCellValue((item.isInflow ? item.amountSatang : -item.amountSatang) / 100.0),
        ]);
      }
      sheet.appendRow([
        TextCellValue('กระแสเงินสดสุทธิจากกิจกรรมลงทุน'),
        DoubleCellValue(cashFlow.netInvestingSatang / 100.0),
      ]);

      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('กิจกรรมจัดหาเงิน (Financing Activities)'),
        TextCellValue('จำนวนเงิน (บาท)'),
      ]);
      for (final item in cashFlow.financingItems) {
        sheet.appendRow([
          TextCellValue(item.label),
          DoubleCellValue((item.isInflow ? item.amountSatang : -item.amountSatang) / 100.0),
        ]);
      }
      sheet.appendRow([
        TextCellValue('กระแสเงินสดสุทธิจากกิจกรรมจัดหาเงิน'),
        DoubleCellValue(cashFlow.netFinancingSatang / 100.0),
      ]);
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('กระแสเงินสดสุทธิรวมทุกกิจกรรม'),
        DoubleCellValue(cashFlow.netCashFlowSatang / 100.0),
      ]);
    }

    // 4. Balance Sheet
    if (balanceSheet != null) {
      final sheet = excel['งบดุลส่วนบุคคล'];
      sheet.appendRow([
        TextCellValue('งบดุลส่วนบุคคล (Personal Balance Sheet)'),
        TextCellValue('ณ วันที่ ${balanceSheet.asOfDate.toIso8601String().substring(0, 10)}'),
      ]);
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('สินทรัพย์ (Assets)'),
        TextCellValue('ประเภท'),
        TextCellValue('มูลค่า (บาท)'),
      ]);
      for (final a in balanceSheet.assetItems) {
        sheet.appendRow([
          TextCellValue(a.name),
          TextCellValue(a.category),
          DoubleCellValue(a.valueSatang / 100.0),
        ]);
      }
      sheet.appendRow([
        TextCellValue('รวมสินทรัพย์ทั้งหมด'),
        TextCellValue(''),
        DoubleCellValue(balanceSheet.totalAssetsSatang / 100.0),
      ]);

      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('หนี้สิน (Liabilities)'),
        TextCellValue('ประเภท'),
        TextCellValue('มูลค่า (บาท)'),
      ]);
      for (final l in balanceSheet.liabilityItems) {
        sheet.appendRow([
          TextCellValue(l.name),
          TextCellValue(l.category),
          DoubleCellValue(l.valueSatang / 100.0),
        ]);
      }
      sheet.appendRow([
        TextCellValue('รวมหนี้สินทั้งหมด'),
        TextCellValue(''),
        DoubleCellValue(balanceSheet.totalLiabilitiesSatang / 100.0),
      ]);

      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('ความมั่งคั่งสุทธิ (Net Worth)'),
        TextCellValue('สินทรัพย์ - หนี้สิน'),
        DoubleCellValue(balanceSheet.netWorthSatang / 100.0),
      ]);
    }

    // 5. Portfolio Sheet
    if (portfolio != null) {
      final sheet = excel['พอร์ตการลงทุน'];
      sheet.appendRow([
        TextCellValue('รายงานพอร์ตการลงทุน (Investment Portfolio Report)'),
      ]);
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('สัญลักษณ์'),
        TextCellValue('ชื่อสินทรัพย์'),
        TextCellValue('ประเภท'),
        TextCellValue('จำนวนหน่วย'),
        TextCellValue('ต้นทุนรวม (บาท)'),
        TextCellValue('มูลค่าตลาด (บาท)'),
        TextCellValue('กำไร/ขาดทุนที่ยังไม่เกิดขึ้น (บาท)'),
        TextCellValue('ผลตอบแทน (%)'),
      ]);
      for (final h in portfolio.holdings) {
        sheet.appendRow([
          TextCellValue(h.symbol),
          TextCellValue(h.name),
          TextCellValue(h.assetType),
          DoubleCellValue(double.tryParse(h.units.toString()) ?? 0.0),
          DoubleCellValue(h.costSatang / 100.0),
          DoubleCellValue(h.marketValueSatang / 100.0),
          DoubleCellValue(h.unrealizedGainLossSatang / 100.0),
          DoubleCellValue(h.returnPercent),
        ]);
      }
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('รวมทั้งพอร์ต'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        DoubleCellValue(portfolio.totalCostSatang / 100.0),
        DoubleCellValue(portfolio.totalMarketValueSatang / 100.0),
        DoubleCellValue(portfolio.unrealizedGainLossSatang / 100.0),
        DoubleCellValue(portfolio.unrealizedReturnPercent),
      ]);
      sheet.appendRow([
        TextCellValue('กำไรที่รับรู้แล้วจากการขาย (Realized Gain/Loss)'),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        TextCellValue(''),
        DoubleCellValue(portfolio.realizedGainLossSatang / 100.0),
      ]);
    }

    // 6. Tax Preparation Sheet
    if (taxReport != null) {
      final sheet = excel['เตรียมยื่นภาษี'];
      sheet.appendRow([
        TextCellValue('ชุดเอกสารเตรียมยื่นภาษีเงินได้บุคคลธรรมดา ปีภาษี'),
        IntCellValue(taxReport.taxYear),
      ]);
      sheet.appendRow([
        TextCellValue('* รายงานนี้เป็นการประมาณการเพื่อเตรียมเอกสาร ไม่ใช่คำแนะนำทางภาษีหรือเอกสารทางราชการ'),
      ]);
      sheet.appendRow([]);
      sheet.appendRow([
        TextCellValue('ประเภทเงินได้พึงประเมิน'),
        TextCellValue('จำนวนเงินได้ (บาท)'),
      ]);
      for (final entry in taxReport.grossByCategorySatang.entries) {
        sheet.appendRow([
          TextCellValue(_formatTaxCategory(entry.key)),
          DoubleCellValue(entry.value / 100.0),
        ]);
      }
      sheet.appendRow([
        TextCellValue('เงินได้พึงประเมินรวม'),
        DoubleCellValue(taxReport.totalGrossIncomeSatang / 100.0),
      ]);
      sheet.appendRow([
        TextCellValue('หักค่าใช้จ่ายตามกฎหมาย'),
        DoubleCellValue(taxReport.totalExpenseDeductionsSatang / 100.0),
      ]);
      sheet.appendRow([
        TextCellValue('หักค่าลดหย่อนรวม'),
        DoubleCellValue(taxReport.totalAllowancesSatang / 100.0),
      ]);
      sheet.appendRow([
        TextCellValue('เงินได้สุทธิ'),
        DoubleCellValue(taxReport.netTaxableIncomeSatang / 100.0),
      ]);
      sheet.appendRow([
        TextCellValue('ภาษีคำนวณตามขั้นบันได'),
        DoubleCellValue(taxReport.computedTaxSatang / 100.0),
      ]);
      sheet.appendRow([
        TextCellValue('หักภาษี ณ ที่จ่าย (WHT)'),
        DoubleCellValue(taxReport.totalWithholdingTaxSatang / 100.0),
      ]);
      sheet.appendRow([
        TextCellValue('หักเครดิตภาษีเงินปันผล'),
        DoubleCellValue(taxReport.totalDividendTaxCreditSatang / 100.0),
      ]);
      sheet.appendRow([
        TextCellValue(taxReport.isRefund ? 'ยอดภาษีที่ขอคืนได้' : 'ยอดภาษีที่ต้องชำระเพิ่ม'),
        DoubleCellValue(taxReport.netTaxDueSatang.abs() / 100.0),
      ]);

      if (taxReport.remittances.isNotEmpty) {
        sheet.appendRow([]);
        sheet.appendRow([
          TextCellValue('รายการเงินได้ต่างประเทศที่นำเข้าไทย'),
        ]);
        sheet.appendRow([
          TextCellValue('วันที่นำเข้า'),
          TextCellValue('จากบัญชี'),
          TextCellValue('เข้าบัญชี'),
          TextCellValue('เงินตราต่างประเทศ'),
          TextCellValue('อัตราแลกเปลี่ยน'),
          TextCellValue('จำนวนเงิน THB'),
          TextCellValue('ปีภาษีที่เกิดเงินได้'),
          TextCellValue('เป็นเงินต้น'),
          TextCellValue('สถานะการเสียภาษี'),
        ]);
        for (final r in taxReport.remittances) {
          sheet.appendRow([
            TextCellValue(r.remittanceDate.toIso8601String().substring(0, 10)),
            TextCellValue(r.sourceAccountName),
            TextCellValue(r.destinationAccountName),
            DoubleCellValue(r.amountOriginalSatang / 100.0),
            DoubleCellValue(double.tryParse(r.fxRate.toString()) ?? 1.0),
            DoubleCellValue(r.amountThbSatang / 100.0),
            r.taxYearEarned != null ? IntCellValue(r.taxYearEarned!) : TextCellValue('-'),
            TextCellValue(r.isPrincipal ? 'ใช่' : 'ไม่ใช่'),
            TextCellValue(r.statusLabel),
          ]);
        }
      }
    }

    // Remove default Sheet1 if other sheets exist
    if (excel.sheets.length > 1 && excel.sheets.containsKey(defaultSheet)) {
      excel.delete(defaultSheet);
    }

    final bytes = excel.save();
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File(p.join(tempDir.path, 'MyFinance_Report_$timestamp.xlsx'));
    await file.writeAsBytes(bytes!);
    return file;
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
        return '40(4) กำไรจากคริปโตเคอร์เรนซี';
      case '40_4_foreign_stock_gain':
        return '40(4) กำไรจากหุ้นต่างประเทศ';
      case '40_6_medical':
        return '40(6) วิชาชีพอิสระ (แพทย์/การประกอบโรคศิลปะ)';
      case '40_8':
        return '40(8) ธุรกิจ/พาณิชย์/อื่นๆ';
      case 'foreign_taxable':
        return 'เงินได้ต่างประเทศนำเข้าไทยที่เข้าเกณฑ์';
      default:
        return cat;
    }
  }

  /// Shares an exported Excel file using system share sheet.
  static Future<bool> shareFile(BuildContext context, File file, {String? subject}) async {
    try {
      final xFile = XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final result = await Share.shareXFiles(
        [xFile],
        subject: subject ?? 'MyFinance Report',
      );
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Error sharing excel: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถแชร์ไฟล์ได้: $e')),
        );
      }
      return false;
    }
  }
}
