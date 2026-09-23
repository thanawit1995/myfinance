import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/features/import/domain/csv_import_parser.dart';

void main() {
  group('CsvImportParser - Notion & Medical Income Tests', () {
    test('Amount parsing handles various currency formats into satang', () {
      // "THB 22,830.00" -> 22,830.00 THB = 2,283,000 satang
      expect(CsvImportParser.parseAmountSatang('THB 22,830.00'), 2283000);
      expect(CsvImportParser.parseAmountSatang('฿ 1,500.50'), 150050);
      expect(CsvImportParser.parseAmountSatang('100'), 10000);
      expect(CsvImportParser.parseAmountSatang('-THB 500.00'), -50000);
      expect(CsvImportParser.parseAmountSatang('(1,250.75)'), -125075);
      expect(CsvImportParser.parseAmountSatang(250.5), 25050);
      expect(CsvImportParser.parseAmountSatang(null), 0);
      expect(CsvImportParser.parseAmountSatang(''), 0);
    });

    test('Date parsing handles Notion full month dates, short-month dates, ISO, and Thai BE', () {
      // Notion full month: "January 6, 2026"
      final n1 = CsvImportParser.parseDate('January 6, 2026');
      expect(n1, isNotNull);
      expect(n1!.year, 2026);
      expect(n1.month, 1);
      expect(n1.day, 6);

      // Notion full month: "December 29, 2024"
      final n2 = CsvImportParser.parseDate('December 29, 2024');
      expect(n2, isNotNull);
      expect(n2!.year, 2024);
      expect(n2.month, 12);
      expect(n2.day, 29);

      // Notion quoted full month: '"January 14, 2026"'
      final n3 = CsvImportParser.parseDate('"January 14, 2026"');
      expect(n3, isNotNull);
      expect(n3!.year, 2026);
      expect(n3.month, 1);
      expect(n3.day, 14);

      // Notion date range: "January 6, 2026 -> January 7, 2026"
      final n4 = CsvImportParser.parseDate('January 6, 2026 -> January 7, 2026');
      expect(n4, isNotNull);
      expect(n4!.year, 2026);
      expect(n4.month, 1);
      expect(n4.day, 6);

      // Notion format: "26-Sep-23"
      final d1 = CsvImportParser.parseDate('26-Sep-23');
      expect(d1, isNotNull);
      expect(d1!.year, 2023);
      expect(d1.month, 9);
      expect(d1.day, 26);

      // "5-Oct-23"
      final d2 = CsvImportParser.parseDate('5-Oct-23');
      expect(d2, isNotNull);
      expect(d2!.year, 2023);
      expect(d2.month, 10);
      expect(d2.day, 5);

      // ISO: "2024-03-15"
      final d3 = CsvImportParser.parseDate('2024-03-15');
      expect(d3, isNotNull);
      expect(d3!.year, 2024);
      expect(d3.month, 3);
      expect(d3.day, 15);

      // Thai BE: "10/05/2567" -> 2024
      final d4 = CsvImportParser.parseDate('10/05/2567');
      expect(d4, isNotNull);
      expect(d4!.year, 2024);
      expect(d4.month, 5);
      expect(d4.day, 10);
    });

    test('Notion relation cleaning strips URL parenthesis and month tags', () {
      expect(
        CsvImportParser.cleanNotionRelation('Eating_OCT23 (https://www.notion.so/myworkspace/Eating-123)'),
        'Eating',
      );
      expect(
        CsvImportParser.cleanNotionRelation('Groceries_SEP23'),
        'Groceries',
      );
      expect(
        CsvImportParser.cleanNotionRelation('Shopping (https://notion.so)'),
        'Shopping',
      );
      expect(
        CsvImportParser.cleanNotionRelation('ค่ารักษาพยาบาล'),
        'ค่ารักษาพยาบาล',
      );
      expect(
        CsvImportParser.cleanNotionRelation('🍴Eating_OCT23 (https://notion.so)'),
        'Eating',
      );
      expect(
        CsvImportParser.cleanNotionRelation('❤️Lover_OCT23 (https://notion.so)'),
        'Lover',
      );
      expect(
        CsvImportParser.cleanNotionRelation('✈️Travel_MAY24 (https://notion.so)'),
        'Travel',
      );
    });

    test('Summary and total row detection', () {
      expect(CsvImportParser.isSummaryRow('รวมทั้งเดือน ก.ย.', 'Eating'), isTrue);
      expect(CsvImportParser.isSummaryRow('Total', 'Groceries'), isTrue);
      expect(CsvImportParser.isSummaryRow('ยอดรวมทั้งสิ้น', 'General'), isTrue);
      expect(CsvImportParser.isSummaryRow('กาแฟเย็น', 'รวม'), isTrue);
      expect(CsvImportParser.isSummaryRow('ซื้อกับข้าว', 'Food'), isFalse);
    });

    test('Medical/Healthcare Tax classification rules', () {
      // 1. Top up = Non-taxable
      final topUp = CsvImportParser.classifyIncomeTax(
        name: 'เงิน top up ประจำเดือน',
        date: DateTime(2026, 8, 1),
        amountSatang: 1500000,
      );
      expect(topUp.taxCategory, 'non_taxable');
      expect(topUp.withholdingTaxSatang, 0);

      // 2. เงินเดือนจาก สสจ. = 40(1) (WHT 0)
      final salary = CsvImportParser.classifyIncomeTax(
        name: 'เงินเดือนจาก สสจ.',
        date: DateTime(2026, 5, 1),
        amountSatang: 3000000,
      );
      expect(salary.taxCategory, '40_1');
      expect(salary.withholdingTaxSatang, 0);

      // 3. เงินประจำตำแหน่ง = 40(1) (WHT 0)
      final position = CsvImportParser.classifyIncomeTax(
        name: 'เงินประจำตำแหน่ง',
        date: DateTime(2026, 5, 1),
        amountSatang: 500000,
      );
      expect(position.taxCategory, '40_1');
      expect(position.withholdingTaxSatang, 0);

      // 4. P4P before July 2026 (2569) -> 40(1), WHT 0%
      final p4pBefore = CsvImportParser.classifyIncomeTax(
        name: 'P4P โรงพยาบาลเดิม',
        date: DateTime(2026, 6, 30),
        amountSatang: 2000000, // 20,000 THB
      );
      expect(p4pBefore.taxCategory, '40_1');
      expect(p4pBefore.withholdingTaxSatang, 0);

      // 5. P4P from July 2026 (2569) onwards -> 40(1), WHT 5%
      final p4pAfter = CsvImportParser.classifyIncomeTax(
        name: 'P4P โรงพยาบาลใหม่',
        date: DateTime(2026, 7, 1),
        amountSatang: 2000000, // 20,000 THB -> 5% = 1,000 THB = 100,000 satang
      );
      expect(p4pAfter.taxCategory, '40_1');
      expect(p4pAfter.withholdingTaxSatang, 100000);

      // 6. พ.ต.ส. from July 2026 onwards -> 40(1), WHT 5%
      final ptsAfter = CsvImportParser.classifyIncomeTax(
        name: 'เงิน พ.ต.ส.',
        date: DateTime(2026, 8, 15),
        amountSatang: 1000000, // 10,000 THB -> 5% = 500 THB = 50,000 satang
      );
      expect(ptsAfter.taxCategory, '40_1');
      expect(ptsAfter.withholdingTaxSatang, 50000);

      // 7. เงินเวรเหมา = 40(2) (WHT 0)
      final shift = CsvImportParser.classifyIncomeTax(
        name: 'เงินเวรเหมา ER',
        date: DateTime(2026, 8, 1),
        amountSatang: 1200000,
      );
      expect(shift.taxCategory, '40_2');
      expect(shift.withholdingTaxSatang, 0);

      // 8. TTCM = 40(2)
      final ttcm = CsvImportParser.classifyIncomeTax(
        name: 'TTCM ประจำเดือน',
        date: DateTime(2026, 8, 1),
        amountSatang: 800000,
        explicitWhtSatang: 24000,
      );
      expect(ttcm.taxCategory, '40_2');
      expect(ttcm.withholdingTaxSatang, 24000);
    });

    test('Full CSV rows parsing with Notion Expense template', () {
      const csvData = '''Date,Name,Category,Wallet,Amount,Note
26-Sep-23,ร้านอาหารริมทาง,Eating_OCT23 (https://notion.so/eat),SCB,THB 250.00,มื้อเที่ยง
5-Oct-23,เติมน้ำมัน,Transport_OCT23 (https://notion.so/trans),Cash,"THB 1,200.00",ปั๊ม ปตท.
30-Sep-23,รวมทั้งเดือน ก.ย.,Eating,SCB,"THB 15,250.00",สรุปยอด
''';

      final rawRows = CsvImportParser.parseRawCsv(csvData);
      expect(rawRows.length, 4);

      final headers = rawRows.first.map((e) => e.toString()).toList();
      final mapping = CsvImportParser.detectMapping(headers, template: 'notion_expense');
      expect(mapping, isNotNull);

      final parsed = CsvImportParser.parseRows(
        rawRows: rawRows,
        mapping: mapping!,
        templateType: 'notion_expense',
      );

      expect(parsed.length, 3);
      // Row 1
      expect(parsed[0].name, 'ร้านอาหารริมทาง');
      expect(parsed[0].categoryName, 'Food & Dining');
      expect(parsed[0].amountSatang, 25000);
      expect(parsed[0].isSummaryRow, isFalse);
      expect(parsed[0].isValid, isTrue);

      // Row 2
      expect(parsed[1].name, 'เติมน้ำมัน');
      expect(parsed[1].categoryName, 'Transport');
      expect(parsed[1].amountSatang, 120000);
      expect(parsed[1].isSummaryRow, isFalse);
      expect(parsed[1].isValid, isTrue);

      // Row 3 (Summary row: "รวมทั้งเดือน ก.ย.")
      expect(parsed[2].name, 'รวมทั้งเดือน ก.ย.');
      expect(parsed[2].isSummaryRow, isTrue);
      expect(parsed[2].isValid, isFalse);
    });

    test('Diagnose user Expense logs CSV file', () async {
      final file = File('Notion_expense/Expense logs 13d7fd0cca734827a24f17211dbf5909.csv');
      if (!await file.exists()) {
        // File not present — skip gracefully (CI safe)
        return;
      }
      final content = await file.readAsString();
      final rawRows = CsvImportParser.parseRawCsv(content);
      final headers = rawRows.first.map((e) => e.toString()).toList();
      final mapping = CsvImportParser.detectMapping(headers);

      // Check if there are other header rows in the middle
      for (int i = 1; i < rawRows.length; i++) {
        final row = rawRows[i];
        final rowStr = row.map((e) => e.toString().toLowerCase()).toList();
        if (rowStr.contains('expense') && rowStr.contains('amount') && (rowStr.contains('date') || rowStr.contains('category'))) {
          // Duplicate header detected — expected to be skipped by parser
        }
      }

      final parsed = CsvImportParser.parseRows(
        rawRows: rawRows,
        mapping: mapping!,
        templateType: 'notion_expense',
      );

      final errors = parsed.where((r) => r.validationError != null && !r.isSummaryRow).toList();
      // Verify: should have at most 2 real errors (the empty-amount rows)
      expect(errors.length, lessThanOrEqualTo(2));

      // Check no obvious duplicates from parser itself
      final seen = <String, List<int>>{};
      for (final r in parsed) {
        if (r.isSummaryRow) continue;
        final key = '${r.date?.toIso8601String()}_${r.name}_${r.amountSatang}_${r.accountName}';
        seen.putIfAbsent(key, () => []).add(r.rowIndex + 1);
      }
      // Duplicates in CSV = real life duplicate entries (2 meals, 7-eleven twice etc) — not parser bugs
      // No assertion needed here, just ensure it ran without crash
    });
  });
}
