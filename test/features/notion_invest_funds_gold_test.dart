import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/features/import/domain/notion_funds_import_executor.dart';
import 'package:myfinance/features/import/domain/notion_funds_parser.dart';
import 'package:myfinance/features/import/domain/notion_gold_import_executor.dart';
import 'package:myfinance/features/import/domain/notion_gold_parser.dart';
import 'package:myfinance/features/import/domain/notion_invest_parser.dart';
import 'package:myfinance/features/import/domain/notion_invest_import_executor.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('NotionFundsParser & Executor Tests', () {
    final rawFundCsvRows = [
      [
        'Name',
        'Account',
        'App',
        'Current NAV',
        'Fund Invest formula',
        'Invest',
        'Invest-Funds',
        'Label Profit/Loss',
        'Label invest',
        'Portfolio value formula',
        'Profit/Loss formula',
        'Profit/Loss formula2',
        'Proportion',
        'Related to Proportion (1) (Mutual Funds)',
        'Shares',
        'Type',
      ],
      [
        'K-SET50',
        'Total asset (https://app.notion.com/p/...)',
        'Finnomena',
        'THB 42.43',
        '15709.67',
        '15709.67',
        '@May 5, 2022  (https://app.notion.com/p/...)',
        'Profit/Loss = THB 5026.57 (31.99%)',
        'Invest = THB 15709.67',
        '20736.23730276',
        '5026.56730276',
        '5026.56730276',
        'กองทุนหุ้น',
        '',
        '488.7694',
        'Equity Funds',
      ],
      [
        'SCBFP-SSF',
        'Total asset (https://app.notion.com/p/...)',
        'Finnomena',
        'THB 13.98',
        '25410.73',
        '25410.73',
        '@July 5, 2024  (https://app.notion.com/p/...)',
        'Profit/Loss = THB 1214.21',
        'Invest = THB 25410.73',
        '26624.94',
        '1214.21',
        '1214.21',
        'ตราสารหนี้',
        '',
        '1904.0528',
        'SSF',
      ],
    ];

    test('NotionFundsParser parses mutual funds CSV correctly', () {
      final parsed = NotionFundsParser.parseRows(rawFundCsvRows);

      expect(parsed.length, 2);

      // K-SET50
      final kset = parsed[0];
      expect(kset.symbol, 'K-SET50');
      expect(kset.subType, 'Equity Funds');
      expect(kset.platform, 'Finnomena');
      expect(kset.quantity, Decimal.parse('488.7694'));
      expect(kset.currentNav, Decimal.parse('42.43'));
      expect(kset.totalCostThbSatang, 1570967);
      expect(kset.buyDate.year, 2022);
      expect(kset.buyDate.month, 5);
      expect(kset.buyDate.day, 5);

      // SCBFP-SSF
      final scb = parsed[1];
      expect(scb.symbol, 'SCBFP-SSF');
      expect(scb.subType, 'SSF');
      expect(scb.quantity, Decimal.parse('1904.0528'));
      expect(scb.currentNav, Decimal.parse('13.98'));
      expect(scb.totalCostThbSatang, 2541073);
      expect(scb.buyDate.year, 2024);
      expect(scb.buyDate.month, 7);
      expect(scb.buyDate.day, 5);
    });

    test('NotionFundsImportExecutor imports lots and asset prices with Decimal precision', () async {
      final parsed = NotionFundsParser.parseRows(rawFundCsvRows);
      final executor = NotionFundsImportExecutor(db);

      final result = await executor.executeImport(parsed);
      expect(result.imported, 2);
      expect(result.skippedDuplicates, 0);
      expect(result.errors, isEmpty);

      // Verify Asset created
      final asset = await (db.select(db.assets)..where((a) => a.symbol.equals('K-SET50'))).getSingle();
      expect(asset.assetType, 'mutual_fund');
      expect(asset.currencyCode, 'THB');

      // Verify Lot created with 4-decimal precision
      final lots = await (db.select(db.investmentLots)..where((l) => l.assetId.equals(asset.id))).get();
      expect(lots.length, 1);
      expect(lots.first.quantity, '488.7694');
      expect(lots.first.pricePerUnitOriginal, isNotNull);

      // Verify Asset Price recorded
      final prices = await (db.select(db.assetPrices)..where((p) => p.assetId.equals(asset.id))).get();
      expect(prices.isNotEmpty, true);
      expect(prices.first.marketPriceOriginal, '42.43');

      // Duplicate check: second run should skip all
      final dupResult = await executor.executeImport(parsed);
      expect(dupResult.imported, 0);
      expect(dupResult.skippedDuplicates, 2);
    });
  });

  group('NotionGoldParser & Executor Tests', () {
    final rawGoldCsvRows = [
      [
        'Name',
        'Current THB price',
        'Current price',
        'Profit',
        'Profit THB',
        'Profit label',
        'Total gold',
        'Total invest',
        'USDTHB',
        'USDTHB price',
        'ราคาต้นทุนเฉลี่ย',
      ],
      [
        'MST-GOLD 99.99%',
        'THB 29,650.24',
        '\$4,616.83',
        '\$325.39',
        'THB 10,532.74',
        '325.38592 USD (55.09%)',
        '0.1984',
        '590.6',
        'USDTHB (https://app.notion.com/...)',
        '32.37',
        '\$2,976.78',
      ],
    ];

    test('NotionGoldParser parses gold CSV correctly', () {
      final parsed = NotionGoldParser.parseRows(rawGoldCsvRows);

      expect(parsed.length, 1);
      final gold = parsed.first;
      expect(gold.symbol, 'MST-GOLD 99.99%');
      expect(gold.quantity, Decimal.parse('0.1984'));
      expect(gold.fxRate, Decimal.parse('33.650000'));
      expect(gold.unitCostUsd, Decimal.parse('2976.78'));
      expect(gold.marketPriceUsd, Decimal.parse('4616.83'));
    });

    test('NotionGoldImportExecutor imports gold into portfolio correctly', () async {
      final parsed = NotionGoldParser.parseRows(rawGoldCsvRows);
      final executor = NotionGoldImportExecutor(db);

      final result = await executor.executeImport(parsed);
      expect(result.imported, 1);
      expect(result.skippedDuplicates, 0);
      expect(result.errors, isEmpty);

      // Verify Asset
      final asset = await (db.select(db.assets)..where((a) => a.symbol.equals('MST-GOLD 99.99%'))).getSingle();
      expect(asset.assetType, 'gold');
      expect(asset.currencyCode, 'USD');

      // Verify Lot and account link
      final lots = await (db.select(db.investmentLots)..where((l) => l.assetId.equals(asset.id))).get();
      expect(lots.length, 1);
      expect(lots.first.quantity, '0.1984');
      expect(lots.first.pricePerUnitOriginal, '2976.78');

      final tx = await (db.select(db.transactions)..where((t) => t.id.equals(lots.first.buyTransactionId))).getSingle();
      final sourceAcc = await (db.select(db.accounts)..where((a) => a.id.equals(tx.sourceAccountId!))).getSingle();
      expect(sourceAcc.name, 'Dime! FCD');
      expect(sourceAcc.currencyCode, 'USD');

      // Verify Price
      final prices = await (db.select(db.assetPrices)..where((p) => p.assetId.equals(asset.id))).get();
      expect(prices.isNotEmpty, true);
      expect(prices.first.marketPriceOriginal, '4616.83');

      // Duplicate check
      final dupResult = await executor.executeImport(parsed);
      expect(dupResult.imported, 0);
      expect(dupResult.skippedDuplicates, 1);
    });
  });

  group('NotionInvestParser unitPriceOriginal tests', () {
    test('extracts share price as unitPriceOriginal with Decimal precision', () {
      final rawRows = [
        ['Day', 'Date', 'Invested', 'Rollup', 'Share price', 'Shares', 'Stock', 'THB invested', 'Text'],
        ['@24/06/2024 ', 'June 24, 2024', '\$271.44', '32.37', '\$53.1500', '5.1070555', 'O', '8786.5128', 'THB'],
      ];

      final results = NotionInvestParser.parseRows(rawRows);
      expect(results.length, 1);
      expect(results[0].unitPriceOriginal, Decimal.parse('53.1500'));
    });
  });

  group('NotionInvestImportExecutor Account Routing Tests', () {
    test('routes THB to Dime! Save, FCD to Dime! FCD, USD to Dime! USD, and Dividend to Dime! USD', () async {
      final rows = [
        ParsedInvestRow(
          rowIndex: 1,
          ticker: 'O',
          buyDate: DateTime(2024, 6, 24),
          quantity: Decimal.parse('5.0'),
          amountUsdSatang: 25000,
          fxRate: Decimal.parse('33.650000'),
          amountThbSatang: 841250,
          paymentType: PaymentType.thb,
        ),
        ParsedInvestRow(
          rowIndex: 2,
          ticker: 'NVDA',
          buyDate: DateTime(2024, 6, 25),
          quantity: Decimal.parse('2.0'),
          amountUsdSatang: 20000,
          fxRate: Decimal.parse('33.650000'),
          amountThbSatang: 673000,
          paymentType: PaymentType.fcd,
        ),
        ParsedInvestRow(
          rowIndex: 3,
          ticker: 'MSFT',
          buyDate: DateTime(2024, 6, 26),
          quantity: Decimal.parse('1.0'),
          amountUsdSatang: 40000,
          fxRate: Decimal.parse('33.650000'),
          amountThbSatang: 1346000,
          paymentType: PaymentType.usd,
        ),
        ParsedInvestRow(
          rowIndex: 4,
          ticker: 'JEPQ',
          buyDate: DateTime(2024, 6, 27),
          quantity: Decimal.parse('0.5'),
          amountUsdSatang: 2500,
          fxRate: Decimal.parse('33.650000'),
          amountThbSatang: 84125,
          paymentType: PaymentType.dividend,
        ),
      ];

      final executor = NotionInvestImportExecutor(db);
      final result = await executor.executeImport(rows);
      expect(result.imported, 4);

      final lots = await (db.select(db.investmentLots)..where((l) => l.deletedAt.isNull())).get();
      expect(lots.length, 4);

      final txs = await (db.select(db.transactions)..where((t) => t.deletedAt.isNull())).get();
      final accounts = await db.accountsDao.getActiveAccounts();

      final dimeSave = accounts.firstWhere((a) => a.name == 'Dime! Save');
      final dimeFcd = accounts.firstWhere((a) => a.name == 'Dime! FCD');
      final dimeUsd = accounts.firstWhere((a) => a.name == 'Dime! USD');

      final oTx = txs.firstWhere((t) => t.tag?.contains('O') == true || t.note?.contains('O') == true);
      final nvdaTx = txs.firstWhere((t) => t.tag?.contains('NVDA') == true || t.note?.contains('NVDA') == true);
      final msftTx = txs.firstWhere((t) => t.tag?.contains('MSFT') == true || t.note?.contains('MSFT') == true);
      final jepqTx = txs.firstWhere((t) => t.tag?.contains('JEPQ') == true || t.note?.contains('JEPQ') == true);

      expect(oTx.sourceAccountId, dimeSave.id);
      expect(nvdaTx.sourceAccountId, dimeFcd.id);
      expect(msftTx.sourceAccountId, dimeUsd.id);
      expect(jepqTx.sourceAccountId, dimeUsd.id);
      expect(jepqTx.note, contains('ปันผล'));
    });
  });
}
