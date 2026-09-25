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

  const NotionGoldImportResult({
    required this.imported,
    required this.skippedDuplicates,
    required this.errors,
  });
}

class NotionGoldImportExecutor {
  final AppDatabase _db;
  final InvestmentsDao _dao;
  static const _uuid = Uuid();

  static const _accountIdDimeUsd = '00000000-0000-4000-8000-000000000005';

  NotionGoldImportExecutor(this._db) : _dao = _db.investmentsDao;

  Future<NotionGoldImportResult> executeImport(
    List<ParsedGoldRow> rows, {
    Set<int>? selectedRowIndices,
  }) async {
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

        // Default to Dime! USD or any USD account, fallback to first account
        String accountId = _accountIdDimeUsd;
        final accounts = await _db.accountsDao.getActiveAccounts();
        final usdAccounts = accounts.where((a) => a.currencyCode == 'USD').toList();
        if (accounts.isEmpty) {
          final now = DateTime.now();
          await _db.accountsDao.createAccount(
            AccountsCompanion.insert(
              id: _accountIdDimeUsd,
              name: 'Dime! USD',
              accountType: 'bank',
              currencyCode: 'USD',
              isDomestic: false,
              createdAt: now,
              updatedAt: now,
            ),
          );
        } else if (usdAccounts.isNotEmpty && !accounts.any((a) => a.id == accountId)) {
          accountId = usdAccounts.first.id;
        } else if (!accounts.any((a) => a.id == accountId)) {
          accountId = accounts.first.id;
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

    return NotionGoldImportResult(
      imported: imported,
      skippedDuplicates: skippedDuplicates,
      errors: errors,
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
        defaultAccountId: _accountIdDimeUsd,
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
