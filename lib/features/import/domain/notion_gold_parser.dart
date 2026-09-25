import 'package:decimal/decimal.dart';
import 'csv_import_parser.dart';

/// Represents a single parsed gold holding from Notion Gold CSV.
class ParsedGoldRow {
  final int rowIndex;
  final String symbol;           // e.g. "MST-GOLD 99.99%"
  final String name;             // Gold display name
  final Decimal quantity;        // Total gold weight (e.g. 0.1984)
  final int amountUsdSatang;     // Total invest in USD satang ($590.60 -> 59060)
  final Decimal fxRate;          // USDTHB exchange rate (e.g. 32.37)
  final int totalCostThbSatang;  // Invested THB amount in satang
  final Decimal unitCostUsd;     // Average unit cost USD (e.g. 2976.78)
  final Decimal marketPriceUsd;  // Current market price USD (e.g. 4616.83)
  final DateTime recordDate;
  bool isDuplicate;

  ParsedGoldRow({
    required this.rowIndex,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.amountUsdSatang,
    required this.fxRate,
    required this.totalCostThbSatang,
    required this.unitCostUsd,
    required this.marketPriceUsd,
    required this.recordDate,
    this.isDuplicate = false,
  });
}

/// Parser for Notion Gold CSV export.
class NotionGoldParser {
  NotionGoldParser._();

  static List<ParsedGoldRow> parseRows(List<List<dynamic>> rawRows) {
    final results = <ParsedGoldRow>[];
    if (rawRows.isEmpty) return results;

    final headers = rawRows[0].map((h) => h.toString().trim().toLowerCase()).toList();
    final nameCol = _findCol(headers, ['name', 'gold', 'ทอง']);
    final goldCol = _findCol(headers, ['total gold', 'gold', 'น้ำหนัก']);
    final investCol = _findCol(headers, ['total invest', 'invest', 'เงินลงทุน']);
    final fxCol = _findCol(headers, ['usdthb price', 'usdthb', 'fx']);
    final currentPriceCol = _findCol(headers, ['current price', 'ราคาตลาด']);
    final avgCostCol = _findCol(headers, ['ราคาต้นทุนเฉลี่ย', 'avg cost', 'cost']);

    for (int i = 1; i < rawRows.length; i++) {
      final row = rawRows[i];
      if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) continue;

      final rawName = nameCol != -1 && nameCol < row.length ? row[nameCol].toString().trim() : '';
      if (rawName.isEmpty || rawName.toLowerCase() == 'name') continue;

      final symbol = _cleanSymbol(rawName);
      final rawGold = goldCol != -1 && goldCol < row.length ? row[goldCol].toString().trim() : '0';
      final Decimal quantity = Decimal.tryParse(rawGold.replaceAll(',', '')) ?? Decimal.zero;
      if (quantity <= Decimal.zero) continue;

      // Total Invest USD
      final rawInvest = investCol != -1 && investCol < row.length ? row[investCol] : null;
      final int amountUsdSatang = CsvImportParser.parseAmountSatang(rawInvest).abs();

      // FX Rate
      Decimal fxRate = Decimal.parse('35.000000');
      if (fxCol != -1 && fxCol < row.length) {
        final rawFx = row[fxCol].toString().trim();
        final cleanFx = rawFx.replaceAll(RegExp(r'[^\d.]'), '');
        final parsed = Decimal.tryParse(cleanFx);
        if (parsed != null && parsed > Decimal.zero) {
          fxRate = parsed;
        }
      }

      // Total Cost THB
      final int totalCostThbSatang = (Decimal.fromInt(amountUsdSatang) * fxRate).round().toBigInt().toInt();

      // Current Market Price (USD)
      final rawCurrentPrice = currentPriceCol != -1 && currentPriceCol < row.length ? row[currentPriceCol].toString() : '';
      final cleanCurrentPrice = rawCurrentPrice.replaceAll(RegExp(r'[^\d.]'), '');
      final Decimal marketPriceUsd = Decimal.tryParse(cleanCurrentPrice) ?? Decimal.zero;

      // Avg Cost (USD)
      final rawAvgCost = avgCostCol != -1 && avgCostCol < row.length ? row[avgCostCol].toString() : '';
      final cleanAvgCost = rawAvgCost.replaceAll(RegExp(r'[^\d.]'), '');
      Decimal unitCostUsd = Decimal.tryParse(cleanAvgCost) ?? Decimal.zero;
      if (unitCostUsd <= Decimal.zero && quantity > Decimal.zero && amountUsdSatang > 0) {
        unitCostUsd = ((Decimal.fromInt(amountUsdSatang) * Decimal.parse('0.01')) / quantity).toDecimal(scaleOnInfinitePrecision: 8);
      }

      results.add(ParsedGoldRow(
        rowIndex: i,
        symbol: symbol,
        name: rawName,
        quantity: quantity,
        amountUsdSatang: amountUsdSatang,
        fxRate: fxRate,
        totalCostThbSatang: totalCostThbSatang,
        unitCostUsd: unitCostUsd,
        marketPriceUsd: marketPriceUsd,
        recordDate: DateTime(2024, 6, 1),
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
