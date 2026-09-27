import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/features/import/domain/money_big_plan_parser.dart';

void main() {
  group('MoneyBigPlanParser Tests', () {
    test('evaluateExpressionToSatang calculates arithmetic correctly', () {
      expect(MoneyBigPlanParser.evaluateExpressionToSatang('20520'), 2052000);
      expect(MoneyBigPlanParser.evaluateExpressionToSatang('17442+3077'), 2051900);
      expect(MoneyBigPlanParser.evaluateExpressionToSatang('24000+1312.5+6000'), 3131250);
      expect(MoneyBigPlanParser.evaluateExpressionToSatang('16000-15000'), 100000);
      expect(MoneyBigPlanParser.evaluateExpressionToSatang('0'), 0);
      expect(MoneyBigPlanParser.evaluateExpressionToSatang('-'), 0);
      expect(MoneyBigPlanParser.evaluateExpressionToSatang('SUM(C3:C7)'), 0);
      expect(MoneyBigPlanParser.evaluateExpressionToSatang('C35+D32'), 0);
    });

    test('Parses actual Money BIG PLAN Excel file correctly', () {
      final file = File(r'C:\Users\Msi\.gemini\antigravity\brain\c5e9f109-1891-4afc-a5c8-b236dfd02fe5\.user_uploaded\media_1790476128670.xlsx');
      if (!file.existsSync()) {
        // Skip if running on CI or test without uploaded file
        return;
      }

      final bytes = file.readAsBytesSync();
      final rows = MoneyBigPlanParser.parseExcelBytes(bytes);

      expect(rows, isNotEmpty);
      expect(rows.length, greaterThan(500));

      // Check year 2023 constraint: only months 1 to 8 allowed
      final rows2023 = rows.where((r) => r.year == 2023);
      for (final r in rows2023) {
        expect(r.month, inInclusiveRange(1, 8));
      }

      // Check account: all rows must belong to SCB
      for (final r in rows) {
        expect(r.sourceAccountId, MoneyBigPlanParser.scbAccountId);
        expect(r.amountSatang, greaterThan(0));
      }

      // Check investment exclusion: no rows should have SSF, RMF, crypto, or stocks
      for (final r in rows) {
        final label = r.originalLabel.toLowerCase();
        expect(label.contains('cryptocurrency'), isFalse);
        expect(label.contains('ssf'), isFalse);
        expect(label.contains('rmf'), isFalse);
        expect(label.contains('กองทุน/หุ้น'), isFalse);
      }
    });
  });
}
