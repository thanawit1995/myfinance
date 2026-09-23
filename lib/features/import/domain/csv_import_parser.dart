import 'package:csv/csv.dart';
import 'package:decimal/decimal.dart';
import 'csv_import_models.dart';
import 'notion_category_mapper.dart';

class CsvImportParser {
  static const Map<String, int> monthNames = {
    'jan': 1, 'january': 1, 'ม.ค.': 1, 'มกราคม': 1,
    'feb': 2, 'february': 2, 'ก.พ.': 2, 'กุมภาพันธ์': 2,
    'mar': 3, 'march': 3, 'มี.ค.': 3, 'มีนาคม': 3,
    'apr': 4, 'april': 4, 'เม.ย.': 4, 'เมษายน': 4,
    'may': 5, 'พ.ค.': 5, 'พฤษภาคม': 5,
    'jun': 6, 'june': 6, 'มิ.ย.': 6, 'มิถุนายน': 6,
    'jul': 7, 'july': 7, 'ก.ค.': 7, 'กรกฎาคม': 7,
    'aug': 8, 'august': 8, 'ส.ค.': 8, 'สิงหาคม': 8,
    'sep': 9, 'september': 9, 'sept': 9, 'ก.ย.': 9, 'กันยายน': 9,
    'oct': 10, 'october': 10, 'ต.ค.': 10, 'ตุลาคม': 10,
    'nov': 11, 'november': 11, 'พ.ย.': 11, 'พฤศจิกายน': 11,
    'dec': 12, 'december': 12, 'ธ.ค.': 12, 'ธันวาคม': 12,
  };

  static int _resolveMonth(String rawMonth) {
    final m = rawMonth.trim().toLowerCase().replaceAll('.', '');
    for (final entry in monthNames.entries) {
      final key = entry.key.replaceAll('.', '');
      if (m == key || m.startsWith(key)) {
        return entry.value;
      }
    }
    return 1;
  }

  /// Parses CSV raw text into rows of dynamic values.
  static List<List<dynamic>> parseRawCsv(String csvContent) {
    final normalized = csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final converter = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
      allowInvalid: true,
    );
    return converter.convert(normalized);
  }

  /// Automatically guesses column mapping from CSV header row.
  static CsvColumnMapping? detectMapping(List<String> headers, {String template = 'auto'}) {
    int dateCol = -1;
    int nameCol = -1;
    int categoryCol = -1;
    int amountCol = -1;
    int? accountCol;
    int? noteCol;
    int? taxTypeCol;
    int? whtCol;
    int? budgetCol;
    int? propertyCol;
    int? periodCol;

    for (int i = 0; i < headers.length; i++) {
      final h = headers[i].trim().toLowerCase();
      if (h.contains('date') || h.contains('วันที่') || h.contains('time') || h == 'd') {
        if (dateCol == -1) dateCol = i;
      } else if (h.contains('name') || h.contains('รายการ') || h.contains('description') || h.contains('title') || h == 'item' || h == 'income' || h == 'expense') {
        if (nameCol == -1) nameCol = i;
      } else if (h.contains('category') || h.contains('หมวดหมู่') || h.contains('cat') || h.contains('ประเภท')) {
        if (categoryCol == -1) categoryCol = i;
      } else if (h == 'amount' || h == 'จำนวนเงิน' || h == 'ยอด' || h == 'price' || h == 'thb' || h.contains('actual')) {
        amountCol = i;
      } else if (h.contains('budget') || h.contains('ประมาณการ') || h.contains('คาดการณ์')) {
        budgetCol = i;
      } else if (h.contains('property') || h.contains('สถานะ') || h.contains('status') || h == 'paid') {
        propertyCol = i;
      } else if (h.contains('monthly overview') || h.contains('overview') || h.contains('period') || h.contains('รอบเดือน') || h.contains('cycle')) {
        periodCol = i;
      } else if (h.contains('wallet') || h.contains('account') || h.contains('บัญชี') || h.contains('กระเป๋า')) {
        accountCol = i;
      } else if (h.contains('note') || h.contains('หมายเหตุ') || h.contains('memo') || h.contains('remark') || h == 'type') {
        noteCol = i;
      } else if (h.contains('tax') || h.contains('ภาษี') || h.contains('มาตรา')) {
        taxTypeCol = i;
      } else if (h.contains('wht') || h.contains('หัก ณ ที่จ่าย') || h.contains('withholding')) {
        whtCol = i;
      } else if (amountCol == -1 && (h.contains('amount') || h.contains('ยอดเงิน'))) {
        amountCol = i;
      }
    }

    // Specific template override for Notion Income
    if (template == 'notion_income') {
      for (int i = 0; i < headers.length; i++) {
        final h = headers[i].trim().toLowerCase();
        if (h == 'date') dateCol = i;
        if (h == 'income') nameCol = i;
        if (h == 'category') categoryCol = i;
        if (h == 'budget') budgetCol = i;
        if (h == 'amount') amountCol = i;
        if (h == 'property') propertyCol = i;
        if (h.contains('monthly overview')) periodCol = i;
        if (h == 'type') noteCol = i;
      }
    }

    // Fallbacks if not cleanly matched
    if (dateCol == -1 && headers.isNotEmpty) dateCol = 0;
    if (nameCol == -1 && headers.length > 1) nameCol = 1;
    if (amountCol == -1 && budgetCol != null) {
      amountCol = budgetCol;
    }
    if (amountCol == -1) {
      for (int i = headers.length - 1; i >= 0; i--) {
        if (i != dateCol && i != nameCol && i != categoryCol) {
          amountCol = i;
          break;
        }
      }
    }
    if (categoryCol == -1) {
      for (int i = 0; i < headers.length; i++) {
        if (i != dateCol && i != nameCol && i != amountCol) {
          categoryCol = i;
          break;
        }
      }
    }

    if (dateCol != -1 && nameCol != -1 && categoryCol != -1 && amountCol != -1) {
      return CsvColumnMapping(
        dateCol: dateCol,
        nameCol: nameCol,
        categoryCol: categoryCol,
        amountCol: amountCol,
        accountCol: accountCol,
        noteCol: noteCol,
        taxTypeCol: taxTypeCol,
        whtCol: whtCol,
        budgetCol: budgetCol,
        propertyCol: propertyCol,
        periodCol: periodCol,
      );
    }
    return null;
  }

  /// Cleans Notion relations format: "Eating_OCT23 (https://...)" -> "Eating"
  static String cleanNotionRelation(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return s;

    // Strip URL in parenthesis: "Eating_OCT23 (https://...)" -> "Eating_OCT23"
    final parenIndex = s.indexOf('(');
    if (parenIndex != -1) {
      s = s.substring(0, parenIndex).trim();
    }

    // Strip month suffix like "_OCT23", "_SEP23", "_2023"
    final underscoreIdx = s.indexOf('_');
    if (underscoreIdx != -1) {
      s = s.substring(0, underscoreIdx).trim();
    }

    // Strip leading emojis and symbols (e.g. "🍴Eating" -> "Eating", "❤️Lover" -> "Lover")
    // Keep Thai, English letters, digits, spaces, &, -, /
    final cleanRegex = RegExp(r'^[^a-zA-Z0-9\u0E00-\u0E7F]+');
    s = s.replaceFirst(cleanRegex, '').trim();

    return s;
  }

  /// Parses Notion work period like "December 25 (https://...)" or "July 26" into "2025-12" or "2026-07"
  static String? parseNotionWorkPeriod(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var s = raw.trim();
    final parenIndex = s.indexOf('(');
    if (parenIndex != -1) {
      s = s.substring(0, parenIndex).trim();
    }

    // Pattern 1: ISO like '2026-07' or '2026/07'
    final isoMatch = RegExp(r'^(\d{4})[-/](\d{1,2})$').firstMatch(s);
    if (isoMatch != null) {
      final y = isoMatch.group(1)!;
      final m = int.parse(isoMatch.group(2)!).toString().padLeft(2, '0');
      return '$y-$m';
    }

    // Pattern 2: Month Name + Year e.g. "December 25" or "July 26" or "ธันวาคม 25"
    final match = RegExp(r'([A-Za-zก-๙\.]+)\s*(\d{2,4})').firstMatch(s);
    if (match != null) {
      final rawMonth = match.group(1)!;
      var rawYear = int.tryParse(match.group(2)!) ?? 2026;
      if (rawYear < 100) {
        rawYear += 2000;
      } else if (rawYear > 2500) {
        rawYear -= 543; // พ.ศ. -> ค.ศ.
      }
      final month = _resolveMonth(rawMonth);
      return '${rawYear.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    }

    return null;
  }

  /// Detects whether this row is a total/summary row (e.g. "รวมทั้งเดือน ก.ย.", "Total")
  static bool isSummaryRow(String name, String category) {
    final lowerName = name.trim().toLowerCase();
    final lowerCat = category.trim().toLowerCase();

    if (lowerName.startsWith('รวม') ||
        lowerName.contains('รวมทั้งเดือน') ||
        lowerName.startsWith('total') ||
        lowerName.startsWith('summary') ||
        lowerName.startsWith('ยอดรวม')) {
      return true;
    }
    if (lowerCat.startsWith('รวม') || lowerCat.startsWith('total')) {
      return true;
    }
    return false;
  }

  /// Parses monetary amounts in THB / number strings into integer satang.
  /// Handles "THB 22,830.00", "฿ 1,500.50", "(500.00)", "-100"
  static int parseAmountSatang(dynamic raw) {
    if (raw == null) return 0;
    if (raw is num) {
      return (raw * 100).round();
    }

    String s = raw.toString().trim();
    if (s.isEmpty) return 0;

    bool isNegative = false;
    if (s.startsWith('(') && s.endsWith(')')) {
      isNegative = true;
      s = s.substring(1, s.length - 1).trim();
    } else if (s.startsWith('-')) {
      isNegative = true;
      s = s.substring(1).trim();
    }

    // Remove THB, ฿, commas, currency codes, spaces
    s = s.replaceAll(RegExp(r'[^\d.]'), '');
    if (s.isEmpty) return 0;

    try {
      final dec = Decimal.parse(s);
      final satang = (dec * Decimal.fromInt(100)).toBigInt().toInt();
      return isNegative ? -satang : satang;
    } catch (_) {
      final d = double.tryParse(s);
      if (d == null) return 0;
      final satang = (d * 100).round();
      return isNegative ? -satang : satang;
    }
  }

  /// Parses date formats commonly used in Notion and Thai banking exports:
  /// - Notion default: "January 6, 2026", "December 29, 2024", "Jan 6, 2026"
  /// - Notion date ranges: "January 6, 2026 -> January 7, 2026"
  /// - "26-Sep-23", "5-Oct-23", "14-Oct-2023", "6 January 2026"
  /// - "2023-09-26", "26/09/2023", "26-09-2023"
  /// - Buddhist Era year conversion (e.g. 2569 -> 2026, 2566 -> 2023)
  static DateTime? parseDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;

    var s = raw.toString().trim();
    if (s.isEmpty) return null;

    // Remove surrounding quotes if any: e.g. '"January 6, 2026"'
    if ((s.startsWith('"') && s.endsWith('"')) || (s.startsWith("'") && s.endsWith("'"))) {
      s = s.substring(1, s.length - 1).trim();
    }

    // If Notion date range like "January 6, 2026 -> January 7, 2026", take the start date
    if (s.contains('->')) {
      s = s.split('->').first.trim();
    } else if (s.contains('→')) {
      s = s.split('→').first.trim();
    }

    // Try standard ISO
    try {
      return DateTime.parse(s);
    } catch (_) {}

    // Pattern 1: "Month Day, Year" or "Month Day Year" (e.g. "January 6, 2026", "December 29, 2024", "Jan 6, 2026")
    final regexMonthFirst = RegExp(
      r'^([A-Za-zก-๙.]+)\s+(\d{1,2})(?:st|nd|rd|th)?,?\s+(\d{2,4})',
      caseSensitive: false,
    );
    final matchMonthFirst = regexMonthFirst.firstMatch(s);
    if (matchMonthFirst != null) {
      final monthStr = matchMonthFirst.group(1)!;
      final day = int.parse(matchMonthFirst.group(2)!);
      var year = int.parse(matchMonthFirst.group(3)!);

      if (year < 100) year += 2000;
      if (year > 2400) year -= 543;

      final month = _resolveMonth(monthStr);
      try {
        return DateTime(year, month, day);
      } catch (_) {}
    }

    // Pattern 2: "Day Month Year" (e.g. "6 January 2026", "26-Sep-23", "5-Oct-2023", "26 Sep 2023")
    final regexDayFirst = RegExp(
      r'^(\d{1,2})(?:st|nd|rd|th)?[-/\s]([A-Za-zก-๙.]+)[-/\s](\d{2,4})',
      caseSensitive: false,
    );
    final matchDayFirst = regexDayFirst.firstMatch(s);
    if (matchDayFirst != null) {
      final day = int.parse(matchDayFirst.group(1)!);
      final monthStr = matchDayFirst.group(2)!;
      var year = int.parse(matchDayFirst.group(3)!);

      if (year < 100) year += 2000;
      if (year > 2400) year -= 543;

      final month = _resolveMonth(monthStr);
      try {
        return DateTime(year, month, day);
      } catch (_) {}
    }

    // Pattern 3: "yyyy-MM-dd" or "yyyy/MM/dd"
    final regexYmd = RegExp(r'^(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})');
    final matchYmd = regexYmd.firstMatch(s);
    if (matchYmd != null) {
      var year = int.parse(matchYmd.group(1)!);
      final month = int.parse(matchYmd.group(2)!);
      final day = int.parse(matchYmd.group(3)!);

      if (year > 2400) year -= 543;
      try {
        return DateTime(year, month, day);
      } catch (_) {}
    }

    // Pattern 4: "dd/MM/yyyy" or "dd-MM-yyyy"
    final regexNumeric = RegExp(r'^(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})');
    final matchNum = regexNumeric.firstMatch(s);
    if (matchNum != null) {
      final part1 = int.parse(matchNum.group(1)!);
      final part2 = int.parse(matchNum.group(2)!);
      var year = int.parse(matchNum.group(3)!);

      if (year < 100) year += 2000;
      if (year > 2400) year -= 543;

      int day = part1;
      int month = part2;
      if (month > 12 && day <= 12) {
        day = part2;
        month = part1;
      }

      try {
        return DateTime(year, month, day);
      } catch (_) {}
    }

    return null;
  }

  /// Medical/Healthcare Income Tax Rule Classifier
  /// Maps income titles to 40(1), 40(2), non-taxable, and computes withholding tax.
  /// Specific user rules:
  /// - Top up = Non-taxable
  /// - TTCM = 40(2) (withholding already recorded)
  /// - Starting July 2026 (2569 BE), P4P & พ.ต.ส. have 5% withholding tax.
  /// - P4P, พ.ต.ส., เงินประจำตำแหน่ง = 40(1)
  /// - เงินเวรเหมา, เงินรายชั่วโมง, เงิน DF = 40(2) (WHT 0)
  static IncomeTaxClassification classifyIncomeTax({
    required String name,
    required DateTime date,
    required int amountSatang,
    int? explicitWhtSatang,
  }) {
    final cleanName = name.trim().toLowerCase();

    // 1. Top up = Non-taxable (ยกเว้นภาษี 100%)
    if (cleanName.contains('top up') || cleanName.contains('topup') || cleanName.contains('เงิน top up')) {
      return const IncomeTaxClassification(
        taxCategory: 'non_taxable',
        withholdingTaxSatang: 0,
        ruleReason: 'Top up ได้รับการยกเว้นภาษี (Non-taxable)',
      );
    }

    // Check July 2026 boundary (2569 BE = 2026 CE)
    final isJuly2026OrLater = date.year > 2026 || (date.year == 2026 && date.month >= 7);

    // 2. P4P = 40(1) (5% WHT starting July 2026)
    if (cleanName.contains('p4p') || cleanName.contains('pay for performance')) {
      final wht = explicitWhtSatang ?? (isJuly2026OrLater ? (amountSatang * 5 ~/ 100) : 0);
      return IncomeTaxClassification(
        taxCategory: '40_1',
        withholdingTaxSatang: wht,
        ruleReason: isJuly2026OrLater
            ? 'P4P มาตรา 40(1) หัก ณ ที่จ่าย 5% (เริ่ม ก.ค. 2569)'
            : 'P4P มาตรา 40(1) ไม่หัก ณ ที่จ่าย (ก่อน ก.ค. 2569)',
      );
    }

    // 3. พ.ต.ส. = 40(1) (5% WHT starting July 2026)
    if (cleanName.contains('พ.ต.ส.') || cleanName.contains('พตส') || cleanName.contains('พ.ต.ส')) {
      final wht = explicitWhtSatang ?? (isJuly2026OrLater ? (amountSatang * 5 ~/ 100) : 0);
      return IncomeTaxClassification(
        taxCategory: '40_1',
        withholdingTaxSatang: wht,
        ruleReason: isJuly2026OrLater
            ? 'พ.ต.ส. มาตรา 40(1) หัก ณ ที่จ่าย 5% (เริ่ม ก.ค. 2569)'
            : 'พ.ต.ส. มาตรา 40(1) ไม่หัก ณ ที่จ่าย (ก่อน ก.ค. 2569)',
      );
    }

    // 4. เงินประจำตำแหน่ง = 40(1) (WHT 0)
    if (cleanName.contains('ประจำตำแหน่ง') || cleanName.contains('เงินประจำตำแหน่ง')) {
      return IncomeTaxClassification(
        taxCategory: '40_1',
        withholdingTaxSatang: explicitWhtSatang ?? 0,
        ruleReason: 'เงินประจำตำแหน่ง มาตรา 40(1) ไม่หักภาษี ณ ที่จ่าย',
      );
    }

    // 5. เงินเดือนจาก สสจ. = 40(1) (WHT 0)
    if (cleanName.contains('สสจ') || cleanName.contains('เงินเดือน')) {
      return IncomeTaxClassification(
        taxCategory: '40_1',
        withholdingTaxSatang: explicitWhtSatang ?? 0,
        ruleReason: 'เงินเดือนจาก สสจ. มาตรา 40(1) ไม่หักภาษี ณ ที่จ่าย',
      );
    }

    // 6. TTCM = 40(2) (withholding tax as recorded)
    if (cleanName.contains('ttcm')) {
      return IncomeTaxClassification(
        taxCategory: '40_2',
        withholdingTaxSatang: explicitWhtSatang ?? 0,
        ruleReason: 'TTCM มาตรา 40(2) มีหักภาษี ณ ที่จ่าย',
      );
    }

    // 7. เงินเวรเหมา = 40(2) (WHT 0)
    if (cleanName.contains('เวรเหมา') || cleanName.contains('เงินเวรเหมา')) {
      return IncomeTaxClassification(
        taxCategory: '40_2',
        withholdingTaxSatang: explicitWhtSatang ?? 0,
        ruleReason: 'เงินเวรเหมา มาตรา 40(2) ไม่หักภาษี ณ ที่จ่าย',
      );
    }

    // 8. เงินรายชั่วโมง = 40(2) (WHT 0)
    if (cleanName.contains('รายชั่วโมง') || cleanName.contains('ชั่วโมง')) {
      return IncomeTaxClassification(
        taxCategory: '40_2',
        withholdingTaxSatang: explicitWhtSatang ?? 0,
        ruleReason: 'เงินรายชั่วโมง มาตรา 40(2) ไม่หักภาษี ณ ที่จ่าย',
      );
    }

    // 9. เงิน DF (Doctor Fee) = 40(2) (WHT 0)
    if (cleanName.contains('df') || cleanName.contains('doctor fee')) {
      return IncomeTaxClassification(
        taxCategory: '40_2',
        withholdingTaxSatang: explicitWhtSatang ?? 0,
        ruleReason: 'เงิน DF มาตรา 40(2) ไม่หักภาษี ณ ที่จ่าย',
      );
    }

    // 10. เงินหมื่น ไม่ทำเวชฯ = 40(2) (WHT 0)
    if (cleanName.contains('ไม่ทำเวช') || cleanName.contains('เงินหมื่น')) {
      return IncomeTaxClassification(
        taxCategory: '40_2',
        withholdingTaxSatang: explicitWhtSatang ?? 0,
        ruleReason: 'เงินหมื่นไม่ทำเวชปฏิบัติส่วนตัว มาตรา 40(2) ไม่หักภาษี ณ ที่จ่าย',
      );
    }

    // 11. เงินส่งเสริมพิเศษ / เบี้ยกันดาร = 40(2) (WHT 0)
    if (cleanName.contains('ส่งเสริมพิเศษ') || cleanName.contains('เบี้ยกันดาร')) {
      return IncomeTaxClassification(
        taxCategory: '40_2',
        withholdingTaxSatang: explicitWhtSatang ?? 0,
        ruleReason: 'เงินส่งเสริมพิเศษ มาตรา 40(2) ไม่หักภาษี ณ ที่จ่าย',
      );
    }

    // 12. P4P = 40(2)
    if (cleanName.contains('p4p')) {
      return IncomeTaxClassification(
        taxCategory: '40_2',
        withholdingTaxSatang: explicitWhtSatang ?? 0,
        ruleReason: 'P4P (Pay for Performance) มาตรา 40(2) มีหักภาษี ณ ที่จ่ายตามระเบียบ',
      );
    }

    // 13. สมุดตรวจสุขภาพ = 40(2)
    if (cleanName.contains('สมุดตรวจสุขภาพ') || cleanName.contains('ตรวจสุขภาพ')) {
      return IncomeTaxClassification(
        taxCategory: '40_2',
        withholdingTaxSatang: explicitWhtSatang ?? 0,
        ruleReason: 'ค่าตรวจสุขภาพ มาตรา 40(2) ไม่หักภาษี ณ ที่จ่าย',
      );
    }

    // 14. ค่าเวร / เวรนอก / ซื้อเวร = 40(2)
    if (cleanName.contains('เวร') || cleanName.contains('on duty')) {
      return IncomeTaxClassification(
        taxCategory: '40_2',
        withholdingTaxSatang: explicitWhtSatang ?? 0,
        ruleReason: 'ค่าเวรปฏิบัติการ มาตรา 40(2) ไม่หักภาษี ณ ที่จ่าย',
      );
    }

    // 15. Credit เงินคืน / Cashback = Non-taxable
    if (cleanName.contains('เงินคืน') || cleanName.contains('cashback') || cleanName.contains('credit')) {
      return const IncomeTaxClassification(
        taxCategory: 'non_taxable',
        withholdingTaxSatang: 0,
        ruleReason: 'เงินคืน/Cashback ไม่อยู่ในเกณฑ์ประเมินภาษี',
      );
    }

    // Default fallback
    return IncomeTaxClassification(
      taxCategory: '40_2',
      withholdingTaxSatang: explicitWhtSatang ?? 0,
      ruleReason: 'รายได้ค่าตอบแทน มาตรา 40(2)',
    );
  }

  /// Parses all CSV rows using the provided mapping.
  static List<ParsedCsvRow> parseRows({
    required List<List<dynamic>> rawRows,
    required CsvColumnMapping mapping,
    required String templateType, // 'notion_expense', 'notion_income', 'custom'
    bool hasHeader = true,
  }) {
    final results = <ParsedCsvRow>[];
    final startIndex = hasHeader ? 1 : 0;

    for (int i = startIndex; i < rawRows.length; i++) {
      final row = rawRows[i];
      if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) {
        continue;
      }

      final rawDate = mapping.dateCol < row.length ? row[mapping.dateCol] : null;
      final rawName = mapping.nameCol < row.length ? row[mapping.nameCol].toString().trim() : '';
      var rawCategory = mapping.categoryCol < row.length ? row[mapping.categoryCol].toString() : '';
      final rawAmount = mapping.amountCol < row.length ? row[mapping.amountCol] : null;
      final rawAccount = mapping.accountCol != null && mapping.accountCol! < row.length
          ? row[mapping.accountCol!].toString().trim()
          : null;
      final rawNote = mapping.noteCol != null && mapping.noteCol! < row.length
          ? row[mapping.noteCol!].toString().trim()
          : null;
      final rawWht = mapping.whtCol != null && mapping.whtCol! < row.length
          ? parseAmountSatang(row[mapping.whtCol!])
          : null;

      final rawBudget = mapping.budgetCol != null && mapping.budgetCol! < row.length
          ? row[mapping.budgetCol!]
          : null;
      final rawProperty = mapping.propertyCol != null && mapping.propertyCol! < row.length
          ? row[mapping.propertyCol!]
          : null;
      final rawPeriod = mapping.periodCol != null && mapping.periodCol! < row.length
          ? row[mapping.periodCol!]
          : null;

      // 1. Skip completely blank rows (e.g. abandoned empty rows from Notion)
      final isDateEmpty = rawDate == null || rawDate.toString().trim().isEmpty;
      final isAmountEmpty = (rawAmount == null || rawAmount.toString().trim().isEmpty) &&
          (rawBudget == null || rawBudget.toString().trim().isEmpty);
      if (rawName.isEmpty && isDateEmpty && isAmountEmpty) {
        continue;
      }

      // 2. Skip repeated header rows (e.g. if files were concatenated)
      final lowerName = rawName.toLowerCase();
      final lowerDate = (rawDate?.toString() ?? '').toLowerCase().trim();
      if ((lowerName == 'expense' || lowerName == 'name' || lowerName == 'รายการ' || lowerName == 'item' || lowerName == 'income') &&
          (lowerDate == 'date' || lowerDate == 'วันที่' || lowerDate == 'time')) {
        continue;
      }
      if ((lowerName == 'date' || lowerName == 'วันที่') &&
          (lowerDate == 'expense' || lowerDate == 'name' || lowerDate == 'รายการ' || lowerDate == 'income')) {
        continue;
      }

      // Clean Notion relations (e.g. "Eating_OCT23 (https://...)" -> "Eating")
      // Then map Notion category names to app canonical nameEn
      var cleanCategory = templateType.startsWith('notion')
          ? cleanNotionRelation(rawCategory)
          : rawCategory.trim();

      if (templateType.startsWith('notion') && cleanCategory.isNotEmpty) {
        final mapped = NotionCategoryMapper.toAppCategoryNameEn(cleanCategory);
        if (mapped != null) cleanCategory = mapped;
      }

      // Parse work period if provided (e.g. "July 26" -> "2026-07")
      final workPeriod = parseNotionWorkPeriod(rawPeriod?.toString());

      // Parse clearance status (isCleared): Property == 'Yes' -> true, 'No' -> false
      bool isCleared = true;
      if (rawProperty != null) {
        final propStr = rawProperty.toString().trim().toLowerCase();
        if (propStr == 'no' || propStr == 'false') {
          isCleared = false;
        } else if (propStr == 'yes' || propStr == 'true') {
          isCleared = true;
        }
      }

      // Check for summary/total rows
      final isSummary = isSummaryRow(rawName, cleanCategory);

      // Parse date and amount
      final date = parseDate(rawDate);
      final actualSatang = parseAmountSatang(rawAmount).abs();
      final budgetSatang = rawBudget != null ? parseAmountSatang(rawBudget).abs() : 0;

      int amountSatang = actualSatang;
      // If Amount is 0 (or empty because Property was No), use Budget amount as expected amount
      if (amountSatang == 0 && budgetSatang > 0) {
        amountSatang = budgetSatang;
      }
      if (rawProperty != null && rawProperty.toString().trim().toLowerCase() == 'no') {
        isCleared = false;
      }

      final expectedAmountSatang = budgetSatang > 0 ? budgetSatang : amountSatang;

      // Determine transaction type
      String txType = 'expense';
      if (templateType == 'notion_income') {
        txType = 'income';
      } else if (templateType == 'notion_expense') {
        txType = 'expense';
      } else {
        txType = amountSatang < 0 ? 'expense' : 'income';
      }

      // Amounts are stored positive in satang
      amountSatang = amountSatang.abs();

      // Income tax classification
      String? taxCategory;
      int withholdingTaxSatang = 0;
      if (txType == 'income') {
        final classification = classifyIncomeTax(
          name: rawName,
          date: date ?? DateTime.now(),
          amountSatang: amountSatang,
          explicitWhtSatang: rawWht,
        );
        taxCategory = classification.taxCategory;
        withholdingTaxSatang = classification.withholdingTaxSatang;
      }

      // Validation
      String? valError;
      if (!isSummary) {
        if (date == null) {
          valError = 'วันที่ไม่ถูกต้อง ("$rawDate")';
        } else if (amountSatang == 0) {
          valError = 'ยอดเงินเป็น 0 หรืออ่านค่าไม่ได้';
        }
      }

      results.add(ParsedCsvRow(
        rowIndex: i,
        date: date,
        rawDateString: rawDate?.toString() ?? '',
        name: rawName.trim(),
        categoryName: cleanCategory.isEmpty ? 'ทั่วไป' : cleanCategory,
        accountName: rawAccount != null && rawAccount.isNotEmpty ? rawAccount : null,
        amountSatang: amountSatang,
        transactionType: txType,
        taxCategory: taxCategory,
        withholdingTaxSatang: withholdingTaxSatang,
        note: rawNote,
        isSummaryRow: isSummary,
        validationError: valError,
        rawRow: row,
        workPeriod: workPeriod,
        expectedAmountSatang: expectedAmountSatang,
        isCleared: isCleared,
      ));
    }

    return results;
  }
}

class IncomeTaxClassification {
  final String taxCategory;
  final int withholdingTaxSatang;
  final String ruleReason;

  const IncomeTaxClassification({
    required this.taxCategory,
    required this.withholdingTaxSatang,
    required this.ruleReason,
  });
}
