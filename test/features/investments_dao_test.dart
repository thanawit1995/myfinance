import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';

void main() {
  late AppDatabase db;
  late String defaultAccountId;

  setUp(() async {
    db = AppDatabase.forTesting(inMemoryConnection());
    final accs = await db.accountsDao.getActiveAccounts();
    defaultAccountId = accs.first.id;
  });

  tearDown(() async {
    await db.close();
  });

  group('InvestmentsDao - Full Integration Tests', () {
    test('Can create asset and record buy trade with lot creation and FX rate', () async {
      final now = DateTime.now();

      // 1. Create Thai Stock Asset
      const assetId = 'asset-cpall';
      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'CPALL',
          name: 'CP ALL Public Company Limited',
          assetType: 'thai_stock',
          currencyCode: 'THB',
          defaultAccountId: defaultAccountId, // from SeedData
          market: const Value('SET'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final asset = await db.investmentsDao.getAssetById(assetId);
      expect(asset, isNotNull);
      expect(asset!.symbol, 'CPALL');

      // 2. Buy 100 shares @ 65.00 THB (6500 satang), fee 25.00 THB (2500 satang)
      final lotId = await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 2, 1),
        quantity: Decimal.parse('100'),
        priceOriginalSatang: 6500,
        currencyCode: 'THB',
        fxRate: Decimal.parse('1.000000'),
        feeThbSatang: 2500,
      );

      expect(lotId, isNotNull);

      // Verify Lot
      final lots = await db.investmentsDao.getAllLotsForAsset(assetId);
      expect(lots.length, 1);
      final lot = lots.first;
      expect(lot.status, 'open');
      expect(lot.quantity, '100');
      expect(lot.remainingQuantity, '100');
      expect(lot.costPerUnitOriginalSatang, 6500);
      // Total cost = 100 * 65.00 + 25.00 = 6,525.00 THB (652,500 satang)
      expect(lot.totalCostThbSatang, 652500);
      expect(lot.remainingCostThbSatang, 652500);

      // Verify transaction ledger record
      final tx = await (db.select(db.transactions)..where((t) => t.id.equals(lot.buyTransactionId))).getSingle();
      expect(tx.transactionType, 'expense');
      expect(tx.amountThbSatang, 650000);
      expect(tx.feeThbSatang, 2500);
      expect(tx.categoryId, isNotNull);
      final cat = await db.categoriesDao.getCategoryById(tx.categoryId!);
      expect(cat?.nameTh, 'การลงทุน');
      expect(cat?.categoryType, 'expense');
    });

    test('Sell trade consumes lots with FIFO and splits Price P&L vs FX P&L', () async {
      final now = DateTime.now();

      // Create US Stock Asset (e.g. AAPL)
      const assetId = 'asset-aapl';
      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'AAPL',
          name: 'Apple Inc.',
          assetType: 'foreign_stock',
          currencyCode: 'USD',
          defaultAccountId: defaultAccountId,
          market: const Value('NASDAQ'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Buy Lot 1: 10 shares @ 150 USD, FX = 34.00, fee = 0
      // Cost = 10 * 150 * 34 = 51,000 THB (5,100,000 satang)
      await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 1, 10),
        quantity: Decimal.parse('10'),
        priceOriginalSatang: 15000,
        currencyCode: 'USD',
        fxRate: Decimal.parse('34.000000'),
        feeThbSatang: 0,
      );

      // Buy Lot 2: 10 shares @ 160 USD, FX = 35.00, fee = 0
      // Cost = 10 * 160 * 35 = 56,000 THB (5,600,000 satang)
      await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 1, 20),
        quantity: Decimal.parse('10'),
        priceOriginalSatang: 16000,
        currencyCode: 'USD',
        fxRate: Decimal.parse('35.000000'),
        feeThbSatang: 0,
      );

      // Sell 15 shares @ 180 USD, FX = 36.00, fee = 100 THB (10000 satang)
      // FIFO will consume all 10 shares of Lot 1 + 5 shares of Lot 2!
      final sellResult = await db.investmentsDao.recordSellTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 2, 15),
        quantity: Decimal.parse('15'),
        priceOriginalSatang: 18000,
        currencyCode: 'USD',
        fxRate: Decimal.parse('36.000000'),
        feeThbSatang: 10000,
      );

      expect(sellResult.consumptions.length, 2);

      // Lot 1 consumed (10 shares):
      // Buy: 150 USD @ 34.00. Sell: 180 USD @ 36.00
      // Price P&L = (180 - 150) * 10 * 34 = 300 * 34 = 10,200 THB (1,020,000 satang)
      // FX P&L = 180 * 10 * (36 - 34) = 1800 * 2 = 3,600 THB (360,000 satang)
      final c1 = sellResult.consumptions[0];
      expect(c1.quantitySold, Decimal.parse('10'));
      expect(c1.priceGainLossThbSatang, 1020000);
      expect(c1.fxGainLossThbSatang, 360000);

      // Lot 2 consumed (5 shares):
      // Buy: 160 USD @ 35.00. Sell: 180 USD @ 36.00
      // Price P&L = (180 - 160) * 5 * 35 = 100 * 35 = 3,500 THB (350,000 satang)
      // FX P&L = 180 * 5 * (36 - 35) = 900 * 1 = 900 THB (90,000 satang)
      final c2 = sellResult.consumptions[1];
      expect(c2.quantitySold, Decimal.parse('5'));
      expect(c2.priceGainLossThbSatang, 350000);
      expect(c2.fxGainLossThbSatang, 90000);

      // Total fee 100 THB pro-rata:
      // c1 fee (10/15 * 10000) = 6667
      // c2 fee (residual) = 10000 - 6667 = 3333
      expect(c1.feeThbSatang + c2.feeThbSatang, 10000);

      // Verify DB lot statuses
      final updatedLots = await db.investmentsDao.getAllLotsForAsset(assetId);
      expect(updatedLots[0].status, 'closed');
      expect(updatedLots[0].remainingQuantity, '0');
      expect(updatedLots[1].status, 'partially_closed');
      expect(updatedLots[1].remainingQuantity, '5');

      // Check RealizedGainLoss summary
      final yearlySummaries = await db.investmentsDao.getRealizedGainLossByYear();
      expect(yearlySummaries.first.year, 2026);
      expect(yearlySummaries.first.totalFeeThbSatang, 10000);

      // Verify sell transaction category is 'ขายสินทรัพย์' and taxCategory is 'non_taxable'
      final allTxs = await db.transactionsDao.getAllTransactions();
      final sellTx = allTxs.firstWhere((t) => t.transactionType == 'income' && t.tag == 'investment_sell:$assetId');
      expect(sellTx.categoryId, isNotNull);
      final cat = await db.categoriesDao.getCategoryById(sellTx.categoryId!);
      expect(cat?.nameTh, 'ขายสินทรัพย์');
      expect(sellTx.taxCategory, 'non_taxable');
    });

    test('Recalculate FIFO resets and replays all sales chronologically', () async {
      const assetId = 'asset-recalc';
      final now = DateTime.now();
      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'RECALC',
          name: 'Recalculate Asset',
          assetType: 'crypto',
          currencyCode: 'THB',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Buy Lot 1: 10 units @ 100 THB
      await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 1, 1),
        quantity: Decimal.parse('10'),
        priceOriginalSatang: 10000,
        currencyCode: 'THB',
        fxRate: Decimal.parse('1.000000'),
        feeThbSatang: 0,
      );

      // Sell 5 units @ 150 THB
      await db.investmentsDao.recordSellTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 1, 15),
        quantity: Decimal.parse('5'),
        priceOriginalSatang: 15000,
        currencyCode: 'THB',
        fxRate: Decimal.parse('1.000000'),
        feeThbSatang: 0,
      );

      var lots = await db.investmentsDao.getAllLotsForAsset(assetId);
      expect(lots.first.remainingQuantity, '5');
      expect(lots.first.status, 'partially_closed');

      // Trigger recalculation
      await db.investmentsDao.recalculateFifoForAsset(assetId);

      lots = await db.investmentsDao.getAllLotsForAsset(assetId);
      // Should still be cleanly 5 remaining!
      expect(lots.first.remainingQuantity, '5');
      expect(lots.first.status, 'partially_closed');
    });

    test('Record investment income with withholding tax and dividend tax credit', () async {
      const assetId = 'asset-div-test';
      final now = DateTime.now();
      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'DIVSTOCK',
          name: 'Dividend Stock Pcl',
          assetType: 'thai_stock',
          currencyCode: 'THB',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Dividend: 1,000.00 THB gross, 10% withholding tax = 100.00 THB, net = 900.00 THB
      // Thai stock tax credit 20% corporate rate = 1000 * 20/80 = 250.00 THB (25,000 satang)
      final incomeId = await db.investmentsDao.recordInvestmentIncome(
        assetId: assetId,
        accountId: defaultAccountId,
        incomeType: 'dividend',
        incomeDate: DateTime(2026, 5, 20),
        grossAmountOriginalSatang: 100000,
        currencyCode: 'THB',
        fxRate: Decimal.parse('1.000000'),
        withholdingTaxThbSatang: 10000,
        dividendTaxCreditSatang: 25000,
        netAmountThbSatang: 90000,
        isForeignIncome: false,
      );

      expect(incomeId, isNotNull);

      final incomes = await (db.select(db.investmentIncomes)..where((i) => i.id.equals(incomeId))).getSingle();
      expect(incomes.grossAmountThbSatang, 100000);
      expect(incomes.withholdingTaxThbSatang, 10000);
      expect(incomes.dividendTaxCreditSatang, 25000);
      expect(incomes.netAmountThbSatang, 90000);
      expect(incomes.isForeignIncome, false);
    });

    test('Foreign income sets dividendTaxCredit to 0', () async {
      const assetId = 'asset-foreign-div';
      final now = DateTime.now();
      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'VOO',
          name: 'Vanguard S&P 500 ETF',
          assetType: 'etf',
          currencyCode: 'USD',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final incomeId = await db.investmentsDao.recordInvestmentIncome(
        assetId: assetId,
        accountId: defaultAccountId,
        incomeType: 'dividend',
        incomeDate: DateTime(2026, 6, 1),
        grossAmountOriginalSatang: 5000, // 50.00 USD
        currencyCode: 'USD',
        fxRate: Decimal.parse('35.000000'),
        withholdingTaxThbSatang: 26250, // 15% W-8BEN in THB satang
        dividendTaxCreditSatang: 99999, // passed in, but should be forced to 0!
        netAmountThbSatang: 148750,
        isForeignIncome: true,
      );

      final income = await (db.select(db.investmentIncomes)..where((i) => i.id.equals(incomeId))).getSingle();
      // Must be 0 because foreign income cannot claim Thai dividend tax credit
      expect(income.dividendTaxCreditSatang, 0);
      expect(income.isForeignIncome, true);
    });

    test('Monthly valuation and Portfolio Summary calculate unrealized Price vs FX P&L', () async {
      const assetId = 'asset-port-test';
      final now = DateTime.now();
      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'TSLA',
          name: 'Tesla Inc.',
          assetType: 'foreign_stock',
          currencyCode: 'USD',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Buy 2 shares @ 200 USD, FX = 35.00
      // Total cost = 2 * 200 * 35 = 14,000 THB (1,400,000 satang)
      await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 1, 1),
        quantity: Decimal.parse('2'),
        priceOriginalSatang: 20000,
        currencyCode: 'USD',
        fxRate: Decimal.parse('35.000000'),
        feeThbSatang: 0,
      );

      // Record monthly market price: 250 USD, FX = 36.00
      // Current value = 2 * 250 * 36 = 18,000 THB (1,800,000 satang)
      // Total Unrealized Gain = 18,000 - 14,000 = 4,000 THB (400,000 satang)
      // Price P&L = (250 - 200) * 2 * 35 = 50 * 2 * 35 = 3,500 THB (350,000 satang)
      // FX P&L = 250 * 2 * (36 - 35) = 500 * 1 = 500 THB (50,000 satang)
      await db.investmentsDao.recordAssetPrice(
        assetId: assetId,
        priceDate: DateTime(2026, 1, 31),
        marketPriceOriginalSatang: 25000,
        fxRate: Decimal.parse('36.000000'),
      );

      final summary = await db.investmentsDao.getPortfolioSummary();
      expect(summary.totalValueThbSatang, 1800000);
      expect(summary.totalCostThbSatang, 1400000);
      expect(summary.totalUnrealizedPriceGainLossThbSatang, 350000);
      expect(summary.totalUnrealizedFxGainLossThbSatang, 50000);
      expect(summary.totalUnrealizedGainLossThbSatang, 400000);
      expect(summary.holdings.length, 1);
      expect(summary.holdings.first.totalQuantity, Decimal.parse('2'));
    });

    test('Deleting a sell transaction recalculates FIFO and restores lot balance', () async {
      final now = DateTime.now();
      const assetId = 'asset-recalc-test';
      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'RECALC',
          name: 'Recalculation Test',
          assetType: 'thai_stock',
          currencyCode: 'THB',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Buy 100 shares
      final lotId = await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 1, 1),
        quantity: Decimal.parse('100'),
        priceOriginalSatang: 1000,
        currencyCode: 'THB',
        fxRate: Decimal.one,
        feeThbSatang: 0,
      );

      // Sell 40 shares
      await db.investmentsDao.recordSellTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 2, 1),
        quantity: Decimal.parse('40'),
        priceOriginalSatang: 1500,
        currencyCode: 'THB',
        fxRate: Decimal.one,
        feeThbSatang: 0,
      );

      // Verify lot was consumed partially
      var lots = await db.investmentsDao.getAllLotsForAsset(assetId);
      expect(lots.first.remainingQuantity, '60');
      expect(lots.first.status, 'partially_closed');

      // Now soft-delete sell transaction
      final txs = await db.transactionsDao.getRecentTransactions();
      final sellTx = txs.firstWhere((t) => t.tag == 'investment_sell:$assetId');

      await db.transactionsDao.softDeleteTransaction(sellTx.id);
      await db.investmentsDao.handleInvestmentTransactionDeleted(sellTx.id, sellTx.tag);

      // Verify lot is restored to 100 shares and open status
      lots = await db.investmentsDao.getAllLotsForAsset(assetId);
      expect(lots.first.remainingQuantity, '100');
      expect(lots.first.status, 'open');
      expect(lots.first.remainingCostThbSatang, lots.first.totalCostThbSatang);

      final sales = await db.investmentsDao.getSalesForLot(lotId);
      expect(sales.isEmpty, isTrue);
    });

    test('Updating FX rate for holding immediately updates FX P&L even on same priceDate', () async {
      final now = DateTime.now();
      const assetId = 'asset-usd-fx-test';

      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'NVDA',
          name: 'NVIDIA Corporation',
          assetType: 'foreign_stock',
          currencyCode: 'USD',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Buy 10 shares @ $100.00 (10,000 cents), FX rate = 35.00
      await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 1, 1),
        quantity: Decimal.parse('10'),
        priceOriginalSatang: 10000,
        currencyCode: 'USD',
        fxRate: Decimal.parse('35.000000'),
        feeThbSatang: 0,
      );

      final priceDate = DateTime(2026, 1, 31);

      // 1. Initial market valuation at FX = 35.00 (same as buy rate) -> FX P&L = 0
      await db.investmentsDao.recordAssetPrice(
        assetId: assetId,
        priceDate: priceDate,
        marketPriceOriginalSatang: 10000, // $100.00
        fxRate: Decimal.parse('35.000000'),
      );

      var summary = await db.investmentsDao.getPortfolioSummary();
      expect(summary.totalUnrealizedFxGainLossThbSatang, 0);

      // 2. User updates FX rate on the SAME month/date to 36.50 (+1.50 THB per USD)
      // Total USD = 10 * $100 = $1,000. Expected FX gain = $1,000 * 1.50 = 1,500 THB (150,000 satang)
      await db.investmentsDao.recordAssetPrice(
        assetId: assetId,
        priceDate: priceDate,
        marketPriceOriginalSatang: 10000,
        fxRate: Decimal.parse('36.500000'),
      );

      summary = await db.investmentsDao.getPortfolioSummary();
      expect(summary.totalUnrealizedFxGainLossThbSatang, 150000);
      expect(summary.holdings.first.currentFxRate, Decimal.parse('36.500000'));
    });

    test('Assets created without buy trades appear in uninvestedAssets list', () async {
      final now = DateTime.now();
      const assetId = 'asset-watchlist-test';

      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'WATCH1',
          name: 'Watchlist Asset',
          assetType: 'thai_stock',
          currencyCode: 'THB',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final summary = await db.investmentsDao.getPortfolioSummary();
      expect(summary.uninvestedAssets.any((a) => a.id == assetId), isTrue);
    });

    test('Duplicate asset_prices on the same date are automatically deduplicated and newest updatedAt wins', () async {
      final now = DateTime.now();
      const assetId = 'asset-dedup-test';

      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'DEDUP',
          name: 'Dedup Asset',
          assetType: 'foreign_stock',
          currencyCode: 'USD',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 1, 1),
        quantity: Decimal.parse('10'),
        priceOriginalSatang: 5000, // $50.00
        currencyCode: 'USD',
        fxRate: Decimal.parse('32.000000'),
        feeThbSatang: 0,
      );

      final priceDate = DateTime(2026, 1, 31);

      // Directly simulate inserting duplicate rows into assetPrices
      await db.into(db.assetPrices).insert(
        AssetPricesCompanion.insert(
          id: 'price-old',
          assetId: assetId,
          priceDate: priceDate,
          marketPriceOriginalSatang: 5000,
          fxRate: '32.000000',
          marketPriceThbSatang: 160000,
          createdAt: DateTime(2026, 1, 31, 10, 0),
          updatedAt: DateTime(2026, 1, 31, 10, 0),
        ),
      );

      await db.into(db.assetPrices).insert(
        AssetPricesCompanion.insert(
          id: 'price-newer',
          assetId: assetId,
          priceDate: priceDate,
          marketPriceOriginalSatang: 5000,
          fxRate: '36.500000',
          marketPriceThbSatang: 182500,
          createdAt: DateTime(2026, 1, 31, 10, 5),
          updatedAt: DateTime(2026, 1, 31, 12, 0),
        ),
      );

      // getPortfolioSummary should trigger deduplicateAssetPrices and pick the newer one
      final summary = await db.investmentsDao.getPortfolioSummary();
      final holding = summary.holdings.firstWhere((h) => h.asset.id == assetId);
      expect(holding.currentFxRate, Decimal.parse('36.500000'));
      // 10 shares * $50 * (36.5 - 32) = 500 * 4.5 = 2,250 THB (225,000 satang)
      expect(holding.unrealizedFxGainLossThbSatang, 225000);

      // Verify older duplicate is soft-deleted
      final oldPrice = await (db.select(db.assetPrices)..where((p) => p.id.equals('price-old'))).getSingle();
      expect(oldPrice.deletedAt, isNotNull);
    });

    test('getRealizedGainLossByYear includes cost basis, proceeds, and asset breakdown', () async {
      const assetId = 'asset-breakdown';
      final now = DateTime(2025, 5, 10);

      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'BDOWN',
          name: 'Breakdown Test Corp',
          assetType: 'stock_foreign',
          currencyCode: 'USD',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Buy 20 shares @ $10, FX 35, fee 100 THB -> total cost = (20 * $10 * 35) + 100 = 7,000 + 100 = 7,100 THB (710,000 satang)
      await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: now,
        quantity: Decimal.fromInt(20),
        priceOriginalSatang: 1000,
        currencyCode: 'USD',
        fxRate: Decimal.parse('35.000000'),
        feeThbSatang: 10000,
      );

      // Sell 10 shares @ $15, FX 36, fee 50 THB -> proceeds = 10 * 15 * 36 - 50 = 5,400 - 50 = 5,350 THB (535,000 satang)
      // Cost of 10 shares = half of 7,100 = 3,550 THB (355,000 satang)
      final sellDate = DateTime(2025, 8, 15);
      await db.investmentsDao.recordSellTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: sellDate,
        quantity: Decimal.fromInt(10),
        priceOriginalSatang: 1500,
        currencyCode: 'USD',
        fxRate: Decimal.parse('36.000000'),
        feeThbSatang: 5000,
      );

      final summaries = await db.investmentsDao.getRealizedGainLossByYear();
      expect(summaries.isNotEmpty, true);

      final summary2025 = summaries.firstWhere((s) => s.year == 2025);
      expect(summary2025.totalCostThbSatang, 355000); // 3,550 THB cost basis sold
      expect(summary2025.totalSellPriceThbSatang, 540000); // 5,400 THB gross proceeds
      expect(summary2025.totalBuyCostThbSatang, 710000); // 7,100 THB buy cost in 2025
      expect(summary2025.totalFeeThbSatang, 5000);
      expect(summary2025.totalRealizedGainLossThbSatang, 180000); // 5,400 - 50 - 3,550 = 1,800 THB

      // Asset breakdown check
      expect(summary2025.assetSummaries.length, 1);
      final assetSummary = summary2025.assetSummaries.first;
      expect(assetSummary.asset.symbol, 'BDOWN');
      expect(assetSummary.quantityBought, Decimal.fromInt(20));
      expect(assetSummary.quantitySold, Decimal.fromInt(10));
      expect(assetSummary.netQuantity, Decimal.fromInt(10)); // 20 - 10 = 10
      expect(assetSummary.totalCostThbSatang, 355000);
      expect(assetSummary.totalBuyCostThbSatang, 710000);
      expect(assetSummary.realizedGainLossThbSatang, 180000);
    });

    test('getInvestmentTrades returns chronological trade records with complete cost and proceeds', () async {
      const assetId = 'asset-trades';
      final now = DateTime(2025, 5, 10);

      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'TRD',
          name: 'Trade Test Corp',
          assetType: 'stock_foreign',
          currencyCode: 'USD',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Buy 20 shares @ $10, FX 35, fee 100 THB -> total THB = 7,000 THB
      await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: now,
        quantity: Decimal.fromInt(20),
        priceOriginalSatang: 1000,
        currencyCode: 'USD',
        fxRate: Decimal.parse('35.000000'),
        feeThbSatang: 10000,
      );

      // Sell 10 shares @ $15, FX 36, fee 50 THB
      final sellDate = DateTime(2025, 8, 15);
      await db.investmentsDao.recordSellTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: sellDate,
        quantity: Decimal.fromInt(10),
        priceOriginalSatang: 1500,
        currencyCode: 'USD',
        fxRate: Decimal.parse('36.000000'),
        feeThbSatang: 5000,
      );

      final trades = await db.investmentsDao.getInvestmentTrades();
      expect(trades.isNotEmpty, true);

      final trdTrades = trades.where((t) => t.asset?.symbol == 'TRD').toList();
      expect(trdTrades.length, 2);

      // Sell trade (most recent)
      final sellTrade = trdTrades.firstWhere((t) => t.tradeType == 'sell');
      expect(sellTrade.quantity, Decimal.fromInt(10));
      expect(sellTrade.currencyCode, 'USD');
      expect(sellTrade.costThbSatang, 355000); // Cost basis 3,550 THB
      expect(sellTrade.realizedGainLossThbSatang, 180000); // Realized gain 1,800 THB

      // Buy trade
      final buyTrade = trdTrades.firstWhere((t) => t.tradeType == 'buy');
      expect(buyTrade.quantity, Decimal.fromInt(20));
      expect(buyTrade.currencyCode, 'USD');
      expect(buyTrade.totalThbSatang, 700000); // 7,000 THB trade amount
    });

    test('searchTransactions with excludeInvestments filters out stock buy and sell trades', () async {
      const assetId = 'asset-filter';
      final now = DateTime(2025, 5, 10);

      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'FLTR',
          name: 'Filter Test Corp',
          assetType: 'thai_stock',
          currencyCode: 'THB',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Record a buy trade
      await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: now,
        quantity: Decimal.fromInt(100),
        priceOriginalSatang: 5000,
        currencyCode: 'THB',
        fxRate: Decimal.one,
        feeThbSatang: 0,
      );

      // Normal query includes investment transactions
      final allTx = await db.transactionsDao.searchTransactions();
      final hasInvestmentTx = allTx.any((t) => t.tag != null && t.tag!.startsWith('investment_'));
      expect(hasInvestmentTx, true);

      // Query with excludeInvestments: true excludes them
      final nonInvestmentTx = await db.transactionsDao.searchTransactions(excludeInvestments: true);
      final stillHasInvestment = nonInvestmentTx.any((t) => t.tag != null && t.tag!.startsWith('investment_'));
      expect(stillHasInvestment, false);
    });

    test('Soft delete, restore, and permanent delete of assets', () async {
      final now = DateTime.now();
      const assetId = 'asset-trash-test';

      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'TRASH',
          name: 'Trash Test Corp',
          assetType: 'thai_stock',
          currencyCode: 'THB',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Verify asset exists in active assets
      var activeAssets = await db.investmentsDao.getAssets();
      expect(activeAssets.any((a) => a.id == assetId), true);

      // Soft delete asset
      await db.investmentsDao.softDeleteAsset(assetId);

      // Asset should be excluded from active assets
      activeAssets = await db.investmentsDao.getAssets();
      expect(activeAssets.any((a) => a.id == assetId), false);

      // Asset should be present in deleted assets (trash bin)
      var deletedAssets = await db.investmentsDao.getDeletedAssets();
      expect(deletedAssets.any((a) => a.id == assetId), true);

      // Restore asset
      await db.investmentsDao.restoreAsset(assetId);

      // Asset should be back in active assets
      activeAssets = await db.investmentsDao.getAssets();
      expect(activeAssets.any((a) => a.id == assetId), true);

      // Asset should be removed from deleted assets
      deletedAssets = await db.investmentsDao.getDeletedAssets();
      expect(deletedAssets.any((a) => a.id == assetId), false);

      // Soft delete again, then permanently delete
      await db.investmentsDao.softDeleteAsset(assetId);
      await db.investmentsDao.permanentlyDeleteAsset(assetId);

      final asset = await db.investmentsDao.getAssetById(assetId);
      expect(asset, isNull);
      deletedAssets = await db.investmentsDao.getDeletedAssets();
      expect(deletedAssets.any((a) => a.id == assetId), false);
    });

    test('cleanupExpiredDeletedAssets removes assets deleted more than 30 days ago', () async {
      final now = DateTime.now();
      const expiredAssetId = 'asset-expired';
      const recentAssetId = 'asset-recent';

      // Insert expired asset (>30 days ago)
      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: expiredAssetId,
          symbol: 'OLD',
          name: 'Old Corp',
          assetType: 'thai_stock',
          currencyCode: 'THB',
          defaultAccountId: defaultAccountId,
          createdAt: now.subtract(const Duration(days: 40)),
          updatedAt: now.subtract(const Duration(days: 40)),
          deletedAt: Value(now.subtract(const Duration(days: 31))),
        ),
      );

      // Insert recent deleted asset (<30 days ago)
      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: recentAssetId,
          symbol: 'RECENT',
          name: 'Recent Corp',
          assetType: 'thai_stock',
          currencyCode: 'THB',
          defaultAccountId: defaultAccountId,
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 5)),
          deletedAt: Value(now.subtract(const Duration(days: 2))),
        ),
      );

      // Run cleanup
      await db.investmentsDao.cleanupExpiredDeletedAssets();

      // Expired asset should be hard deleted
      final expired = await db.investmentsDao.getAssetById(expiredAssetId);
      expect(expired, isNull);

      // Recent deleted asset should still exist in trash
      final recent = await db.investmentsDao.getAssetById(recentAssetId);
      expect(recent, isNotNull);
      expect(recent!.deletedAt, isNotNull);
    });

    test('4-decimal precision for trade price and NAV computes exact satang without rounding drift', () async {
      const fundId = 'fund-4dec-test';
      final now = DateTime.now();

      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: fundId,
          symbol: 'K-SET50-TEST',
          name: 'K SET50 Index Fund',
          assetType: 'mutual_fund',
          currencyCode: 'THB',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Buy 1,000 units at NAV 31.9043 THB
      final navBuy = Decimal.parse('31.9043');
      final lotId = await db.investmentsDao.recordBuyTrade(
        assetId: fundId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 6, 1),
        quantity: Decimal.parse('1000'),
        priceOriginalSatang: (navBuy * Decimal.fromInt(100)).round().toBigInt().toInt(),
        pricePerUnitOriginal: navBuy,
        currencyCode: 'THB',
        fxRate: Decimal.one,
        feeThbSatang: 0,
      );

      final lot = await (db.select(db.investmentLots)..where((l) => l.id.equals(lotId))).getSingle();
      // Total cost should be 1000 * 31.9043 = 31,904.30 THB = 3,190,430 satang (NOT truncated to 3,190,000!)
      expect(lot.totalCostThbSatang, 3190430);
      expect(lot.pricePerUnitOriginal, '31.9043');

      // Record monthly valuation at NAV 35.1234
      final navVal = Decimal.parse('35.1234');
      await db.investmentsDao.recordAssetPrice(
        assetId: fundId,
        priceDate: DateTime(2026, 6, 30),
        marketPriceOriginalSatang: (navVal * Decimal.fromInt(100)).round().toBigInt().toInt(),
        marketPriceOriginal: navVal,
        fxRate: Decimal.one,
      );

      final summary = await db.investmentsDao.getPortfolioSummary();
      final holding = summary.holdings.firstWhere((h) => h.asset.id == fundId);

      // Current value: 1000 * 35.1234 = 35,123.40 THB = 3,512,340 satang
      expect(holding.currentValueThbSatang, 3512340);
      expect(holding.currentPriceOriginal, navVal);
      // Unrealized gain: 3,512,340 - 3,190,430 = 321,910 satang = 3,219.10 THB
      expect(holding.unrealizedPriceGainLossThbSatang, 321910);
      expect(holding.totalUnrealizedGainLossThbSatang, 321910);
    });
  });
}
