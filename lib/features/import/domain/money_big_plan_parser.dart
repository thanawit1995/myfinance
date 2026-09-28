import 'dart:typed_data';
import 'package:excel/excel.dart';

/// Represents a parsed transaction from the Money BIG PLAN Excel workbook.
class ParsedMoneyBigPlanRow {
  final int rowIndex;
  final int year;
  final int month;
  final DateTime date;
  final String workPeriod; // e.g. "2021-05"
  final String originalLabel;
  final String transactionType; // 'income' or 'expense' or 'transfer'
  final String categoryId;
  final String categoryName;
  final String sourceAccountId;
  final String? destinationAccountId;
  final int amountSatang;
  final String? tag;
  final String? taxCategory; // '40_1', '40_2', '40_8'
  final String note;

  const ParsedMoneyBigPlanRow({
    required this.rowIndex,
    required this.year,
    required this.month,
    required this.date,
    required this.workPeriod,
    required this.originalLabel,
    required this.transactionType,
    required this.categoryId,
    required this.categoryName,
    required this.sourceAccountId,
    this.destinationAccountId,
    required this.amountSatang,
    this.tag,
    this.taxCategory,
    required this.note,
  });
}

/// Parses the user's historical "Money BIG PLAN" Excel file (2020 - Aug 2023).
class MoneyBigPlanParser {
  MoneyBigPlanParser._();

  static const String scbAccountId = '00000000-0000-4000-8000-000000000001';

  // Standard category IDs from seed_data.dart
  static const String catSalary = 'cat-inc-0000-4000-8000-000000000001';
  static const String catShiftDuty = 'cat-inc-0000-4000-8000-000000000002';
  static const String catOtherIncome = 'cat-inc-0000-4000-8000-000000000005';

  static const String catHousing = 'cat-exp-0000-4000-8000-000000000002';
  static const String catTransportation = 'cat-exp-0000-4000-8000-000000000003';
  static const String catUtilities = 'cat-exp-0000-4000-8000-000000000004';
  static const String catEntertainment = 'cat-exp-0000-4000-8000-000000000007';
  static const String catFinancialFees = 'cat-exp-0000-4000-8000-000000000009';
  static const String catOtherExpense = 'cat-exp-0000-4000-8000-000000000010';
  static const String catGifts = 'cat-exp-0000-4000-8000-000000000011';
  static const String catGpf = 'cat-exp-0000-4000-8000-000000000014';
  static const String catInsurance = 'cat-exp-0000-4000-8000-000000000015';

  static const Map<String, int> _monthNames = {
    'january': 1, 'jan': 1, 'มกราคม': 1, 'ม.ค.': 1,
    'february': 2, 'feb': 2, 'กุมภาพันธ์': 2, 'ก.พ.': 2,
    'march': 3, 'mar': 3, 'มีนาคม': 3, 'มี.ค.': 3,
    'april': 4, 'apr': 4, 'เมษายน': 4, 'เม.ย.': 4,
    'may': 5, 'พฤษภาคม': 5, 'พ.ค.': 5,
    'june': 6, 'jun': 6, 'มิถุนายน': 6, 'มิ.ย.': 6,
    'july': 7, 'jul': 7, 'กรกฎาคม': 7, 'ก.ค.': 7,
    'august': 8, 'aug': 8, 'สิงหาคม': 8, 'ส.ค.': 8,
    'september': 9, 'sep': 9, 'กันยายน': 9, 'ก.ย.': 9,
    'october': 10, 'oct': 10, 'ตุลาคม': 10, 'ต.ค.': 10,
    'november': 11, 'nov': 11, 'พฤศจิกายน': 11, 'พ.ย.': 11,
    'december': 12, 'dec': 12, 'ธันวาคม': 12, 'ธ.ค.': 12,
  };

  /// Decodes Excel bytes and parses all rows from sheets '2020', '2021', '2022', and '2023'.
  /// For 2023, stops at August (months 1-8).
  static List<ParsedMoneyBigPlanRow> parseBytes(Uint8List bytes) => parseExcelBytes(bytes);

  static List<ParsedMoneyBigPlanRow> parseExcelBytes(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final results = <ParsedMoneyBigPlanRow>[];
    int globalRowIndex = 0;

    for (final yearStr in ['2020', '2021', '2022', '2023']) {
      final sheet = excel.tables[yearStr];
      if (sheet == null) continue;
      final year = int.tryParse(yearStr) ?? 0;
      if (year == 0) continue;

      // Find month columns in Row 0 or 1
      final monthColMap = <int, int>{}; // colIndex -> monthNumber (1-12)
      for (int r = 0; r < 2 && r < sheet.maxRows; r++) {
        final row = sheet.rows[r];
        for (int c = 0; c < row.length; c++) {
          final val = row[c]?.value?.toString().trim().toLowerCase() ?? '';
          if (_monthNames.containsKey(val)) {
            monthColMap[c] = _monthNames[val]!;
          }
        }
        if (monthColMap.isNotEmpty) break;
      }

      if (monthColMap.isEmpty) continue;

      String currentSection = ''; // 'income' or 'expense'

      for (int r = 0; r < sheet.maxRows; r++) {
        final row = sheet.rows[r];
        if (row.isEmpty) continue;

        final c0 = row.isNotEmpty ? row[0]?.value?.toString().trim() ?? '' : '';
        final c1 = row.length > 1 ? row[1]?.value?.toString().trim() ?? '' : '';

        // Section header detection
        if (c0.contains('รายรับ')) {
          currentSection = 'income';
          continue;
        } else if (c0.contains('รายจ่าย')) {
          currentSection = 'expense';
          continue;
        }

        // Skip rows that are totals, plans, or estimations
        if (c0.contains('รวม') || c0.contains('PLAN') || c0.contains('คงเหลือ') ||
            c0.contains('ประมาณ') || c0.startsWith('*')) {
          continue;
        }
        if (c1.contains('รวม') || c1.contains('PLAN') || c1.contains('คงเหลือ') ||
            c1.contains('ประมาณ') || c1.startsWith('*')) {
          continue;
        }

        final combinedLabel = '${c0.isNotEmpty ? c0 : ''} ${c1.isNotEmpty ? c1 : ''}'.trim();
        if (combinedLabel.isEmpty) continue;

        // Skip investment rows (handled by Notion)
        if (_isInvestmentRow(combinedLabel)) {
          continue;
        }

        // Map category
        final categoryMapping = _mapCategory(combinedLabel, currentSection);
        if (categoryMapping == null) continue;

        // Extract amounts across month columns
        for (final entry in monthColMap.entries) {
          final colIdx = entry.key;
          final month = entry.value;

          // For 2023, stop before September (Jan-Aug only)
          if (year == 2023 && month > 8) continue;
          // For 2020, data starts from June
          if (year == 2020 && month < 6) continue;

          if (colIdx >= row.length) continue;
          final cellVal = row[colIdx]?.value?.toString().trim() ?? '';
          if (cellVal.isEmpty || cellVal == '-' || cellVal == '0') continue;

          final satang = evaluateExpressionToSatang(cellVal);
          if (satang <= 0) continue;

          final lastDay = _getLastDayOfMonth(year, month);
          final workPeriod = '$year-${month.toString().padLeft(2, '0')}';

          results.add(ParsedMoneyBigPlanRow(
            rowIndex: globalRowIndex++,
            year: year,
            month: month,
            date: DateTime(year, month, lastDay),
            workPeriod: workPeriod,
            originalLabel: combinedLabel,
            transactionType: categoryMapping.type,
            categoryId: categoryMapping.id,
            categoryName: categoryMapping.name,
            sourceAccountId: scbAccountId,
            amountSatang: satang,
            tag: categoryMapping.tag,
            taxCategory: categoryMapping.taxCategory,
            note: 'Money BIG PLAN: $combinedLabel ($workPeriod)',
          ));
        }
      }
    }

    return results;
  }

  /// Evaluates arithmetic strings like "17442+3077", "24000+1312.5+6000", "16000-15000", "20520"
  /// into integer satang. Returns 0 if invalid or formula contains cell references.
  static int evaluateExpressionToSatang(String raw) {
    var cleaned = raw.trim()
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('฿', '')
        .replaceAll(r'$', '');

    if (cleaned.startsWith('=')) {
      cleaned = cleaned.substring(1);
    }

    // Ignore formulas referencing cells (e.g. SUM(C3:C7), C35+D32, 0.15*C3)
    if (RegExp(r'[A-Za-z]').hasMatch(cleaned)) {
      return 0;
    }

    try {
      // Split into additions and subtractions
      // E.g. "17442+3078" or "16000-15000"
      final regex = RegExp(r'([+-]?[0-9]*\.?[0-9]+)');
      final matches = regex.allMatches(cleaned);
      if (matches.isEmpty) return 0;

      double total = 0.0;
      for (final m in matches) {
        final token = m.group(0);
        if (token != null && token.isNotEmpty) {
          final val = double.tryParse(token) ?? 0.0;
          total += val;
        }
      }

      if (total <= 0) return 0;
      return (total * 100.0).round();
    } catch (_) {
      return 0;
    }
  }

  static bool _isInvestmentRow(String label) {
    final lower = label.toLowerCase();
    return lower.contains('กองทุน') ||
        lower.contains('หุ้น') ||
        lower.contains('crypto') ||
        lower.contains('ssf') ||
        lower.contains('rmf') ||
        lower.contains('เงินออม') ||
        lower.contains('เงินเก็บฉุกเฉิน') ||
        lower.contains('ลงทุนเพิ่มเติม');
  }

  static ({String id, String name, String type, String? tag, String? taxCategory})? _mapCategory(
      String label, String section) {
    final lower = label.toLowerCase();

    // ─── INCOMES ────────────────────────────────────────────────────────────
    if (section == 'income' || lower.contains('เงินเดือน') || lower.contains('พตส') || lower.contains('เวร')) {
      if (lower.contains('เงินเดือน')) {
        return (
          id: catSalary,
          name: 'เงินเดือน',
          type: 'income',
          tag: 'historical_summary',
          taxCategory: '40_1',
        );
      }
      if (lower.contains('พตส') || lower.contains('p4p') || lower.contains('ฉ.11') ||
          lower.contains('ไม่ทำเวช') || lower.contains('ค่าเวร') || lower.contains('เวร')) {
        return (
          id: catShiftDuty,
          name: 'รับจ้าง / ค่าอยู่เวร',
          type: 'income',
          tag: 'historical_summary',
          taxCategory: '40_2',
        );
      }
      return (
        id: catOtherIncome,
        name: 'รายรับอื่นๆ',
        type: 'income',
        tag: 'historical_summary',
        taxCategory: '40_8',
      );
    }

    // ─── EXPENSES ───────────────────────────────────────────────────────────
    if (lower.contains('กบข')) {
      return (
        id: catGpf,
        name: 'เงินสะสม กบข.',
        type: 'expense',
        tag: 'deduction:gpf',
        taxCategory: null,
      );
    }

    if (lower.contains('พ่อแม่') || lower.contains('pp')) {
      return (
        id: catGifts,
        name: 'ของขวัญ / ของฝาก',
        type: 'expense',
        tag: 'historical_summary',
        taxCategory: null,
      );
    }

    if (lower.contains('ไฟ') || lower.contains('น้ำ') || lower.contains('coway') ||
        lower.contains('มือถือ') || lower.contains('อินเทอร์เน็ต')) {
      return (
        id: catUtilities,
        name: 'สาธารณูปโภค',
        type: 'expense',
        tag: 'historical_summary',
        taxCategory: null,
      );
    }

    if (lower.contains('ซักผ้า') || lower.contains('แฟลต') || lower.contains('แอร์') || lower.contains('ที่พัก')) {
      return (
        id: catHousing,
        name: 'ที่อยู่อาศัย',
        type: 'expense',
        tag: 'historical_summary',
        taxCategory: null,
      );
    }

    if (lower.contains('น้ำมัน') || lower.contains('บำรุงรถ') || lower.contains('ประกันรถ')) {
      return (
        id: catTransportation,
        name: 'การเดินทาง',
        type: 'expense',
        tag: 'historical_summary',
        taxCategory: null,
      );
    }

    if (lower.contains('spotify') || lower.contains('netflix')) {
      return (
        id: catEntertainment,
        name: 'บันเทิงและการพักผ่อน',
        type: 'expense',
        tag: 'historical_summary',
        taxCategory: null,
      );
    }

    if (lower.contains('ภาษี')) {
      return (
        id: catFinancialFees,
        name: 'ค่าธรรมเนียมและการเงิน',
        type: 'expense',
        tag: 'historical_summary',
        taxCategory: null,
      );
    }

    // Insurance transactions are intentionally excluded from Money BIG PLAN import.
    // The user has already recorded all insurance payments via Notion Bills import,
    // which is the canonical source for insurance data. Returning null causes the
    // parser to skip these rows entirely.
    if (lower.contains('ประกันชีวิต') || lower.contains('i-shield') || lower.contains('ประกันออมทรัพย์')) {
      return null;
    }

    // Default for personal expenses
    return (
      id: catOtherExpense,
      name: 'ค่าใช้จ่ายอื่นๆ',
      type: 'expense',
      tag: 'historical_summary',
      taxCategory: null,
    );
  }

  static int _getLastDayOfMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 0).day;
    }
    return DateTime(year, month + 1, 0).day;
  }
}
