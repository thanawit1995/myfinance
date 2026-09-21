import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/money/money.dart';

void main() {
  group('Money - Core & Arithmetic Tests', () {
    test('Constructors and factories work correctly', () {
      const m1 = Money(12345);
      expect(m1.inSatang, equals(12345));
      expect(m1.inBaht, equals(123.45));

      final m2 = Money.fromBaht(123.45);
      expect(m2.inSatang, equals(12345));

      final m3 = Money.fromDecimal(Decimal.parse('123.45'));
      expect(m3.inSatang, equals(12345));

      const zero = Money.zero();
      expect(zero.inSatang, equals(0));
      expect(zero.isZero, isTrue);
      expect(zero.isPositive, isFalse);
      expect(zero.isNegative, isFalse);
    });

    test('Addition and Subtraction maintain exact integer satang', () {
      const a = Money(10050); // 100.50 THB
      const b = Money(20075); // 200.75 THB

      final sum = a + b;
      expect(sum.inSatang, equals(30125)); // 301.25 THB
      expect(sum.inBaht, equals(301.25));

      final diff = b - a;
      expect(diff.inSatang, equals(10025)); // 100.25 THB

      final neg = a - b;
      expect(neg.inSatang, equals(-10025));
      expect(neg.isNegative, isTrue);
      expect(neg.abs().inSatang, equals(10025));
    });

    test('Multiplication and Division handle rounding correctly', () {
      const m = Money(10000); // 100.00 THB

      final half = m * 0.5;
      expect(half.inSatang, equals(5000));

      final dividedBy3 = m / 3;
      expect(dividedBy3.inSatang, equals(3333)); // 10000 / 3 = 3333.333... -> 3333

      expect(() => m / 0, throwsArgumentError);
    });

    test('Comparison operators work as expected', () {
      const m1 = Money(1000);
      const m2 = Money(2000);
      const m3 = Money(1000);

      expect(m1 < m2, isTrue);
      expect(m1 <= m3, isTrue);
      expect(m2 > m1, isTrue);
      expect(m2 >= m1, isTrue);
      expect(m1 == m3, isTrue);
      expect(m1.compareTo(m2), isNegative);
    });

    test('Parsing string input', () {
      expect(Money.parse('1,234.50').inSatang, equals(123450));
      expect(Money.parse('50').inSatang, equals(5000));
      expect(Money.parse('0.05').inSatang, equals(5));
      expect(Money.tryParse('invalid'), isNull);
      expect(Money.parse('').inSatang, equals(0));
    });

    test('Formatting string output', () {
      const mPositive = Money(123456); // 1,234.56 THB
      expect(mPositive.format(), equals('฿1,234.56'));
      expect(mPositive.format(includeSymbol: false), equals('1,234.56'));
      expect(mPositive.format(showSign: true), equals('+฿1,234.56'));

      const mNegative = Money(-5000); // -50.00 THB
      expect(mNegative.format(), equals('-฿50.00'));
    });
  });
}
