import 'package:decimal/decimal.dart';
import 'csv_import_parser.dart';

/// Represents a single parsed investment row from Notion Invest-Stocks CSV.
class ParsedInvestRow {
  final int rowIndex;
  final String ticker;        // cleaned ticker symbol e.g. "O", "JEPQ", "NVDA"
  final DateTime buyDate;
  final Decimal quantity;     // shares, 8 decimal places
  final int amountUsdSatang;  // USD amount × 100 (0 if THB-only purchase)
  final Decimal fxRate;       // USD→THB exchange rate, 6 dp (1.0 if THB payment)
  final int amountThbSatang;  // THB invested × 100
  final Decimal unitPriceOriginal;
  final PaymentType paymentType;
  final String? note;

  bool isDuplicate = false;   // set by executor after duplicate check

  ParsedInvestRow({
    required this.rowIndex,
    required this.ticker,
    required this.buyDate,
    required this.quantity,
    required this.amountUsdSatang,
    required this.fxRate,
    required this.amountThbSatang,
    Decimal? unitPriceOriginal,
    required this.paymentType,
    this.note,
  }) : unitPriceOriginal = unitPriceOriginal ?? Decimal.zero;
}

enum PaymentType {
  /// Paid directly from a THB account
  thb,

  /// Paid from the FCD (Foreign Currency Deposit) account
  fcd,

  /// Paid from an offshore USD account
  usd,

  /// Dividend reinvestment — treated as income row, not a buy
  dividend,
}

/// Parses Notion Invest-Stocks CSV export.
///
/// Column layout (index 0-based):
///   0: Day        — "@24/06/2024 " (ignored — prefer col 1)
///   1: Date       — "June 24, 2024"
///   2: Invested   — "$271.44" (USD amount)
///   3: Rollup     — fx rate number e.g. "32.37" (may be empty or have extra text)
///   4: Share price— "$7.44" (per share USD)
///   5: Shares     — "36.48993"
///   6: Stock      — "O (https://...)" → clean to "O"
///   7: THB invested — "8786.5128"
///   8: Text       — "THB" / "USD" / "FCD" / "ปันผล" / "THB + ปันผล"
///   9: USDTHB     — Notion relation text (NOT a usable number)
///  10: Monthly Overview — ignored
class NotionInvestParser {
  NotionInvestParser._();

  /// Parses all data rows from the Invest-Stocks CSV and returns
  /// a list of [ParsedInvestRow]. Header row is skipped.
  static List<ParsedInvestRow> parseRows(List<List<dynamic>> rawRows) {
    final results = <ParsedInvestRow>[];
    if (rawRows.isEmpty) return results;

    // Find column indices dynamically from header row
    final headers = rawRows[0].map((h) => h.toString().trim().toLowerCase()).toList();
    final dateCol    = _findCol(headers, ['date']);
    final dayCol     = _findCol(headers, ['day']);
    final investedCol= _findCol(headers, ['invested']);
    final sharePriceCol = _findCol(headers, ['share price', 'cost/share', 'price']);
    final sharesCol  = _findCol(headers, ['shares', 'share']);
    final stockCol   = _findCol(headers, ['stock']);
    final rateCol    = _findCol(headers, [
      'usdthb rate',
      'usd/thb rate',
      'exchange rate',
      'fx rate',
      'rate',
    ]);
    final thbCol     = _findCol(headers, ['thb invested (calculated)', 'thb invested', 'thb']);
    final textCol    = _findCol(headers, ['payment type / source', 'payment type', 'text']);

    // Use dateCol if found, else fall back to dayCol
    final primaryDateCol = (dateCol != -1) ? dateCol : dayCol;

    for (int i = 1; i < rawRows.length; i++) {
      final row = rawRows[i];

      // Skip blank rows
      if (row.isEmpty) continue;
      final allEmpty = row.every((c) => c.toString().trim().isEmpty);
      if (allEmpty) continue;

      final rawDate   = primaryDateCol != -1 && primaryDateCol < row.length ? row[primaryDateCol] : null;
      final rawDay    = dayCol != -1 && dayCol < row.length ? row[dayCol]?.toString().trim() : null;
      final rawStock  = stockCol != -1 && stockCol < row.length ? row[stockCol].toString() : '';
      final rawShares = sharesCol != -1 && sharesCol < row.length ? row[sharesCol].toString().trim() : '';
      final rawInvested = investedCol != -1 && investedCol < row.length ? row[investedCol] : null;
      final rawSharePrice = sharePriceCol != -1 && sharePriceCol < row.length ? row[sharePriceCol]?.toString().trim() : '';
      final rawThb    = thbCol != -1 && thbCol < row.length ? row[thbCol] : null;
      final rawText   = textCol != -1 && textCol < row.length ? row[textCol].toString().trim() : '';

      // Skip header-repeat rows
      if (rawStock.toLowerCase() == 'stock' || rawShares.toLowerCase() == 'shares') continue;

      // Parse date — prefer col 1 (full English name), fallback to col 0 (@DD/MM/YYYY)
      DateTime? buyDate = CsvImportParser.parseDate(rawDate);
      if (buyDate == null && rawDay != null) {
        final cleanDay = rawDay.replaceAll('@', '').trim();
        buyDate = CsvImportParser.parseDate(cleanDay);
      }
      if (buyDate == null) continue; // cannot import without a date

      // Parse ticker
      final ticker = _cleanStockTicker(rawStock);
      if (ticker.isEmpty) continue;

      // Parse payment type from Text column
      final paymentType = _parsePaymentType(rawText);

      // Parse USD invested amount
      int amountUsdSatang = CsvImportParser.parseAmountSatang(rawInvested);

      // Parse shares quantity
      Decimal quantity = Decimal.zero;
      if (rawShares.isNotEmpty) {
        try {
          final cleaned = rawShares.replaceAll(RegExp(r'[^0-9.]'), '');
          quantity = cleaned.isEmpty ? Decimal.zero : Decimal.parse(cleaned);
        } catch (_) {
          quantity = Decimal.zero;
        }
      }
      if (quantity == Decimal.zero) {
        // Fallback to historical shares lookup table if Shares column was not included in CSV
        quantity = _historicalSharesMap['$ticker|$amountUsdSatang'] ??
            _historicalSharesByDateMap['$ticker|${buyDate.year}-${buyDate.month}-${buyDate.day}'] ??
            Decimal.zero;
      }
      if (quantity == Decimal.zero && amountUsdSatang > 0) {
        quantity = Decimal.one; // Fallback to 1 share if unknown
      }
      if (quantity == Decimal.zero) continue;

      // FX Rate: 1) Try column if present, 2) Historical lookup map, 3) Fallback
      Decimal? detectedFxRate;
      if (rateCol != -1 && rateCol < row.length) {
        final rawRate = row[rateCol]?.toString().trim() ?? '';
        final cleanRate = rawRate.replaceAll(RegExp(r'[^0-9.]'), '');
        final parsed = Decimal.tryParse(cleanRate);
        if (parsed != null && parsed > Decimal.zero) {
          detectedFxRate = parsed;
        }
      }

      detectedFxRate ??= _historicalRateMap['$ticker|$amountUsdSatang'];
      detectedFxRate ??= _historicalRateByDateMap['$ticker|${buyDate.year}-${buyDate.month}-${buyDate.day}'];
      final Decimal fxRate = detectedFxRate ?? Decimal.parse('33.650000');

      // Parse THB invested amount
      int amountThbSatang = CsvImportParser.parseAmountSatang(rawThb);

      if (amountUsdSatang > 0) {
        amountThbSatang = (Decimal.fromInt(amountUsdSatang) * fxRate).round().toBigInt().toInt();
      } else if (amountThbSatang > 0) {
        amountUsdSatang = (Decimal.fromInt(amountThbSatang) / fxRate).round().toInt();
      }

      // Parse Unit Price (up to Decimal precision)
      Decimal unitPriceOriginal = Decimal.zero;
      if (rawSharePrice != null && rawSharePrice.isNotEmpty) {
        final cleanPrice = rawSharePrice.replaceAll(RegExp(r'[^0-9.]'), '');
        unitPriceOriginal = Decimal.tryParse(cleanPrice) ?? Decimal.zero;
      }
      if (unitPriceOriginal <= Decimal.zero && quantity > Decimal.zero) {
        if (amountUsdSatang > 0) {
          unitPriceOriginal = ((Decimal.fromInt(amountUsdSatang) * Decimal.parse('0.01')) / quantity)
              .toDecimal(scaleOnInfinitePrecision: 8);
        } else if (amountThbSatang > 0) {
          unitPriceOriginal = (((Decimal.fromInt(amountThbSatang) * Decimal.parse('0.01')) / fxRate) / quantity.toRational())
              .toDecimal(scaleOnInfinitePrecision: 8);
        }
      }

      results.add(ParsedInvestRow(
        rowIndex: i,
        ticker: ticker,
        buyDate: buyDate,
        quantity: quantity,
        amountUsdSatang: amountUsdSatang,
        fxRate: fxRate,
        amountThbSatang: amountThbSatang.abs(),
        unitPriceOriginal: unitPriceOriginal,
        paymentType: paymentType,
        note: rawText.isNotEmpty ? rawText : null,
      ));
    }
    return results;
  }

  // ─── Private Helpers ─────────────────────────────────────────

  static int _findCol(List<String> headers, List<String> candidates) {
    // 1. Try exact match first
    for (int i = 0; i < headers.length; i++) {
      for (final cand in candidates) {
        if (headers[i] == cand) return i;
      }
    }
    // 2. Fall back to contains
    for (int i = 0; i < headers.length; i++) {
      for (final cand in candidates) {
        if (headers[i].contains(cand)) return i;
      }
    }
    return -1;
  }

  /// Cleans a raw Notion stock cell like "O (https://...)" → "O"
  static String _cleanStockTicker(String raw) {
    var s = raw.trim();
    // Strip URL in parenthesis
    final paren = s.indexOf('(');
    if (paren != -1) s = s.substring(0, paren).trim();
    // Strip any trailing month suffix like "_JUN24"
    final underscore = s.indexOf('_');
    if (underscore != -1) s = s.substring(0, underscore).trim();
    return s.toUpperCase();
  }

  /// Maps the Notion `Text` field to a [PaymentType].
  static PaymentType _parsePaymentType(String rawText) {
    final t = rawText.toLowerCase().trim();
    if (t == 'fcd') return PaymentType.fcd;
    if (t == 'usd') return PaymentType.usd;
    if (t.contains('thb')) return PaymentType.thb;
    if (t.contains('ปันผล')) return PaymentType.dividend;
    return PaymentType.thb;
  }

  /// Historical USD/THB exchange rates lookup table from Invest-Stocks_USDTHB_Historical_Rates.csv
  static final Map<String, Decimal> _historicalRateMap = {
    'O|27144': Decimal.parse('36.600000'),      // 24-Jun-24
    'JEPQ|54229': Decimal.parse('36.720000'),   // 1-Jul-24
    'O|27776': Decimal.parse('35.870000'),      // 17-Jul-24
    'MSFT|28011': Decimal.parse('35.500000'),   // 31-Jul-24
    'JEPQ|29372': Decimal.parse('34.130000'),   // 20-Aug-24
    'JEPQ|32568': Decimal.parse('33.780000'),   // 1-Nov-24
    'O|20000': Decimal.parse('34.580000'),      // 18-Dec-24
    'O|33900': Decimal.parse('34.400000'),      // 5-Jan-25
    'O|26067': Decimal.parse('34.620000'),      // 8-Jan-25
    'NVDA|59014': Decimal.parse('33.720000'),   // 30-Jan-25
    'JEPQ|59084': Decimal.parse('33.850000'),   // 4-Mar-25
    'JEPQ|29205': Decimal.parse('34.200000'),   // 3-Apr-25
    'JEPQ|156812': Decimal.parse('33.450000'),  // 5-May-25
    'JEPQ|10100': Decimal.parse('32.850000'),   // 14-Sep-25
    'NVO|62853': Decimal.parse('32.100000'),    // 16-Sep-25
    'JEPQ|90000': Decimal.parse('32.400000'),   // 25-Sep-25
    'NVDA|61180': Decimal.parse('32.650000'),   // 15-Oct-25
    'JEPQ|10368': Decimal.parse('32.650000'),   // 15-Oct-25
    'QQQM|13189': Decimal.parse('31.390000'),   // 15-Jan-26
    'NVO|31496': Decimal.parse('31.550000'),    // 31-May-26
    'NVDA|24606': Decimal.parse('32.500000'),   // 12-Jun-26
  };

  static final Map<String, Decimal> _historicalRateByDateMap = {
    'O|2024-6-24': Decimal.parse('36.600000'),
    'JEPQ|2024-7-1': Decimal.parse('36.720000'),
    'O|2024-7-17': Decimal.parse('35.870000'),
    'MSFT|2024-7-31': Decimal.parse('35.500000'),
    'JEPQ|2024-8-19': Decimal.parse('34.130000'),
    'JEPQ|2024-8-20': Decimal.parse('34.130000'),
    'JEPQ|2024-11-1': Decimal.parse('33.780000'),
    'O|2024-12-18': Decimal.parse('34.580000'),
    'O|2024-11-6': Decimal.parse('34.400000'),
    'O|2025-1-5': Decimal.parse('34.400000'),
    'O|2025-1-8': Decimal.parse('34.620000'),
    'NVDA|2025-1-29': Decimal.parse('33.720000'),
    'NVDA|2025-1-30': Decimal.parse('33.720000'),
    'JEPQ|2025-3-4': Decimal.parse('33.850000'),
    'JEPQ|2025-4-3': Decimal.parse('34.200000'),
    'JEPQ|2025-5-5': Decimal.parse('33.450000'),
    'JEPQ|2025-7-16': Decimal.parse('32.850000'),
    'JEPQ|2025-9-14': Decimal.parse('32.850000'),
    'NVO|2025-9-15': Decimal.parse('32.100000'),
    'NVO|2025-9-16': Decimal.parse('32.100000'),
    'JEPQ|2025-9-24': Decimal.parse('32.400000'),
    'JEPQ|2025-9-25': Decimal.parse('32.400000'),
    'NVDA|2025-10-15': Decimal.parse('32.650000'),
    'JEPQ|2025-10-15': Decimal.parse('32.650000'),
    'QQQM|2026-1-13': Decimal.parse('31.390000'),
    'QQQM|2026-1-15': Decimal.parse('31.390000'),
    'NVO|2026-2-4': Decimal.parse('31.550000'),
    'NVO|2026-5-31': Decimal.parse('31.550000'),
    'NVDA|2026-6-12': Decimal.parse('32.500000'),
  };

  static final Map<String, Decimal> _historicalSharesMap = {
    'O|27144': Decimal.parse('5.1070555'),
    'JEPQ|54229': Decimal.parse('9.8374603'),
    'O|27776': Decimal.parse('4.8250039'),
    'MSFT|28011': Decimal.parse('0.6725491'),
    'JEPQ|29372': Decimal.parse('5.4911198'),
    'JEPQ|32568': Decimal.parse('6.0000000'),
    'O|20000': Decimal.parse('3.6706829'),
    'O|33900': Decimal.parse('6.0000000'),
    'O|26067': Decimal.parse('4.9793696'),
    'NVDA|59014': Decimal.parse('4.9219350'),
    'JEPQ|59084': Decimal.parse('10.6387075'),
    'JEPQ|29205': Decimal.parse('5.1481698'),
    'JEPQ|156812': Decimal.parse('28.1630747'),
    'JEPQ|10100': Decimal.parse('1.8390459'),
    'NVO|62853': Decimal.parse('4.8727010'),
    'JEPQ|90000': Decimal.parse('16.3636364'),
    'NVDA|61180': Decimal.parse('3.4215089'),
    'JEPQ|10368': Decimal.parse('1.8906354'),
    'QQQM|13189': Decimal.parse('0.5849885'),
    'NVO|31496': Decimal.parse('2.6619047'),
    'NVDA|24606': Decimal.parse('1.8911766'),
  };

  static final Map<String, Decimal> _historicalSharesByDateMap = {
    'O|2024-6-24': Decimal.parse('5.1070555'),
    'JEPQ|2024-7-1': Decimal.parse('9.8374603'),
    'O|2024-7-17': Decimal.parse('4.8250039'),
    'MSFT|2024-7-31': Decimal.parse('0.6725491'),
    'JEPQ|2024-8-19': Decimal.parse('5.4911198'),
    'JEPQ|2024-8-20': Decimal.parse('5.4911198'),
    'JEPQ|2024-11-1': Decimal.parse('6.0000000'),
    'O|2024-12-18': Decimal.parse('3.6706829'),
    'O|2024-11-6': Decimal.parse('6.0000000'),
    'O|2025-1-5': Decimal.parse('6.0000000'),
    'O|2025-1-8': Decimal.parse('4.9793696'),
    'NVDA|2025-1-29': Decimal.parse('4.9219350'),
    'NVDA|2025-1-30': Decimal.parse('4.9219350'),
    'JEPQ|2025-3-4': Decimal.parse('10.6387075'),
    'JEPQ|2025-4-3': Decimal.parse('5.1481698'),
    'JEPQ|2025-5-5': Decimal.parse('28.1630747'),
    'JEPQ|2025-7-16': Decimal.parse('1.8390459'),
    'JEPQ|2025-9-14': Decimal.parse('1.8390459'),
    'NVO|2025-9-15': Decimal.parse('4.8727010'),
    'NVO|2025-9-16': Decimal.parse('4.8727010'),
    'JEPQ|2025-9-24': Decimal.parse('16.3636364'),
    'JEPQ|2025-9-25': Decimal.parse('16.3636364'),
    'NVDA|2025-10-15': Decimal.parse('3.4215089'),
    'JEPQ|2025-10-15': Decimal.parse('1.8906354'),
    'QQQM|2026-1-13': Decimal.parse('0.5849885'),
    'QQQM|2026-1-15': Decimal.parse('0.5849885'),
    'NVO|2026-2-4': Decimal.parse('2.6619047'),
    'NVO|2026-5-31': Decimal.parse('2.6619047'),
    'NVDA|2026-6-12': Decimal.parse('1.8911766'),
  };
}
