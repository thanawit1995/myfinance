import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/investments_dao.dart';
import 'notion_gold_parser.dart';

class NotionGoldImportResult {
  final int imported;
  final int skippedDuplicates;
  final List<String> errors;
  final String? batchId;

  const NotionGoldImportResult({
    required this.imported,
    required this.skippedDuplicates,
    required this.errors,
    this.batchId,
  });
}

class NotionGoldImportExecutor {
  final AppDatabase _db;
  final InvestmentsDao _dao;
  static const _uuid = Uuid();

  static const _accountIdDimeFcd = '00000000-0000-4000-8000-000000000004';

  NotionGoldImportExecutor(this._db) : _dao = _db.investmentsDao;

  Future<NotionGoldImportResult> executeImport(
    List<ParsedGoldRow> rows, {
    Set<int>? selectedRowIndices,
    String? fileName,
  }) async {
    final batchId = _uuid.v4();
    final batchNow = DateTime.now();

    await _db.importBatchesDao.createBatch(
      ImportBatchesCompanion.insert(
        id: batchId,
        fileName: fileName ?? 'Notion Gold.csv',
        templateType: const Value('notion_invest_gold'),
        totalImported: 0,
        importedAt: batchNow,
        isRolledBack: const Value(false),
        createdAt: batchNow,
        updatedAt: batchNow,
      ),
    );

    int imported = 0;
    int skippedDuplicates = 0;
    final errors = <String>[];

    final existingLots = await (_db.select(_db.investmentLots)
          ..where((l) => l.deletedAt.isNull()))
        .get();
    final existingKeys = <String>{};
    for (final lot in existingLots) {
      existingKeys.add('${lot.assetId}_${lot.quantity}');
    }

    final assetCache = <String, Asset>{};

    for (final row in rows) {
      if (selectedRowIndices != null && !selectedRowIndices.contains(row.rowIndex)) {
        continue;
      }

      try {
        final asset = await _findOrCreateAsset(row.symbol, row.name, assetCache);
        final key = '${asset.id}_${row.quantity}';

        if (existingKeys.contains(key)) {
          skippedDuplicates++;
          row.isDuplicate = true;
          continue;
        }

        // Default to Dime! FCD or any FCD/USD account
        final accounts = await _db.accountsDao.getActiveAccounts();
        final dimeFcd = accounts.where((a) => a.name.trim().toLowerCase() == 'dime! fcd' || a.name.trim().toLowerCase() == 'dime fcd').firstOrNull;
        String accountId = dimeFcd?.id ?? _accountIdDimeFcd;

        if (accounts.isEmpty || !accounts.any((a) => a.id == accountId)) {
          final now = DateTime.now();
          await _db.accountsDao.createAccount(
            AccountsCompanion.insert(
              id: _accountIdDimeFcd,
              name: 'Dime! FCD',
              accountType: 'fcd',
              currencyCode: 'USD',
              isDomestic: true,
              createdAt: now,
              updatedAt: now,
            ),
          );
          accountId = _accountIdDimeFcd;
        }

        final int priceSatang = (row.unitCostUsd * Decimal.fromInt(100)).round().toBigInt().toInt();

        // 1. Record Buy Trade (USD Gold)
        await _dao.recordBuyTrade(
          assetId: asset.id,
          accountId: accountId,
          tradeDate: row.recordDate,
          quantity: row.quantity,
          priceOriginalSatang: priceSatang,
          pricePerUnitOriginal: row.unitCostUsd,
          currencyCode: 'USD',
          fxRate: row.fxRate,
          feeThbSatang: 0,
          note: 'Imported from Notion — ${row.symbol}',
          importBatchId: batchId,
        );

        // 2. Record latest market price if available
        if (row.marketPriceUsd > Decimal.zero) {
          final marketPriceSatang = (row.marketPriceUsd * Decimal.fromInt(100)).round().toBigInt().toInt();
          await _dao.recordAssetPrice(
            assetId: asset.id,
            priceDate: DateTime.now(),
            marketPriceOriginalSatang: marketPriceSatang,
            marketPriceOriginal: row.marketPriceUsd,
            fxRate: row.fxRate,
          );
        }

        existingKeys.add(key);
        imported++;
      } catch (e) {
        errors.add('Row ${row.rowIndex} (${row.symbol}): $e');
      }
    }

    // Update total imported in the batch
    await (_db.update(_db.importBatches)..where((t) => t.id.equals(batchId))).write(
      ImportBatchesCompanion(
        totalImported: Value(imported),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return NotionGoldImportResult(
      imported: imported,
      skippedDuplicates: skippedDuplicates,
      errors: errors,
      batchId: batchId,
    );
  }

  Future<Asset> _findOrCreateAsset(
    String symbol,
    String name,
    Map<String, Asset> cache,
  ) async {
    if (cache.containsKey(symbol)) return cache[symbol]!;

    final existing = await (_db.select(_db.assets)
          ..where((a) => a.symbol.equals(symbol) & a.deletedAt.isNull()))
        .getSingleOrNull();

    if (existing != null) {
      cache[symbol] = existing;
      return existing;
    }

    final now = DateTime.now();
    final newId = _uuid.v4();

    await _dao.createAsset(
      AssetsCompanion.insert(
        id: newId,
        symbol: symbol,
        name: name,
        assetType: 'gold',
        currencyCode: 'USD',
        defaultAccountId: _accountIdDimeFcd,
        note: const Value('ทองคำดิจิทัล (MST-GOLD)'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final created = (await _dao.getAssetById(newId))!;
    cache[symbol] = created;
    return created;
  }
}
