import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/investments_dao.dart';
import 'notion_invest_parser.dart';

/// Result object returned after executing a Notion Invest import.
class NotionInvestImportResult {
  final int imported;
  final int skippedDuplicates;
  final int skippedDividends;
  final List<String> errors;

  const NotionInvestImportResult({
    required this.imported,
    required this.skippedDuplicates,
    required this.skippedDividends,
    required this.errors,
  });
}

/// Executes the import of parsed Notion Invest-Stocks rows into the database.
///
/// For each [ParsedInvestRow]:
/// - Finds or auto-creates an [Asset] for the ticker
/// - Maps [PaymentType] to the correct source account
/// - Calls [InvestmentsDao.recordBuyTrade] (which atomically creates
///   the Transaction + InvestmentLot + AuditLog)
/// - Skips dividend rows (recorded separately as income is not supported yet)
/// - Detects duplicate lots by (assetId + buyDate + quantity string)
class NotionInvestImportExecutor {
  final AppDatabase _db;
  final InvestmentsDao _dao;
  static const _uuid = Uuid();

  // Fixed seed account IDs (from seed_data.dart)
  static const _accountIdKrungthai = '00000000-0000-4000-8000-000000000002';
  static const _accountIdDimeFcd   = '00000000-0000-4000-8000-000000000004';
  static const _accountIdDimeUsd   = '00000000-0000-4000-8000-000000000005';

  NotionInvestImportExecutor(this._db) : _dao = _db.investmentsDao;

  /// Runs the import for [rows] that are selected by the user.
  /// Returns a [NotionInvestImportResult] summarising what happened.
  Future<NotionInvestImportResult> executeImport(
    List<ParsedInvestRow> rows, {
    Set<int>? selectedRowIndices, // if null → import all non-duplicate
  }) async {
    int imported = 0;
    int skippedDuplicates = 0;
    int skippedDividends = 0;
    final errors = <String>[];

    // Pre-load existing lots to detect duplicates
    final existingLots = await (_db.select(_db.investmentLots)
          ..where((l) => l.deletedAt.isNull()))
        .get();
    final existingKeys = <String>{};
    for (final lot in existingLots) {
      existingKeys.add(_lotKey(lot.assetId, lot.buyDate, lot.quantity));
    }

    // Cache for asset symbol → Asset (avoids repeated DB reads per row)
    final assetCache = <String, Asset>{};

    for (final row in rows) {
      // Apply row selection filter
      if (selectedRowIndices != null && !selectedRowIndices.contains(row.rowIndex)) {
        continue;
      }

      // Skip dividends — not imported as buy trades
      if (row.paymentType == PaymentType.dividend) {
        skippedDividends++;
        continue;
      }

      try {
        // 1. Find or create Asset
        final asset = await _findOrCreateAsset(row.ticker, assetCache);

        // 2. Duplicate check
        final key = _lotKey(asset.id, row.buyDate, row.quantity.toStringAsFixed(8));
        if (existingKeys.contains(key)) {
          skippedDuplicates++;
          row.isDuplicate = true;
          continue;
        }

        // 3. Resolve source account
        final accountId = _resolveAccountId(row.paymentType);

        // 4. Compute per-share price (in USD satang)
        // price = totalUSD / quantity
        final pricePerShareSatang = _computePricePerShare(
          row.amountUsdSatang,
          row.quantity,
          row.amountThbSatang,
          row.fxRate,
          row.paymentType,
        );

        // 5. Currency code
        final currencyCode = row.paymentType == PaymentType.thb ? 'THB' : 'USD';
        final fxRate = row.paymentType == PaymentType.thb ? Decimal.one : row.fxRate;

        // 6. Record buy trade via DAO (atomic: Transaction + Lot + Audit)
        await _dao.recordBuyTrade(
          assetId: asset.id,
          accountId: accountId,
          tradeDate: row.buyDate,
          quantity: row.quantity,
          priceOriginalSatang: pricePerShareSatang,
          pricePerUnitOriginal: row.unitPriceOriginal > Decimal.zero ? row.unitPriceOriginal : null,
          currencyCode: currencyCode,
          fxRate: fxRate,
          feeThbSatang: 0,
          note: 'Imported from Notion — ${row.ticker} (${row.paymentType.name})',
        );

        // 7. Add to in-memory duplicate set so subsequent rows with same key are skipped
        existingKeys.add(key);
        imported++;
      } catch (e) {
        errors.add('Row ${row.rowIndex} (${row.ticker}): $e');
      }
    }

    return NotionInvestImportResult(
      imported: imported,
      skippedDuplicates: skippedDuplicates,
      skippedDividends: skippedDividends,
      errors: errors,
    );
  }

  // ─── Private Helpers ───────────────────────────────────────────────────────

  Future<Asset> _findOrCreateAsset(String ticker, Map<String, Asset> cache) async {
    if (cache.containsKey(ticker)) return cache[ticker]!;

    // Search by symbol (case-insensitive)
    final assets = await (_db.select(_db.assets)
          ..where((a) => a.deletedAt.isNull()))
        .get();
    final existing = assets.where((a) => a.symbol.toLowerCase() == ticker.toLowerCase()).firstOrNull;

    if (existing != null) {
      cache[ticker] = existing;
      return existing;
    }

    // Auto-create a new asset record
    final id = _uuid.v4();
    final now = DateTime.now();
    await _dao.createAsset(
      AssetsCompanion.insert(
        id: id,
        symbol: ticker,
        name: ticker, // user can rename later
        assetType: 'foreign_stock',
        currencyCode: 'USD',
        defaultAccountId: _accountIdDimeUsd,
        market: const Value('NYSE/NASDAQ'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final created = await _dao.getAssetById(id);
    if (created == null) throw StateError('Failed to create asset for ticker $ticker');
    cache[ticker] = created;
    return created;
  }

  String _resolveAccountId(PaymentType type) {
    switch (type) {
      case PaymentType.fcd:
        return _accountIdDimeFcd;
      case PaymentType.usd:
        return _accountIdDimeUsd;
      case PaymentType.thb:
      case PaymentType.dividend:
        return _accountIdKrungthai;
    }
  }

  /// Computes the price per share in the original currency (USD satang usually).
  /// For THB payments: price is in THB satang (fxRate = 1).
  int _computePricePerShare(
    int amountUsdSatang,
    Decimal quantity,
    int amountThbSatang,
    Decimal fxRate,
    PaymentType type,
  ) {
    if (quantity == Decimal.zero) return 0;

    if (type == PaymentType.thb) {
      // Return THB price per share
      return (Decimal.fromInt(amountThbSatang) / quantity)
          .round()
          .toInt();
    }

    if (amountUsdSatang > 0) {
      return (Decimal.fromInt(amountUsdSatang) / quantity)
          .round()
          .toInt();
    }

    // Fallback: back-compute USD from THB and fxRate
    if (amountThbSatang > 0 && fxRate > Decimal.zero) {
      final usdSatang = (Decimal.fromInt(amountThbSatang) / fxRate)
          .round()
          .toInt();
      return (Decimal.fromInt(usdSatang) / quantity).round().toInt();
    }

    return 0;
  }

  /// Unique key for duplicate detection.
  String _lotKey(String assetId, DateTime date, String quantityStr) {
    final d = '${date.year}-${date.month}-${date.day}';
    // Normalise quantity to 8dp for comparison
    Decimal q;
    try {
      q = Decimal.parse(quantityStr);
    } catch (_) {
      q = Decimal.zero;
    }
    return '$assetId|$d|${q.toStringAsFixed(8)}';
  }
}
