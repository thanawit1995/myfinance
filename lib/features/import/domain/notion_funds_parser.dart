import 'package:decimal/decimal.dart';
import 'csv_import_parser.dart';

/// Represents a single parsed mutual fund holding/lot from Notion Mutual Funds CSV.
class ParsedFundRow {
  final int rowIndex;
  final String symbol;          // e.g. "K-SET50", "SCBFP-SSF", "GPF"
  final String name;            // Fund display name
  final String fundType;        // "mutual_fund"
  final String? subType;        // "Equity Funds", "SSF", "Retirement fund"
  final DateTime buyDate;
  final Decimal quantity;       // Shares (units)
  final int totalCostThbSatang; // Invested THB amount in satang
  final Decimal unitCostThb;    // Invested cost per share (Decimal precision)
  final Decimal currentNav;     // Current NAV per unit (Decimal precision)
  final String platform;        // "Finnomena", "GPF", etc.
  bool isDuplicate;

  ParsedFundRow({
    required this.rowIndex,
    required this.symbol,
    required this.name,
    required this.fundType,
    this.subType,
    required this.buyDate,
    required this.quantity,
    required this.totalCostThbSatang,
    required this.unitCostThb,
    required this.currentNav,
    required this.platform,
    this.isDuplicate = false,
  });
}

/// Parser for Notion Mutual Funds CSV export.
class NotionFundsParser {
  NotionFundsParser._();

  static List<ParsedFundRow> parseRows(List<List<dynamic>> rawRows) {
    final results = <ParsedFundRow>[];
    if (rawRows.isEmpty) return results;

    final headers = rawRows[0].map((h) => h.toString().trim().toLowerCase()).toList();
    final nameCol = _findCol(headers, ['name', 'fund', 'กองทุน']);
    final sharesCol = _findCol(headers, ['shares', 'หน่วย']);
    final investCol = _findCol(headers, ['invest', 'เงินลงทุน', 'ต้นทุน']);
    final navCol = _findCol(headers, ['current nav', 'nav', 'ราคา nav']);
    final typeCol = _findCol(headers, ['type', 'ประเภท']);
    final appCol = _findCol(headers, ['app', 'platform', 'บัญชี']);
    final dateCol = _findCol(headers, ['invest-funds', 'date', 'วันที่']);

    for (int i = 1; i < rawRows.length; i++) {
      final row = rawRows[i];
      if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;

      final rawName = nameCol != -1 && nameCol < row.length ? row[nameCol].toString().trim() : '';
      if (rawName.isEmpty || rawName.toLowerCase() == 'name') continue;

      // Symbol / clean name
      final symbol = _cleanSymbol(rawName);
      final rawShares = sharesCol != -1 && sharesCol < row.length ? row[sharesCol].toString().trim() : '0';
      final Decimal quantity = Decimal.tryParse(rawShares.replaceAll(',', '')) ?? Decimal.zero;
      if (quantity <= Decimal.zero) continue;

      // Total Invested THB
      final rawInvest = investCol != -1 && investCol < row.length ? row[investCol] : null;
      final int totalCostThbSatang = CsvImportParser.parseAmountSatang(rawInvest).abs();

      // Current NAV
      final rawNav = navCol != -1 && navCol < row.length ? row[navCol].toString() : '';
      final cleanNavStr = rawNav.replaceAll(RegExp(r'[^\d.]'), '');
      final Decimal currentNav = Decimal.tryParse(cleanNavStr) ?? Decimal.zero;

      // Platform / App
      final rawApp = appCol != -1 && appCol < row.length ? row[appCol].toString().trim() : 'Finnomena';
      final platform = rawApp.isNotEmpty ? rawApp : 'Finnomena';

      // Type
      final rawType = typeCol != -1 && typeCol < row.length ? row[typeCol].toString().trim() : 'Equity Funds';

      // Date
      DateTime buyDate = DateTime(2024, 1, 1);
      if (dateCol != -1 && dateCol < row.length) {
        final rawDateCell = row[dateCol].toString();
        final cleanedDateStr = rawDateCell.replaceAll(RegExp(r'\s*\(\s*https?:\/\/[^\)]+\)'), '').replaceAll('@', '').trim();
        final parsed = CsvImportParser.parseDate(cleanedDateStr);
        if (parsed != null) buyDate = parsed;
      }

      // Unit Cost (Decimal precision)
      Decimal unitCostThb = Decimal.zero;
      if (totalCostThbSatang > 0 && quantity > Decimal.zero) {
        unitCostThb = ((Decimal.fromInt(totalCostThbSatang) * Decimal.parse('0.01')) / quantity).toDecimal(scaleOnInfinitePrecision: 8);
      } else if (currentNav > Decimal.zero) {
        unitCostThb = currentNav;
      }

      results.add(ParsedFundRow(
        rowIndex: i,
        symbol: symbol,
        name: rawName,
        fundType: 'mutual_fund',
        subType: rawType.isNotEmpty ? rawType : null,
        buyDate: buyDate,
        quantity: quantity,
        totalCostThbSatang: totalCostThbSatang,
        unitCostThb: unitCostThb,
        currentNav: currentNav,
        platform: platform,
      ));
    }

    return results;
  }

  static int _findCol(List<String> headers, List<String> candidates) {
    for (final cand in candidates) {
      for (int i = 0; i < headers.length; i++) {
        if (headers[i] == cand) return i;
      }
    }
    for (final cand in candidates) {
      for (int i = 0; i < headers.length; i++) {
        if (headers[i].contains(cand)) return i;
      }
    }
    return -1;
  }

  static String _cleanSymbol(String raw) {
    var s = raw.trim();
    final paren = s.indexOf('(');
    if (paren != -1) s = s.substring(0, paren).trim();
    return s;
  }
}
