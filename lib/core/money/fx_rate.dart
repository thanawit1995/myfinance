import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';
import 'money.dart';

/// Class representing a Foreign Exchange (FX) rate with 6 decimal places precision.
/// Conforms to Rule 4 in AGENTS.md.
class FxRate implements Comparable<FxRate> {
  final Decimal rate;

  const FxRate(this.rate);

  factory FxRate.fromString(String value) {
    return FxRate(Decimal.parse(value.trim()));
  }

  factory FxRate.fromNum(num value) {
    return FxRate(Decimal.parse(value.toString()));
  }

  static FxRate? tryParse(String input) {
    try {
      final parsed = Decimal.tryParse(input.trim());
      if (parsed == null) return null;
      return FxRate(parsed);
    } catch (_) {
      return null;
    }
  }

  /// Converts foreign money (in original sub-units, e.g. USD cents)
  /// into THB Money (in satang) by multiplying with the locked FX rate.
  Money convertToThb(Money foreignAmount) {
    final resultDecimal = Decimal.fromInt(foreignAmount.satang) * rate;
    // Round to nearest integer satang
    final satang = (resultDecimal + Decimal.parse('0.5')).toBigInt().toInt();
    return Money(satang);
  }

  /// Converts THB Money (in satang) into foreign Money (e.g. USD cents).
  Money convertFromThb(Money thbAmount) {
    if (rate == Decimal.zero) {
      throw ArgumentError('FX rate cannot be zero');
    }
    final thbDecimal = Decimal.fromInt(thbAmount.satang);
    final foreignDecimal = (thbDecimal / rate).toDecimal(scaleOnInfinitePrecision: 6);
    final satang = (foreignDecimal + Decimal.parse('0.5')).toBigInt().toInt();
    return Money(satang);
  }

  bool operator <(FxRate other) => rate < other.rate;
  bool operator <=(FxRate other) => rate <= other.rate;
  bool operator >(FxRate other) => rate > other.rate;
  bool operator >=(FxRate other) => rate >= other.rate;

  @override
  int compareTo(FxRate other) => rate.compareTo(other.rate);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FxRate && runtimeType == other.runtimeType && rate == other.rate;

  @override
  int get hashCode => rate.hashCode;

  /// Returns string representation formatted with up to [fractionDigits] decimal places.
  String format([int fractionDigits = 6]) {
    final formatter = NumberFormat('#,##0.${'0' * fractionDigits}');
    return DecimalFormatter(formatter).format(rate);
  }

  @override
  String toString() => rate.toString();
}
