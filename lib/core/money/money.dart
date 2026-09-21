import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Class representing a monetary amount in integer satang (1 THB = 100 satang).
/// Immutable, prevents floating-point inaccuracies as required by AGENTS.md.
class Money implements Comparable<Money> {
  final int satang;

  const Money(this.satang);

  const Money.zero() : satang = 0;

  factory Money.fromSatang(int satang) => Money(satang);

  factory Money.fromBaht(num baht) {
    return Money((baht * 100).round());
  }

  factory Money.fromDecimal(Decimal baht) {
    final satangDecimal = baht * Decimal.fromInt(100);
    return Money(satangDecimal.toBigInt().toInt());
  }

  /// Parses a string representation of money (e.g. "1,234.50" or "500").
  factory Money.parse(String input) {
    final cleaned = input.replaceAll(',', '').trim();
    if (cleaned.isEmpty) {
      return const Money.zero();
    }
    final decimal = Decimal.parse(cleaned);
    return Money.fromDecimal(decimal);
  }

  static Money? tryParse(String input) {
    try {
      return Money.parse(input);
    } catch (_) {
      return null;
    }
  }

  int get inSatang => satang;

  double get inBaht => satang / 100.0;

  Decimal get toDecimal =>
      (Decimal.fromInt(satang) / Decimal.fromInt(100)).toDecimal();

  bool get isZero => satang == 0;
  bool get isPositive => satang > 0;
  bool get isNegative => satang < 0;

  Money operator +(Money other) => Money(satang + other.satang);
  Money operator -(Money other) => Money(satang - other.satang);
  Money operator -() => Money(-satang);
  Money operator *(num multiplier) => Money((satang * multiplier).round());
  Money operator /(num divisor) {
    if (divisor == 0) {
      throw ArgumentError('Divisor cannot be zero');
    }
    return Money((satang / divisor).round());
  }

  bool operator <(Money other) => satang < other.satang;
  bool operator <=(Money other) => satang <= other.satang;
  bool operator >(Money other) => satang > other.satang;
  bool operator >=(Money other) => satang >= other.satang;

  Money abs() => Money(satang.abs());

  @override
  int compareTo(Money other) => satang.compareTo(other.satang);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money && runtimeType == other.runtimeType && satang == other.satang;

  @override
  int get hashCode => satang.hashCode;

  /// Formats money into a human-readable string (e.g., ฿1,234.50 or -$50.00).
  String format({
    String symbol = '฿',
    bool includeSymbol = true,
    bool showSign = false,
    String locale = 'en_US',
  }) {
    final isNeg = satang < 0;
    final absBaht = satang.abs() / 100.0;
    final formatter = NumberFormat('#,##0.00', locale);
    final formattedNumber = formatter.format(absBaht);

    final sign = isNeg ? '-' : (showSign && satang > 0 ? '+' : '');
    final sym = includeSymbol ? symbol : '';

    return '$sign$sym$formattedNumber';
  }

  @override
  String toString() => format();
}
