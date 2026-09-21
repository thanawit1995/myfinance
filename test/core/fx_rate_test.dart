import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/money/fx_rate.dart';
import 'package:myfinance/core/money/money.dart';

void main() {
  group('FxRate - Precision & Conversion Tests', () {
    test('Constructors and 6-decimal precision', () {
      final rate = FxRate.fromString('35.500000');
      expect(rate.rate, equals(Decimal.parse('35.5')));
      expect(rate.format(6), equals('35.500000'));

      final rate2 = FxRate.fromNum(36.123456);
      expect(rate2.format(6), equals('36.123456'));
    });

    test('Converts foreign currency (USD) to THB accurately', () {
      // 100.50 USD = 10050 cents
      const usdAmount = Money(10050);
      final fx = FxRate.fromString('35.500000');

      // 100.50 * 35.50 = 3567.75 THB = 356775 satang
      final thbAmount = fx.convertToThb(usdAmount);
      expect(thbAmount.inSatang, equals(356775));
      expect(thbAmount.inBaht, equals(3567.75));
    });

    test('Converts THB to foreign currency (USD) accurately', () {
      // 3567.75 THB = 356775 satang
      const thbAmount = Money(356775);
      final fx = FxRate.fromString('35.500000');

      final usdAmount = fx.convertFromThb(thbAmount);
      expect(usdAmount.inSatang, equals(10050)); // 100.50 USD
    });

    test('Comparison and equality', () {
      final r1 = FxRate.fromString('35.500000');
      final r2 = FxRate.fromString('36.000000');
      final r3 = FxRate.fromString('35.50');

      expect(r1 < r2, isTrue);
      expect(r1 == r3, isTrue);
    });
  });
}
