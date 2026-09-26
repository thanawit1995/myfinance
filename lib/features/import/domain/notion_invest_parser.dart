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
    final thbCol     = _findCol(headers, ['thb invested', 'thb']);
    final textCol    = _findCol(headers, ['text']);

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

      // Parse shares quantity
      Decimal quantity;
      try {
        final cleaned = rawShares.replaceAll(RegExp(r'[^0-9.]'), '');
        quantity = cleaned.isEmpty ? Decimal.zero : Decimal.parse(cleaned);
      } catch (_) {
        quantity = Decimal.zero;
      }
      if (quantity == Decimal.zero) continue;

      // FX Rate: Fixed at 33.65 as specified by user
      final Decimal fxRate = Decimal.parse('33.650000');

      // Parse USD invested amount
      int amountUsdSatang = CsvImportParser.parseAmountSatang(rawInvested);

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
    if (t.contains('ปันผล')) return PaymentType.dividend;
    if (t == 'fcd') return PaymentType.fcd;
    if (t == 'usd') return PaymentType.usd;
    // "THB" or "THB + ปันผล" without "ปันผล only" → THB buy
    return PaymentType.thb;
  }
}
