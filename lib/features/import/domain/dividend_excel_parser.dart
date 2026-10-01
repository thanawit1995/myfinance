import 'dart:typed_data';
import 'package:decimal/decimal.dart';
import 'package:excel/excel.dart';

/// Represents a single parsed row from the dividend Excel file (ปันผล.xlsx).
class ParsedDividendExcelRow {
  final int rowIndex;
  final DateTime date;
  final String symbol;
  final double grossUsd;
  final double taxUsd;
  final double netUsd;
  final Decimal fxRate;
  final int grossSatang; // USD cents
  final int taxSatang; // USD cents
  final int netUsdSatang; // USD cents
  final int netThbSatang; // THB satang
  final int withholdingTaxThbSatang; // THB satang
  final bool isTaxExemptRefund; // e.g. "ส่วนเว้นภาษี"

  const ParsedDividendExcelRow({
    required this.rowIndex,
    required this.date,
    required this.symbol,
    required this.grossUsd,
    required this.taxUsd,
    required this.netUsd,
    required this.fxRate,
    required this.grossSatang,
    required this.taxSatang,
    required this.netUsdSatang,
    required this.netThbSatang,
    required this.withholdingTaxThbSatang,
    this.isTaxExemptRefund = false,
  });
}

/// Parses the user's foreign stock dividend Excel file (ปันผล.xlsx).
class DividendExcelParser {
  DividendExcelParser._();

  static const String dimeUsdAccountId = '00000000-0000-4000-8000-000000000005';
  static const String dividendCategoryId = 'cat-inc-0000-4000-8000-000000000003';

  /// Decodes Excel bytes and parses all dividend rows from Sheet1.
  static List<ParsedDividendExcelRow> parseExcelBytes(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final results = <ParsedDividendExcelRow>[];

    // Pick Sheet1 or first sheet
    Sheet? sheet = excel.tables['Sheet1'] ?? excel.tables.values.firstOrNull;
    if (sheet == null) return [];

    int headerRowIndex = -1;
    int colDate = -1;
    int colSymbol = -1;
    int colGross = -1;
    int colTax = -1;
    int colFx = -1;

    // 1. Scan for header row
    for (int r = 0; r < sheet.maxRows && r < 5; r++) {
      final row = sheet.rows[r];
      for (int c = 0; c < row.length; c++) {
        final val = _extractCellValue(row[c]).toLowerCase();
        if (val.contains('วัน') || val.contains('date')) {
          colDate = c;
        } else if (val.contains('ชื่อ') || val.contains('หุ้น') || val.contains('symbol')) {
          colSymbol = c;
        } else if (val.contains('ปันผล') || val.contains('dividend') || val.contains('gross')) {
          colGross = c;
        } else if (val.contains('ภาษี') || val.contains('tax') || val.contains('wht')) {
          colTax = c;
        } else if (val.contains('อัตราแลกเปลี่ยน') || val.contains('fx') || val.contains('usd/thb') || val.contains('rate')) {
          colFx = c;
        }
      }

      if (colDate != -1 && (colSymbol != -1 || colGross != -1)) {
        headerRowIndex = r;
        break;
      }
    }

    // Default column indices if header scanning missed specific positions
    if (colDate == -1) colDate = 0;
    if (colSymbol == -1) colSymbol = 1;
    if (colGross == -1) colGross = 2;
    if (colTax == -1) colTax = 3;
    if (colFx == -1) colFx = 4;
    if (headerRowIndex == -1) headerRowIndex = 0;

    // 2. Iterate data rows
    for (int r = headerRowIndex + 1; r < sheet.maxRows; r++) {
      final row = sheet.rows[r];
      if (row.isEmpty) continue;

      final dateVal = colDate < row.length ? row[colDate]?.value : null;
      final parsedDate = _parseDate(dateVal);
      if (parsedDate == null) continue;

      final symbolVal = colSymbol < row.length ? _extractCellValue(row[colSymbol]).trim() : '';
      if (symbolVal.isEmpty) continue;

      final grossVal = colGross < row.length ? row[colGross]?.value : null;
      final grossUsd = _parseDouble(grossVal);
      if (grossUsd <= 0) continue;

      final taxVal = colTax < row.length ? row[colTax]?.value : null;
      final taxUsd = _parseDouble(taxVal);

      final fxVal = colFx < row.length ? row[colFx]?.value : null;
      final fxRate = _parseDecimal(fxVal);

      final netUsd = grossUsd - taxUsd;
      final grossSatang = (grossUsd * 100).round();
      final taxSatang = (taxUsd * 100).round();
      final netUsdSatang = (netUsd * 100).round();

      final netThbSatang = (Decimal.fromInt(netUsdSatang) * fxRate).round().toBigInt().toInt();
      final withholdingTaxThbSatang = (Decimal.fromInt(taxSatang) * fxRate).round().toBigInt().toInt();

      final isTaxExemptRefund = symbolVal.contains('ส่วนเว้นภาษี') || symbolVal.contains('เว้นภาษี');

      results.add(ParsedDividendExcelRow(
        rowIndex: r,
        date: parsedDate,
        symbol: symbolVal,
        grossUsd: grossUsd,
        taxUsd: taxUsd,
        netUsd: netUsd,
        fxRate: fxRate,
        grossSatang: grossSatang,
        taxSatang: taxSatang,
        netUsdSatang: netUsdSatang,
        netThbSatang: netThbSatang,
        withholdingTaxThbSatang: withholdingTaxThbSatang,
        isTaxExemptRefund: isTaxExemptRefund,
      ));
    }

    return results;
  }

  static String _extractCellValue(Data? cell) {
    if (cell == null || cell.value == null) return '';
    final val = cell.value;
    if (val is TextCellValue) return val.value.text ?? '';
    return val.toString();
  }

  static DateTime? _parseDate(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    if (val is DateCellValue) {
      // In Thai spreadsheets, users enter dates as Day/Month/Year (d/M/yyyy).
      // On systems with US locale defaults, Excel parses d/M/yyyy as M/d/yyyy whenever day <= 12,
      // resulting in DateCellValue having month = user's day, and day = user's month.
      // (Whenever day > 12, Excel leaves the cell as TextCellValue '16/6/2026').
      // Therefore, we swap val.day (real month) and val.month (real day).
      return DateTime(val.year, val.day, val.month);
    }
    if (val is DateTimeCellValue) {
      return DateTime(val.year, val.day, val.month, val.hour, val.minute, val.second);
    }
    if (val is IntCellValue) {
      return _parseExcelSerialDate(val.value);
    }
    if (val is DoubleCellValue) {
      return _parseExcelSerialDate(val.value.toInt());
    }

    final s = val.toString().trim();
    if (s.isEmpty) return null;

    final numVal = int.tryParse(s);
    if (numVal != null && numVal > 30000 && numVal < 60000) {
      return _parseExcelSerialDate(numVal);
    }

    final partsSlash = s.split('/');
    if (partsSlash.length == 3) {
      final day = int.tryParse(partsSlash[0]);
      final month = int.tryParse(partsSlash[1]);
      final year = int.tryParse(partsSlash[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    final partsDash = s.split('-');
    if (partsDash.length == 3) {
      final year = int.tryParse(partsDash[0]);
      final month = int.tryParse(partsDash[1]);
      final day = int.tryParse(partsDash[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }

    return DateTime.tryParse(s);
  }

  static DateTime _parseExcelSerialDate(num serial) {
    final base = DateTime(1899, 12, 30);
    return base.add(Duration(days: serial.toInt()));
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is DoubleCellValue) return val.value;
    if (val is IntCellValue) return val.value.toDouble();
    if (val is TextCellValue) {
      final s = val.value.text?.trim().replaceAll(',', '') ?? '';
      if (s == '-' || s.isEmpty) return 0.0;
      return double.tryParse(s) ?? 0.0;
    }
    final s = val.toString().trim().replaceAll(',', '');
    if (s == '-' || s.isEmpty) return 0.0;
    return double.tryParse(s) ?? 0.0;
  }

  static Decimal _parseDecimal(dynamic val) {
    if (val == null) return Decimal.one;
    if (val is DoubleCellValue) return Decimal.parse(val.value.toStringAsFixed(6));
    if (val is IntCellValue) return Decimal.fromInt(val.value);
    if (val is TextCellValue) {
      final s = val.value.text?.trim().replaceAll(',', '') ?? '';
      if (s == '-' || s.isEmpty) return Decimal.one;
      return Decimal.tryParse(s) ?? Decimal.one;
    }
    final s = val.toString().trim().replaceAll(',', '');
    if (s == '-' || s.isEmpty) return Decimal.one;
    return Decimal.tryParse(s) ?? Decimal.one;
  }
}
