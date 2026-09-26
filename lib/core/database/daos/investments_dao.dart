import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/all_tables.dart';
import '../../../features/investments/domain/fifo_engine.dart';

part 'investments_dao.g.dart';

class PortfolioAssetHolding {
  final Asset asset;
  final Decimal totalQuantity;
  final int totalCostThbSatang;
  final int currentPriceOriginalSatang;
  final Decimal? currentPriceOriginal;
  final Decimal currentFxRate;
  final int currentPriceThbSatang;
  final int currentValueThbSatang;
  final int unrealizedPriceGainLossThbSatang;
  final int unrealizedFxGainLossThbSatang;
  final int totalUnrealizedGainLossThbSatang;

  const PortfolioAssetHolding({
    required this.asset,
    required this.totalQuantity,
    required this.totalCostThbSatang,
    required this.currentPriceOriginalSatang,
    this.currentPriceOriginal,
    required this.currentFxRate,
    required this.currentPriceThbSatang,
    required this.currentValueThbSatang,
    required this.unrealizedPriceGainLossThbSatang,
    required this.unrealizedFxGainLossThbSatang,
    required this.totalUnrealizedGainLossThbSatang,
  });
}

class PortfolioSummary {
  final int totalValueThbSatang;
  final int totalCostThbSatang;
  final int totalUnrealizedPriceGainLossThbSatang;
  final int totalUnrealizedFxGainLossThbSatang;
  final int totalUnrealizedGainLossThbSatang;
  final List<PortfolioAssetHolding> holdings;
  final List<Asset> uninvestedAssets;

  const PortfolioSummary({
    required this.totalValueThbSatang,
    required this.totalCostThbSatang,
    required this.totalUnrealizedPriceGainLossThbSatang,
    required this.totalUnrealizedFxGainLossThbSatang,
    required this.totalUnrealizedGainLossThbSatang,
    required this.holdings,
    this.uninvestedAssets = const [],
  });
}

class RealizedGainLossAssetSummary {
  final Asset asset;
  final Decimal quantitySold;
  final Decimal quantityBought;
  final Decimal netQuantity;
  final int totalCostThbSatang; // ต้นทุน/เงินต้นของหุ้นที่ขาย
  final int totalSellPriceThbSatang; // มูลค่าขายรวม
  final int realizedGainLossThbSatang; // กำไร/ขาดทุนสุทธิ
  final int priceGainLossThbSatang; // กำไรจากราคา
  final int fxGainLossThbSatang; // กำไรจากอัตราแลกเปลี่ยน
  final int feeThbSatang;
  final int totalBuyCostThbSatang; // เงินต้นที่ซื้อใหม่ในปีนั้น

  const RealizedGainLossAssetSummary({
    required this.asset,
    required this.quantitySold,
    required this.quantityBought,
    required this.netQuantity,
    required this.totalCostThbSatang,
    required this.totalSellPriceThbSatang,
    required this.realizedGainLossThbSatang,
    required this.priceGainLossThbSatang,
    required this.fxGainLossThbSatang,
    required this.feeThbSatang,
    required this.totalBuyCostThbSatang,
  });
}

class RealizedGainLossYearSummary {
  final int year;
  final int totalRealizedGainLossThbSatang;
  final int totalPriceGainLossThbSatang;
  final int totalFxGainLossThbSatang;
  final int totalFeeThbSatang;
  final int totalCostThbSatang; // เงินต้นทั้งหมดของหุ้นที่ขายในปีนั้น
  final int totalSellPriceThbSatang; // ยอดขายรวมทั้งหมดในปีนั้น
  final int totalBuyCostThbSatang; // เงินต้นทั้งหมดที่ซื้อใหม่ในปีนั้น
  final List<RealizedGainLossAssetSummary> assetSummaries;

  const RealizedGainLossYearSummary({
    required this.year,
    required this.totalRealizedGainLossThbSatang,
    required this.totalPriceGainLossThbSatang,
    required this.totalFxGainLossThbSatang,
    required this.totalFeeThbSatang,
    this.totalCostThbSatang = 0,
    this.totalSellPriceThbSatang = 0,
    this.totalBuyCostThbSatang = 0,
    this.assetSummaries = const [],
  });
}

class InvestmentTradeRecord {
  final String id;
  final DateTime tradeDate;
  final String tradeType; // 'buy' or 'sell'
  final Asset? asset;
  final Decimal quantity;
  final int priceOriginalSatang;
  final String currencyCode;
  final Decimal fxRate;
  final int totalThbSatang;
  final int feeThbSatang;
  final int? costThbSatang;
  final int? realizedGainLossThbSatang;
  final String? accountName;
  final String? note;

  const InvestmentTradeRecord({
    required this.id,
    required this.tradeDate,
    required this.tradeType,
    this.asset,
    required this.quantity,
    required this.priceOriginalSatang,
    required this.currencyCode,
    required this.fxRate,
    required this.totalThbSatang,
    required this.feeThbSatang,
    this.costThbSatang,
    this.realizedGainLossThbSatang,
    this.accountName,
    this.note,
  });
}

@DriftAccessor(tables: [
  Assets,
  InvestmentLots,
  InvestmentSales,
  AssetPrices,
  InvestmentIncomes,
  Transactions,
  FxRates,
  Currencies,
  Accounts,
  AuditLogs,
])
class InvestmentsDao extends DatabaseAccessor<AppDatabase> with _$InvestmentsDaoMixin {
  InvestmentsDao(super.db);

  static const _uuid = Uuid();

  // -------------------------------------------------------------
  // 1. ASSETS REGISTRY CRUD
  // -------------------------------------------------------------

  Stream<List<Asset>> watchAssets() {
    return (select(assets)
          ..where((a) => a.deletedAt.isNull())
          ..orderBy([(a) => OrderingTerm.asc(a.symbol)]))
        .watch();
  }

  Future<List<Asset>> getAssets() {
    return (select(assets)
          ..where((a) => a.deletedAt.isNull())
          ..orderBy([(a) => OrderingTerm.asc(a.symbol)]))
        .get();
  }

  Future<Asset?> getAssetById(String id) {
    return (select(assets)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  Future<int> createAsset(AssetsCompanion entry) async {
    final now = DateTime.now();
    final result = await into(assets).insert(entry);

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'assets',
        entityId: entry.id.value,
        action: 'CREATE',
        afterDataJson: Value(jsonEncode({
          'id': entry.id.value,
          'symbol': entry.symbol.value,
          'name': entry.name.value,
          'assetType': entry.assetType.value,
        })),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return result;
  }

  Future<bool> updateAsset(AssetsCompanion entry) async {
    final before = await getAssetById(entry.id.value);
    if (before == null) return false;

    final now = DateTime.now();
    final count = await (update(assets)..where((a) => a.id.equals(entry.id.value))).write(entry);

    if (count > 0) {
      await into(auditLogs).insert(
        AuditLogsCompanion.insert(
          id: _uuid.v4(),
          entityTable: 'assets',
          entityId: entry.id.value,
          action: 'UPDATE',
          beforeDataJson: Value(jsonEncode({
            'symbol': before.symbol,
            'name': before.name,
            'assetType': before.assetType,
          })),
          afterDataJson: Value(jsonEncode({
            'symbol': entry.symbol.present ? entry.symbol.value : before.symbol,
            'name': entry.name.present ? entry.name.value : before.name,
          })),
          changeTimestamp: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    return count > 0;
  }

  Future<bool> softDeleteAsset(String id) async {
    final now = DateTime.now();
    final count = await (update(assets)..where((a) => a.id.equals(id))).write(
      AssetsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return count > 0;
  }

  /// Returns all soft-deleted assets currently in the trash bin.
  Future<List<Asset>> getDeletedAssets() {
    return (select(assets)
          ..where((a) => a.deletedAt.isNotNull())
          ..orderBy([(a) => OrderingTerm.desc(a.deletedAt)]))
        .get();
  }

  /// Restores a soft-deleted asset from the trash bin.
  Future<bool> restoreAsset(String id) async {
    final now = DateTime.now();
    final count = await (update(assets)..where((a) => a.id.equals(id))).write(
      AssetsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
    return count > 0;
  }

  /// Permanently deletes an asset and its associated prices, sales, and lots (Hard Delete).
  Future<void> permanentlyDeleteAsset(String assetId) async {
    // 1. Delete associated asset prices
    await (delete(assetPrices)..where((p) => p.assetId.equals(assetId))).go();

    // 2. Find all lots for asset
    final lots = await (select(investmentLots)..where((l) => l.assetId.equals(assetId))).get();
    final lotIds = lots.map((l) => l.id).toList();

    // 3. Delete sales associated with lots
    if (lotIds.isNotEmpty) {
      await (delete(investmentSales)..where((s) => s.lotId.isIn(lotIds))).go();
    }

    // 4. Delete lots
    await (delete(investmentLots)..where((l) => l.assetId.equals(assetId))).go();

    // 5. Delete asset
    await (delete(assets)..where((a) => a.id.equals(assetId))).go();
  }

  /// Cleans up any assets that have been in the trash for more than 30 days.
  Future<int> cleanupExpiredDeletedAssets() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final expired = await (select(assets)..where((a) => a.deletedAt.isSmallerOrEqualValue(cutoff))).get();

    for (final asset in expired) {
      await permanentlyDeleteAsset(asset.id);
    }
    return expired.length;
  }

  Future<List<InvestmentSale>> getSalesForLot(String lotId) {
    return (select(investmentSales)
          ..where((s) => s.lotId.equals(lotId) & s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.asc(s.sellDate)]))
        .get();
  }

  // -------------------------------------------------------------
  // 2. BUY TRADE
  // -------------------------------------------------------------

  Future<String> recordBuyTrade({
    required String assetId,
    required String accountId,
    required DateTime tradeDate,
    required Decimal quantity,
    required int priceOriginalSatang,
    Decimal? pricePerUnitOriginal,
    required String currencyCode,
    required Decimal fxRate,
    required int feeThbSatang,
    String? note,
  }) async {
    final now = DateTime.now();
    final txId = _uuid.v4();
    final lotId = _uuid.v4();

    final asset = await getAssetById(assetId);
    final symbol = asset?.symbol ?? 'ASSET';

    final totalCostThbSatang = FifoEngine.calculateBuyTotalCostThbSatang(
      quantity: quantity,
      costPerUnitOriginalSatang: priceOriginalSatang,
      pricePerUnitOriginal: pricePerUnitOriginal,
      fxRate: fxRate,
      feeThbSatang: feeThbSatang,
    );

    final Decimal unitPriceOriginal = pricePerUnitOriginal ??
        (Decimal.fromInt(priceOriginalSatang) * Decimal.parse('0.01'));
    final Decimal unitPriceThb = unitPriceOriginal * fxRate;

    final costPerUnitThbSatang = (unitPriceThb * Decimal.fromInt(100)).round().toBigInt().toInt();
    final effectivePriceOriginalSatang = (unitPriceOriginal * Decimal.fromInt(100)).round().toBigInt().toInt();

    final amountOriginalSatang = (quantity * unitPriceOriginal * Decimal.fromInt(100)).round().toBigInt().toInt();
    final amountThbSatang = (Decimal.fromInt(amountOriginalSatang) * fxRate).round().toBigInt().toInt();

    // 1. Record FX Rate if not THB
    if (currencyCode != 'THB' && fxRate != Decimal.one) {
      await into(fxRates).insert(
        FxRatesCompanion.insert(
          id: _uuid.v4(),
          baseCurrency: currencyCode,
          targetCurrency: 'THB',
          rate: fxRate.toString(),
          effectiveDate: tradeDate,
          note: Value('Auto-recorded from BUY $symbol trade'),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // 2. Record Transaction in ledger (expense from sourceAccountId)
    final investmentCategory = await attachedDatabase.categoriesDao.getOrCreateInvestmentExpenseCategory();

    await into(transactions).insert(
      TransactionsCompanion.insert(
        id: txId,
        transactionType: 'expense',
        categoryId: Value(investmentCategory.id),
        amountOriginalSatang: amountOriginalSatang,
        currencyCode: currencyCode,
        fxRate: Value(fxRate.toString()),
        amountThbSatang: amountThbSatang,
        feeThbSatang: Value(feeThbSatang),
        sourceAccountId: Value(accountId),
        transactionDate: tradeDate,
        note: Value(note ?? 'ซื้อ $symbol $quantity หน่วย @ $unitPriceOriginal $currencyCode'),
        tag: Value('investment_buy:$assetId'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // 3. Record Investment Lot
    await into(investmentLots).insert(
      InvestmentLotsCompanion.insert(
        id: lotId,
        assetId: assetId,
        buyTransactionId: txId,
        buyDate: tradeDate,
        quantity: quantity.toString(),
        remainingQuantity: quantity.toString(),
        costPerUnitOriginalSatang: effectivePriceOriginalSatang,
        fxRate: fxRate.toString(),
        costPerUnitThbSatang: costPerUnitThbSatang,
        pricePerUnitOriginal: Value(unitPriceOriginal.toString()),
        pricePerUnitThb: Value(unitPriceThb.toString()),
        feeThbSatang: feeThbSatang,
        totalCostThbSatang: Value(totalCostThbSatang),
        remainingCostThbSatang: Value(totalCostThbSatang),
        status: 'open',
        createdAt: now,
        updatedAt: now,
      ),
    );

    // 4. Audit Log
    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'investment_lots',
        entityId: lotId,
        action: 'CREATE_BUY_LOT',
        afterDataJson: Value(jsonEncode({
          'lotId': lotId,
          'assetId': assetId,
          'quantity': quantity.toString(),
          'priceOriginal': priceOriginalSatang,
          'fxRate': fxRate.toString(),
          'totalCostThb': totalCostThbSatang,
        })),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return lotId;
  }

  // -------------------------------------------------------------
  // 3. SELL TRADE (FIFO LOT CONSUMPTION)
  // -------------------------------------------------------------

  Future<FifoSellResult> recordSellTrade({
    required String assetId,
    required String accountId,
    required DateTime tradeDate,
    required Decimal quantity,
    required int priceOriginalSatang,
    Decimal? pricePerUnitOriginal,
    required String currencyCode,
    required Decimal fxRate,
    required int feeThbSatang,
    String? note,
  }) async {
    final now = DateTime.now();
    final txId = _uuid.v4();

    final asset = await getAssetById(assetId);
    final symbol = asset?.symbol ?? 'ASSET';

    final Decimal unitSellPrice = pricePerUnitOriginal ??
        (Decimal.fromInt(priceOriginalSatang) * Decimal.parse('0.01'));

    // 1. Fetch open lots for asset
    final lotRows = await (select(investmentLots)
          ..where((l) =>
              l.assetId.equals(assetId) &
              l.deletedAt.isNull() &
              l.status.isNotValue('closed'))
          ..orderBy([(l) => OrderingTerm.asc(l.buyDate), (l) => OrderingTerm.asc(l.createdAt)]))
        .get();

    final openLots = lotRows.map((r) {
      return LotState(
        id: r.id,
        assetId: r.assetId,
        buyDate: r.buyDate,
        createdAt: r.createdAt,
        quantity: Decimal.parse(r.quantity),
        remainingQuantity: Decimal.parse(r.remainingQuantity),
        costPerUnitOriginalSatang: r.costPerUnitOriginalSatang,
        pricePerUnitOriginal: r.pricePerUnitOriginal != null ? Decimal.tryParse(r.pricePerUnitOriginal!) : null,
        fxRate: Decimal.parse(r.fxRate),
        costPerUnitThbSatang: r.costPerUnitThbSatang,
        feeThbSatang: r.feeThbSatang,
        totalCostThbSatang: r.totalCostThbSatang,
        remainingCostThbSatang: r.remainingCostThbSatang,
        status: r.status,
      );
    }).toList();

    // 2. Process FIFO Sell
    final sellResult = FifoEngine.processSell(
      openLots: openLots,
      sellQuantity: quantity,
      sellPriceOriginalSatang: priceOriginalSatang,
      pricePerUnitOriginal: unitSellPrice,
      sellFxRate: fxRate,
      sellFeeThbSatang: feeThbSatang,
    );

    // 3. Record FX Rate if not THB
    if (currencyCode != 'THB' && fxRate != Decimal.one) {
      await into(fxRates).insert(
        FxRatesCompanion.insert(
          id: _uuid.v4(),
          baseCurrency: currencyCode,
          targetCurrency: 'THB',
          rate: fxRate.toString(),
          effectiveDate: tradeDate,
          note: Value('Auto-recorded from SELL $symbol trade'),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // 4. Record Transaction in ledger (income proceeds into destinationAccountId)
    final amountOriginalSatang = (quantity * unitSellPrice * Decimal.fromInt(100)).round().toBigInt().toInt();
    final saleCategory = await attachedDatabase.categoriesDao.getOrCreateAssetSaleCategory();

    await into(transactions).insert(
      TransactionsCompanion.insert(
        id: txId,
        transactionType: 'income',
        categoryId: Value(saleCategory.id),
        taxCategory: const Value('non_taxable'),
        amountOriginalSatang: amountOriginalSatang,
        currencyCode: currencyCode,
        fxRate: Value(fxRate.toString()),
        amountThbSatang: sellResult.totalSellPriceThbSatang,
        feeThbSatang: Value(feeThbSatang),
        destinationAccountId: Value(accountId),
        transactionDate: tradeDate,
        note: Value(note ?? 'ขาย $symbol $quantity หน่วย @ $unitSellPrice $currencyCode'),
        tag: Value('investment_sell:$assetId'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // 5. Update lots and insert investment_sales
    for (final consumption in sellResult.consumptions) {
      final updatedLotState = openLots.firstWhere((l) => l.id == consumption.lotId);

      // Update lot in DB
      await (update(investmentLots)..where((l) => l.id.equals(consumption.lotId))).write(
        InvestmentLotsCompanion(
          remainingQuantity: Value(updatedLotState.remainingQuantity.toString()),
          remainingCostThbSatang: Value(updatedLotState.remainingCostThbSatang),
          status: Value(updatedLotState.status),
          updatedAt: Value(now),
        ),
      );

      // Record in investment_sales
      await into(investmentSales).insert(
        InvestmentSalesCompanion.insert(
          id: _uuid.v4(),
          sellTransactionId: txId,
          lotId: consumption.lotId,
          sellDate: tradeDate,
          quantitySold: consumption.quantitySold.toString(),
          sellPriceThbSatang: consumption.sellPriceThbSatang,
          costThbSatang: consumption.costThbSatang,
          realizedGainLossThbSatang: consumption.realizedGainLossThbSatang,
          priceGainLossThbSatang: Value(consumption.priceGainLossThbSatang),
          fxGainLossThbSatang: Value(consumption.fxGainLossThbSatang),
          sellFxRate: Value(consumption.sellFxRate.toString()),
          buyFxRate: Value(consumption.buyFxRate.toString()),
          feeThbSatang: consumption.feeThbSatang,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // 6. Audit Log
    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'investment_sales',
        entityId: txId,
        action: 'EXECUTE_FIFO_SELL',
        afterDataJson: Value(jsonEncode({
          'assetId': assetId,
          'sellTransactionId': txId,
          'quantitySold': quantity.toString(),
          'totalRealizedGainLossThb': sellResult.totalRealizedGainLossThbSatang,
          'totalPriceGainLossThb': sellResult.totalPriceGainLossThbSatang,
          'totalFxGainLossThb': sellResult.totalFxGainLossThbSatang,
        })),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    return sellResult;
  }

  // -------------------------------------------------------------
  // 4. FIFO RECALCULATION ON PAST TRANSACTION EDIT / DELETE
  // -------------------------------------------------------------

  Future<void> recalculateFifoForAsset(String assetId) async {
    final now = DateTime.now();

    // 1. Reset all non-deleted lots for this asset
    final allLots = await (select(investmentLots)
          ..where((l) => l.assetId.equals(assetId) & l.deletedAt.isNull())
          ..orderBy([(l) => OrderingTerm.asc(l.buyDate), (l) => OrderingTerm.asc(l.createdAt)]))
        .get();

    for (final lot in allLots) {
      await (update(investmentLots)..where((l) => l.id.equals(lot.id))).write(
        InvestmentLotsCompanion(
          remainingQuantity: Value(lot.quantity),
          remainingCostThbSatang: Value(lot.totalCostThbSatang),
          status: const Value('open'),
          updatedAt: Value(now),
        ),
      );
    }

    // 2. Delete all investment_sales records linked to this asset's lots (both active and soft-deleted)
    final allAssetLots = await (select(investmentLots)..where((l) => l.assetId.equals(assetId))).get();
    final lotIds = allAssetLots.map((l) => l.id).toList();
    if (lotIds.isNotEmpty) {
      await (delete(investmentSales)..where((s) => s.lotId.isIn(lotIds))).go();
    }

    // 3. Find all active sell transactions for this asset
    final sellTransactions = await (select(transactions)
          ..where((t) =>
              t.tag.equals('investment_sell:$assetId') &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.transactionDate), (t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    // Prepare in-memory lots
    final openLots = allLots.map((r) {
      return LotState(
        id: r.id,
        assetId: r.assetId,
        buyDate: r.buyDate,
        createdAt: r.createdAt,
        quantity: Decimal.parse(r.quantity),
        remainingQuantity: Decimal.parse(r.quantity),
        costPerUnitOriginalSatang: r.costPerUnitOriginalSatang,
        pricePerUnitOriginal: r.pricePerUnitOriginal != null ? Decimal.tryParse(r.pricePerUnitOriginal!) : null,
        fxRate: Decimal.parse(r.fxRate),
        costPerUnitThbSatang: r.costPerUnitThbSatang,
        feeThbSatang: r.feeThbSatang,
        totalCostThbSatang: r.totalCostThbSatang,
        remainingCostThbSatang: r.totalCostThbSatang,
        status: 'open',
      );
    }).toList();

    // 4. Re-play each sell transaction in chronological order
    for (final stx in sellTransactions) {
      final fx = Decimal.parse(stx.fxRate);
      final priceOriginal = (Decimal.fromInt(stx.amountOriginalSatang) / Decimal.parse(stx.note?.split(' ')[2] ?? '1')).toDecimal().round().toBigInt().toInt();
      // Parse quantity from note or derive
      final qtyMatch = RegExp(r'ขาย\s+\S+\s+([0-9\.]+)\s+หน่วย').firstMatch(stx.note ?? '');
      final sellQty = qtyMatch != null ? Decimal.parse(qtyMatch.group(1)!) : Decimal.one;

      final res = FifoEngine.processSell(
        openLots: openLots,
        sellQuantity: sellQty,
        sellPriceOriginalSatang: priceOriginal > 0 ? priceOriginal : stx.amountOriginalSatang,
        sellFxRate: fx,
        sellFeeThbSatang: stx.feeThbSatang,
      );

      // Re-insert investment_sales
      for (final consumption in res.consumptions) {
        final lotState = openLots.firstWhere((l) => l.id == consumption.lotId);

        await (update(investmentLots)..where((l) => l.id.equals(consumption.lotId))).write(
          InvestmentLotsCompanion(
            remainingQuantity: Value(lotState.remainingQuantity.toString()),
            remainingCostThbSatang: Value(lotState.remainingCostThbSatang),
            status: Value(lotState.status),
            updatedAt: Value(now),
          ),
        );

        await into(investmentSales).insert(
          InvestmentSalesCompanion.insert(
            id: _uuid.v4(),
            sellTransactionId: stx.id,
            lotId: consumption.lotId,
            sellDate: stx.transactionDate,
            quantitySold: consumption.quantitySold.toString(),
            sellPriceThbSatang: consumption.sellPriceThbSatang,
            costThbSatang: consumption.costThbSatang,
            realizedGainLossThbSatang: consumption.realizedGainLossThbSatang,
            priceGainLossThbSatang: Value(consumption.priceGainLossThbSatang),
            fxGainLossThbSatang: Value(consumption.fxGainLossThbSatang),
            sellFxRate: Value(consumption.sellFxRate.toString()),
            buyFxRate: Value(consumption.buyFxRate.toString()),
            feeThbSatang: consumption.feeThbSatang,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }
  }

  Future<void> handleInvestmentTransactionDeleted(String transactionId, String? tag) async {
    if (tag == null) return;
    if (tag.startsWith('investment_buy:')) {
      final assetId = tag.substring('investment_buy:'.length);
      final now = DateTime.now();
      await (update(investmentLots)..where((l) => l.buyTransactionId.equals(transactionId))).write(
        InvestmentLotsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await recalculateFifoForAsset(assetId);
    } else if (tag.startsWith('investment_sell:')) {
      final assetId = tag.substring('investment_sell:'.length);
      final now = DateTime.now();
      await (update(investmentSales)..where((s) => s.sellTransactionId.equals(transactionId))).write(
        InvestmentSalesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await recalculateFifoForAsset(assetId);
    } else if (tag.startsWith('investment_income:')) {
      final now = DateTime.now();
      await (update(investmentIncomes)..where((i) => i.transactionId.equals(transactionId))).write(
        InvestmentIncomesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
  }

  // -------------------------------------------------------------
  // 5. INVESTMENT INCOMES (DIVIDENDS / INTEREST)
  // -------------------------------------------------------------

  Future<String> recordInvestmentIncome({
    required String assetId,
    required String accountId,
    required String incomeType, // dividend, interest, bond_coupon, other
    required DateTime incomeDate,
    required int grossAmountOriginalSatang,
    required String currencyCode,
    required Decimal fxRate,
    required int withholdingTaxThbSatang,
    required int dividendTaxCreditSatang,
    required int netAmountThbSatang,
    required bool isForeignIncome,
    String? note,
  }) async {
    final now = DateTime.now();
    final txId = _uuid.v4();
    final incomeId = _uuid.v4();

    final asset = await getAssetById(assetId);
    final symbol = asset?.symbol ?? 'ASSET';

    final grossThbSatang = (Decimal.fromInt(grossAmountOriginalSatang) * fxRate).round().toBigInt().toInt();

    // 1. Record FX rate if foreign
    if (currencyCode != 'THB' && fxRate != Decimal.one) {
      await into(fxRates).insert(
        FxRatesCompanion.insert(
          id: _uuid.v4(),
          baseCurrency: currencyCode,
          targetCurrency: 'THB',
          rate: fxRate.toString(),
          effectiveDate: incomeDate,
          note: Value('Auto-recorded from $incomeType $symbol'),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // 2. Ledger Transaction
    await into(transactions).insert(
      TransactionsCompanion.insert(
        id: txId,
        transactionType: 'income',
        amountOriginalSatang: grossAmountOriginalSatang,
        currencyCode: currencyCode,
        fxRate: Value(fxRate.toString()),
        amountThbSatang: netAmountThbSatang,
        feeThbSatang: Value(withholdingTaxThbSatang),
        destinationAccountId: Value(accountId),
        transactionDate: incomeDate,
        note: Value(note ?? 'เงินปันผล/ดอกเบี้ย $symbol'),
        tag: Value('investment_income:$assetId'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // 3. Record InvestmentIncome
    await into(investmentIncomes).insert(
      InvestmentIncomesCompanion.insert(
        id: incomeId,
        transactionId: txId,
        assetId: assetId,
        incomeType: incomeType,
        grossAmountOriginalSatang: grossAmountOriginalSatang,
        currencyCode: currencyCode,
        fxRate: fxRate.toString(),
        grossAmountThbSatang: grossThbSatang,
        withholdingTaxThbSatang: Value(withholdingTaxThbSatang),
        dividendTaxCreditSatang: Value(isForeignIncome ? 0 : dividendTaxCreditSatang),
        netAmountThbSatang: netAmountThbSatang,
        isForeignIncome: Value(isForeignIncome),
        note: Value(note),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return incomeId;
  }

  // -------------------------------------------------------------
  // 6. MONTHLY VALUATION & ASSET PRICES
  // -------------------------------------------------------------

  Future<void> deduplicateAssetPrices() async {
    final allPrices = await (select(assetPrices)
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([
            (p) => OrderingTerm.asc(p.assetId),
            (p) => OrderingTerm.asc(p.priceDate),
            (p) => OrderingTerm.desc(p.updatedAt),
            (p) => OrderingTerm.desc(p.createdAt),
          ]))
        .get();

    final seen = <String>{};
    for (final price in allPrices) {
      final key = '${price.assetId}_${price.priceDate.year}_${price.priceDate.month}_${price.priceDate.day}';
      if (seen.contains(key)) {
        await (update(assetPrices)..where((p) => p.id.equals(price.id))).write(
          AssetPricesCompanion(
            deletedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
          ),
        );
      } else {
        seen.add(key);
      }
    }
  }

  Future<void> recordAssetPrice({
    required String assetId,
    required DateTime priceDate,
    required int marketPriceOriginalSatang,
    Decimal? marketPriceOriginal,
    required Decimal fxRate,
  }) async {
    final now = DateTime.now();
    final Decimal unitMarketPrice = marketPriceOriginal ??
        (Decimal.fromInt(marketPriceOriginalSatang) * Decimal.parse('0.01'));
    final Decimal unitMarketPriceThb = unitMarketPrice * fxRate;
    final priceThbSatang = (unitMarketPriceThb * Decimal.fromInt(100)).round().toBigInt().toInt();
    final effectivePriceOriginalSatang = (unitMarketPrice * Decimal.fromInt(100)).round().toBigInt().toInt();

    // Check if price records for this asset on this priceDate already exist
    final existingList = await (select(assetPrices)
          ..where((p) =>
              p.assetId.equals(assetId) &
              p.priceDate.equals(priceDate) &
              p.deletedAt.isNull())
          ..orderBy([
            (p) => OrderingTerm.desc(p.updatedAt),
            (p) => OrderingTerm.desc(p.createdAt),
          ]))
        .get();

    if (existingList.isNotEmpty) {
      final primary = existingList.first;
      await (update(assetPrices)..where((p) => p.id.equals(primary.id))).write(
        AssetPricesCompanion(
          marketPriceOriginalSatang: Value(effectivePriceOriginalSatang),
          fxRate: Value(fxRate.toString()),
          marketPriceThbSatang: Value(priceThbSatang),
          marketPriceOriginal: Value(unitMarketPrice.toString()),
          marketPriceThb: Value(unitMarketPriceThb.toString()),
          updatedAt: Value(now),
        ),
      );
      // Soft delete any older duplicates for the same asset & priceDate
      for (int i = 1; i < existingList.length; i++) {
        await (update(assetPrices)..where((p) => p.id.equals(existingList[i].id))).write(
          AssetPricesCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      }
    } else {
      await into(assetPrices).insert(
        AssetPricesCompanion.insert(
          id: _uuid.v4(),
          assetId: assetId,
          priceDate: priceDate,
          marketPriceOriginalSatang: effectivePriceOriginalSatang,
          fxRate: fxRate.toString(),
          marketPriceThbSatang: priceThbSatang,
          marketPriceOriginal: Value(unitMarketPrice.toString()),
          marketPriceThb: Value(unitMarketPriceThb.toString()),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // Also sync USD FX rate into fx_rates table
    if (fxRate != Decimal.one) {
      final existingFx = await (select(fxRates)
            ..where((f) =>
                f.baseCurrency.equals('USD') &
                f.targetCurrency.equals('THB') &
                f.effectiveDate.equals(priceDate) &
                f.deletedAt.isNull())
            ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
          .get();

      if (existingFx.isNotEmpty) {
        await (update(fxRates)..where((f) => f.id.equals(existingFx.first.id))).write(
          FxRatesCompanion(
            rate: Value(fxRate.toString()),
            updatedAt: Value(now),
          ),
        );
        for (int i = 1; i < existingFx.length; i++) {
          await (update(fxRates)..where((f) => f.id.equals(existingFx[i].id))).write(
            FxRatesCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
        }
      } else {
        await into(fxRates).insert(
          FxRatesCompanion.insert(
            id: _uuid.v4(),
            baseCurrency: 'USD',
            targetCurrency: 'THB',
            rate: fxRate.toString(),
            effectiveDate: priceDate,
            note: const Value('อัปเดตจากราคาตลาดประจำเดือน'),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }
  }

  Future<AssetPrice?> getLatestPriceForAsset(String assetId) {
    return (select(assetPrices)
          ..where((p) => p.assetId.equals(assetId) & p.deletedAt.isNull())
          ..orderBy([
            (p) => OrderingTerm.desc(p.priceDate),
            (p) => OrderingTerm.desc(p.updatedAt),
            (p) => OrderingTerm.desc(p.createdAt),
            (p) => OrderingTerm.desc(p.id),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Decimal> getLatestUsdFxRate() async {
    final rateRow = await (select(fxRates)
          ..where((f) => f.baseCurrency.equals('USD') & f.targetCurrency.equals('THB') & f.deletedAt.isNull())
          ..orderBy([
            (f) => OrderingTerm.desc(f.effectiveDate),
            (f) => OrderingTerm.desc(f.updatedAt),
            (f) => OrderingTerm.desc(f.createdAt),
          ])
          ..limit(1))
        .getSingleOrNull();

    if (rateRow != null) {
      final parsed = Decimal.tryParse(rateRow.rate);
      if (parsed != null && parsed > Decimal.zero) {
        return parsed;
      }
    }
    return Decimal.parse('35.000000');
  }

  // -------------------------------------------------------------
  // 7. PORTFOLIO SUMMARY & AGGREGATES
  // -------------------------------------------------------------

  Future<PortfolioSummary> getPortfolioSummary() async {
    await deduplicateAssetPrices();
    final activeAssets = await getAssets();
    final holdings = <PortfolioAssetHolding>[];
    final uninvestedAssets = <Asset>[];

    int totalValThb = 0;
    int totalCostThb = 0;
    int totalUnrealizedPriceGainLoss = 0;
    int totalUnrealizedFxGainLoss = 0;

    for (final asset in activeAssets) {
      // Fetch open/partially_closed lots
      final lots = await (select(investmentLots)
            ..where((l) =>
                l.assetId.equals(asset.id) &
                l.deletedAt.isNull() &
                l.status.isNotValue('closed')))
          .get();

      if (lots.isEmpty) {
        uninvestedAssets.add(asset);
        continue;
      }

      Decimal totalQty = Decimal.zero;
      int assetTotalCostThb = 0;

      for (final lot in lots) {
        final remQty = Decimal.parse(lot.remainingQuantity);
        if (remQty > Decimal.zero) {
          totalQty += remQty;
          assetTotalCostThb += lot.remainingCostThbSatang;
        }
      }

      if (totalQty == Decimal.zero) {
        uninvestedAssets.add(asset);
        continue;
      }

      // Get latest market price
      final latestPriceRow = await getLatestPriceForAsset(asset.id);
      final Decimal unitMarketPriceOrig = (latestPriceRow?.marketPriceOriginal != null)
          ? Decimal.parse(latestPriceRow!.marketPriceOriginal!)
          : (latestPriceRow != null
              ? (Decimal.fromInt(latestPriceRow.marketPriceOriginalSatang) * Decimal.parse('0.01'))
              : (lots.last.pricePerUnitOriginal != null
                  ? Decimal.parse(lots.last.pricePerUnitOriginal!)
                  : (Decimal.fromInt(lots.last.costPerUnitOriginalSatang) * Decimal.parse('0.01'))));

      final int currentPriceOrigSatang = (unitMarketPriceOrig * Decimal.fromInt(100)).round().toBigInt().toInt();
      final Decimal currentFx = latestPriceRow != null
          ? Decimal.parse(latestPriceRow.fxRate)
          : Decimal.parse(lots.last.fxRate);

      final currentPriceThb = (unitMarketPriceOrig * currentFx * Decimal.fromInt(100)).round().toBigInt().toInt();
      final currentValThb = (totalQty * unitMarketPriceOrig * currentFx * Decimal.fromInt(100)).round().toBigInt().toInt();

      // Unrealized P&L split per lot:
      int assetUnrealizedPrice = 0;
      int assetUnrealizedFx = 0;

      for (final lot in lots) {
        final remQty = Decimal.parse(lot.remainingQuantity);
        if (remQty <= Decimal.zero) continue;

        final lotBuyFx = Decimal.parse(lot.fxRate);
        final Decimal lotUnitPriceOrig = lot.pricePerUnitOriginal != null
            ? Decimal.parse(lot.pricePerUnitOriginal!)
            : (Decimal.fromInt(lot.costPerUnitOriginalSatang) * Decimal.parse('0.01'));

        final priceDiffOrig = unitMarketPriceOrig - lotUnitPriceOrig;

        // Price P&L = (P_market - P_buy) * Q * R_buy
        final pPnl = (priceDiffOrig * remQty * lotBuyFx * Decimal.fromInt(100)).round().toBigInt().toInt();
        // FX P&L = P_market * Q * (R_current - R_buy)
        final fxPnl = (unitMarketPriceOrig * remQty * (currentFx - lotBuyFx) * Decimal.fromInt(100)).round().toBigInt().toInt();

        assetUnrealizedPrice += pPnl;
        assetUnrealizedFx += fxPnl;
      }

      final holding = PortfolioAssetHolding(
        asset: asset,
        totalQuantity: totalQty,
        totalCostThbSatang: assetTotalCostThb,
        currentPriceOriginalSatang: currentPriceOrigSatang,
        currentPriceOriginal: unitMarketPriceOrig,
        currentFxRate: currentFx,
        currentPriceThbSatang: currentPriceThb,
        currentValueThbSatang: currentValThb,
        unrealizedPriceGainLossThbSatang: assetUnrealizedPrice,
        unrealizedFxGainLossThbSatang: assetUnrealizedFx,
        totalUnrealizedGainLossThbSatang: currentValThb - assetTotalCostThb,
      );

      holdings.add(holding);
      totalValThb += currentValThb;
      totalCostThb += assetTotalCostThb;
      totalUnrealizedPriceGainLoss += assetUnrealizedPrice;
      totalUnrealizedFxGainLoss += assetUnrealizedFx;
    }

    return PortfolioSummary(
      totalValueThbSatang: totalValThb,
      totalCostThbSatang: totalCostThb,
      totalUnrealizedPriceGainLossThbSatang: totalUnrealizedPriceGainLoss,
      totalUnrealizedFxGainLossThbSatang: totalUnrealizedFxGainLoss,
      totalUnrealizedGainLossThbSatang: totalValThb - totalCostThb,
      holdings: holdings,
      uninvestedAssets: uninvestedAssets,
    );
  }

  // -------------------------------------------------------------
  // 8. REALIZED GAIN/LOSS GROUPED BY YEAR
  // -------------------------------------------------------------

  Future<List<RealizedGainLossYearSummary>> getRealizedGainLossByYear() async {
    final allSales = await (select(investmentSales)
          ..where((s) => s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.sellDate)]))
        .get();

    final allLots = await (select(investmentLots)
          ..where((l) => l.deletedAt.isNull())
          ..orderBy([(l) => OrderingTerm.desc(l.buyDate)]))
        .get();

    final allAssets = await getAssets();
    final assetMap = {for (final a in allAssets) a.id: a};
    final lotMap = {for (final l in allLots) l.id: l};

    final years = <int>{};
    for (final s in allSales) {
      years.add(s.sellDate.year);
    }
    for (final l in allLots) {
      years.add(l.buyDate.year);
    }

    final result = <RealizedGainLossYearSummary>[];
    for (final year in years) {
      final yearSales = allSales.where((s) => s.sellDate.year == year).toList();
      final yearLots = allLots.where((l) => l.buyDate.year == year).toList();

      int totalRealized = 0;
      int totalPricePnl = 0;
      int totalFxPnl = 0;
      int totalFee = 0;
      int totalCost = 0;
      int totalSellPrice = 0;
      int totalBuyCost = 0;

      final assetIds = <String>{};
      for (final s in yearSales) {
        final lot = lotMap[s.lotId];
        if (lot != null) assetIds.add(lot.assetId);
        totalRealized += s.realizedGainLossThbSatang;
        totalPricePnl += s.priceGainLossThbSatang;
        totalFxPnl += s.fxGainLossThbSatang;
        totalFee += s.feeThbSatang;
        totalCost += s.costThbSatang;
        totalSellPrice += s.sellPriceThbSatang;
      }

      for (final l in yearLots) {
        assetIds.add(l.assetId);
        totalBuyCost += l.totalCostThbSatang;
      }

      final assetSummaries = <RealizedGainLossAssetSummary>[];
      for (final assetId in assetIds) {
        final asset = assetMap[assetId];
        if (asset == null) continue;

        final assetSales = yearSales.where((s) => lotMap[s.lotId]?.assetId == assetId).toList();
        final assetBuys = yearLots.where((l) => l.assetId == assetId).toList();

        Decimal qtySold = Decimal.zero;
        int aCost = 0;
        int aSellPrice = 0;
        int aRealized = 0;
        int aPricePnl = 0;
        int aFxPnl = 0;
        int aFee = 0;

        for (final s in assetSales) {
          qtySold += Decimal.parse(s.quantitySold);
          aCost += s.costThbSatang;
          aSellPrice += s.sellPriceThbSatang;
          aRealized += s.realizedGainLossThbSatang;
          aPricePnl += s.priceGainLossThbSatang;
          aFxPnl += s.fxGainLossThbSatang;
          aFee += s.feeThbSatang;
        }

        Decimal qtyBought = Decimal.zero;
        int aBuyCost = 0;
        for (final l in assetBuys) {
          qtyBought += Decimal.parse(l.quantity);
          aBuyCost += l.totalCostThbSatang;
        }

        assetSummaries.add(RealizedGainLossAssetSummary(
          asset: asset,
          quantitySold: qtySold,
          quantityBought: qtyBought,
          netQuantity: qtyBought - qtySold,
          totalCostThbSatang: aCost,
          totalSellPriceThbSatang: aSellPrice,
          realizedGainLossThbSatang: aRealized,
          priceGainLossThbSatang: aPricePnl,
          fxGainLossThbSatang: aFxPnl,
          feeThbSatang: aFee,
          totalBuyCostThbSatang: aBuyCost,
        ));
      }

      assetSummaries.sort((a, b) {
        final aHasSale = a.quantitySold > Decimal.zero;
        final bHasSale = b.quantitySold > Decimal.zero;
        if (aHasSale != bHasSale) return aHasSale ? -1 : 1;
        return a.asset.symbol.compareTo(b.asset.symbol);
      });

      result.add(RealizedGainLossYearSummary(
        year: year,
        totalRealizedGainLossThbSatang: totalRealized,
        totalPriceGainLossThbSatang: totalPricePnl,
        totalFxGainLossThbSatang: totalFxPnl,
        totalFeeThbSatang: totalFee,
        totalCostThbSatang: totalCost,
        totalSellPriceThbSatang: totalSellPrice,
        totalBuyCostThbSatang: totalBuyCost,
        assetSummaries: assetSummaries,
      ));
    }

    result.sort((a, b) => b.year.compareTo(a.year));
    return result;
  }

  Future<List<InvestmentTradeRecord>> getInvestmentTrades({int? limit}) async {
    final query = select(transactions)
      ..where((t) =>
          t.deletedAt.isNull() &
          (t.tag.like('investment_buy:%') | t.tag.like('investment_sell:%')))
      ..orderBy([(t) => OrderingTerm.desc(t.transactionDate), (t) => OrderingTerm.desc(t.createdAt)]);

    if (limit != null) {
      query.limit(limit);
    }

    final txRows = await query.get();
    if (txRows.isEmpty) return [];

    final allAssets = await getAssets();
    final assetMap = {for (final a in allAssets) a.id: a};

    final allAccounts = await (select(accounts)..where((a) => a.deletedAt.isNull())).get();
    final accountMap = {for (final acc in allAccounts) acc.id: acc};

    final allLots = await (select(investmentLots)..where((l) => l.deletedAt.isNull())).get();
    final lotByTxMap = {for (final l in allLots) l.buyTransactionId: l};

    final allSales = await (select(investmentSales)..where((s) => s.deletedAt.isNull())).get();
    final salesByTxMap = <String, List<InvestmentSale>>{};
    for (final s in allSales) {
      salesByTxMap.putIfAbsent(s.sellTransactionId, () => []).add(s);
    }

    final records = <InvestmentTradeRecord>[];

    for (final tx in txRows) {
      final tag = tx.tag ?? '';
      final isBuy = tag.startsWith('investment_buy:');
      final isSell = tag.startsWith('investment_sell:');
      final assetId = isBuy
          ? tag.substring('investment_buy:'.length)
          : (isSell ? tag.substring('investment_sell:'.length) : '');

      final asset = assetMap[assetId];
      final accountId = isBuy ? tx.sourceAccountId : tx.destinationAccountId;
      final acc = accountId != null ? accountMap[accountId] : null;

      Decimal qty = Decimal.zero;
      int priceOriginalSatang = 0;
      int? costThbSatang;
      int? realizedGainLoss;

      if (isBuy) {
        final lot = lotByTxMap[tx.id];
        if (lot != null) {
          qty = Decimal.parse(lot.quantity);
          priceOriginalSatang = lot.costPerUnitOriginalSatang;
        } else if (tx.amountOriginalSatang > 0) {
          priceOriginalSatang = tx.amountOriginalSatang;
          qty = Decimal.one;
        }
      } else if (isSell) {
        final sales = salesByTxMap[tx.id] ?? [];
        int sumCost = 0;
        int sumRealized = 0;
        for (final s in sales) {
          qty += Decimal.parse(s.quantitySold);
          sumCost += s.costThbSatang;
          sumRealized += s.realizedGainLossThbSatang;
        }
        costThbSatang = sumCost;
        realizedGainLoss = sumRealized;
        if (qty > Decimal.zero) {
          final priceDec = Decimal.fromInt(tx.amountOriginalSatang) / qty;
          priceOriginalSatang = priceDec.round().toInt();
        }
      }

      records.add(InvestmentTradeRecord(
        id: tx.id,
        tradeDate: tx.transactionDate,
        tradeType: isBuy ? 'buy' : 'sell',
        asset: asset,
        quantity: qty,
        priceOriginalSatang: priceOriginalSatang,
        currencyCode: tx.currencyCode,
        fxRate: Decimal.tryParse(tx.fxRate) ?? Decimal.one,
        totalThbSatang: tx.amountThbSatang,
        feeThbSatang: tx.feeThbSatang,
        costThbSatang: costThbSatang,
        realizedGainLossThbSatang: realizedGainLoss,
        accountName: acc?.name,
        note: tx.note,
      ));
    }

    return records;
  }

  Future<List<InvestmentSale>> getSalesForSellTransaction(String sellTransactionId) {
    return (select(investmentSales)
          ..where((s) => s.sellTransactionId.equals(sellTransactionId) & s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.asc(s.createdAt)]))
        .get();
  }

  Future<List<InvestmentLot>> getAllLotsForAsset(String assetId) {
    return (select(investmentLots)
          ..where((l) => l.assetId.equals(assetId) & l.deletedAt.isNull())
          ..orderBy([(l) => OrderingTerm.asc(l.buyDate), (l) => OrderingTerm.asc(l.createdAt)]))
        .get();
  }
}

