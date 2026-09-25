import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/investments_dao.dart';
import 'notion_funds_parser.dart';

class NotionFundsImportResult {
  final int imported;
  final int skippedDuplicates;
  final List<String> errors;

  const NotionFundsImportResult({
    required this.imported,
    required this.skippedDuplicates,
    required this.errors,
  });
}

class NotionFundsImportExecutor {
  final AppDatabase _db;
  final InvestmentsDao _dao;
  static const _uuid = Uuid();

  static const _accountIdScb = '00000000-0000-4000-8000-000000000001';

  NotionFundsImportExecutor(this._db) : _dao = _db.investmentsDao;

  Future<NotionFundsImportResult> executeImport(
    List<ParsedFundRow> rows, {
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
        final asset = await _findOrCreateAsset(row.symbol, row.name, row.subType, assetCache);
        final key = '${asset.id}_${row.quantity}';

        if (existingKeys.contains(key)) {
          skippedDuplicates++;
          row.isDuplicate = true;
          continue;
        }

        // Default to SCB account or first THB account
        String accountId = _accountIdScb;
        final accounts = await _db.accountsDao.getActiveAccounts();
        final thbAccounts = accounts.where((a) => a.currencyCode == 'THB').toList();
        if (accounts.isEmpty) {
          final now = DateTime.now();
          await _db.accountsDao.createAccount(
            AccountsCompanion.insert(
              id: _accountIdScb,
              name: 'SCB',
              accountType: 'bank',
              currencyCode: 'THB',
              isDomestic: true,
              createdAt: now,
              updatedAt: now,
            ),
          );
        } else if (thbAccounts.isNotEmpty && !accounts.any((a) => a.id == accountId)) {
          accountId = thbAccounts.first.id;
        } else if (!accounts.any((a) => a.id == accountId)) {
          accountId = accounts.first.id;
        }

        final int priceSatang = (row.unitCostThb * Decimal.fromInt(100)).round().toBigInt().toInt();

        // 1. Record Buy Trade
        await _dao.recordBuyTrade(
          assetId: asset.id,
          accountId: accountId,
          tradeDate: row.buyDate,
          quantity: row.quantity,
          priceOriginalSatang: priceSatang,
          pricePerUnitOriginal: row.unitCostThb,
          currencyCode: 'THB',
          fxRate: Decimal.one,
          feeThbSatang: 0,
          note: 'Imported from Notion — ${row.symbol} (${row.platform})',
        );

        // 2. Record latest NAV price if available
        if (row.currentNav > Decimal.zero) {
          final navSatang = (row.currentNav * Decimal.fromInt(100)).round().toBigInt().toInt();
          await _dao.recordAssetPrice(
            assetId: asset.id,
            priceDate: DateTime.now(),
            marketPriceOriginalSatang: navSatang,
            marketPriceOriginal: row.currentNav,
            fxRate: Decimal.one,
          );
        }

        existingKeys.add(key);
        imported++;
      } catch (e) {
        errors.add('Row ${row.rowIndex} (${row.symbol}): $e');
      }
    }

    return NotionFundsImportResult(
      imported: imported,
      skippedDuplicates: skippedDuplicates,
      errors: errors,
    );
  }

  Future<Asset> _findOrCreateAsset(
    String symbol,
    String name,
    String? subType,
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
        assetType: 'mutual_fund',
        currencyCode: 'THB',
        defaultAccountId: _accountIdScb,
        note: Value(subType != null ? 'หมวด: $subType' : null),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final created = (await _dao.getAssetById(newId))!;
    cache[symbol] = created;
    return created;
  }
}
