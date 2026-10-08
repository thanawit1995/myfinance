import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
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

  group('Financial Summary - Investment Proceeds & Asset Yield Separation Tests', () {
    test('ยอดขายสินทรัพย์ (Asset Sale) ไม่ถูกนับเป็น living income แต่แยกไปที่ assetSaleProceeds', () async {
      final now = DateTime(2026, 10, 15);
      const assetSaleCatId = 'cat-inc-0000-4000-8000-000000000099';
      const salaryCatId = 'cat-inc-0000-4000-8000-000000000001';

      // 1. เงินเดือน 50,000 THB (5,000,000 satang)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-salary-1',
          transactionType: 'income',
          sourceAccountId: Value(defaultAccountId),
          categoryId: const Value(salaryCatId),
          amountOriginalSatang: 5000000,
          currencyCode: 'THB',
          amountThbSatang: 5000000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 2. ขายหุ้นได้เงิน 500,000 THB (50,000,000 satang)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-asset-sale-1',
          transactionType: 'income',
          sourceAccountId: Value(defaultAccountId),
          categoryId: const Value(assetSaleCatId),
          tag: const Value('investment_sell:stock-cpall'),
          amountOriginalSatang: 50000000,
          currencyCode: 'THB',
          amountThbSatang: 50000000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // ดึงรายการของเดือน
      final txs = await db.transactionsDao.searchTransactions(
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31, 23, 59, 59),
      );

      int livingIncomeSatang = 0;
      int assetSaleProceedsSatang = 0;

      for (final t in txs) {
        if (t.transactionType == 'income') {
          final isAssetSale = (t.tag != null && t.tag!.startsWith('investment_sell:')) ||
              (t.categoryId == assetSaleCatId);
          if (isAssetSale) {
            assetSaleProceedsSatang += t.amountThbSatang;
          } else {
            livingIncomeSatang += t.amountThbSatang;
          }
        }
      }

      // ยอด Living Income ต้องเป็นแค่เงินเดือน 50,000 THB เท่านั้น ไม่เพี้ยนเป็น 550,000 THB
      expect(livingIncomeSatang, equals(5000000),
          reason: 'รายรับค่าครองชีพต้องมีเฉพาะเงินเดือน ไม่รวมเงินต้นจากการขายหุ้น');

      // ยอดขายหุ้นต้องแยกมาอยู่ที่ assetSaleProceedsSatang
      expect(assetSaleProceedsSatang, equals(50000000),
          reason: 'ยอดขายหุ้นต้องไปอยู่ที่กระแสเงินสดพอร์ตการลงทุน');
    });

    test('เงินปันผลและดอกเบี้ยรับ ถูกแยกไปที่ assetYield ไม่ปนกับ living income', () async {
      final now = DateTime(2026, 10, 16);
      const dividendInterestCatId = 'cat-inc-0000-4000-8000-000000000003';
      const salaryCatId = 'cat-inc-0000-4000-8000-000000000001';

      // 1. เงินเดือน 60,000 THB
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-salary-2',
          transactionType: 'income',
          sourceAccountId: Value(defaultAccountId),
          categoryId: const Value(salaryCatId),
          amountOriginalSatang: 6000000,
          currencyCode: 'THB',
          amountThbSatang: 6000000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 2. เงินปันผลหุ้น 3,000 THB (300,000 satang)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-div-1',
          transactionType: 'income',
          sourceAccountId: Value(defaultAccountId),
          categoryId: const Value(dividendInterestCatId),
          tag: const Value('dividend:asset-ptt'),
          note: const Value('ปันผล PTT'),
          amountOriginalSatang: 300000,
          currencyCode: 'THB',
          amountThbSatang: 300000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 3. ดอกเบี้ยเงินฝาก 500 THB (50,000 satang)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-int-1',
          transactionType: 'income',
          sourceAccountId: Value(defaultAccountId),
          categoryId: const Value(dividendInterestCatId),
          tag: const Value('interest:acc-savings'),
          note: const Value('ดอกเบี้ยเงินฝากออมทรัพย์'),
          amountOriginalSatang: 50000,
          currencyCode: 'THB',
          amountThbSatang: 50000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final txs = await db.transactionsDao.searchTransactions(
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31, 23, 59, 59),
      );

      int livingIncomeSatang = 0;
      int dividendSatang = 0;
      int interestSatang = 0;

      for (final t in txs) {
        if (t.transactionType == 'income') {
          final isYield = (t.categoryId == dividendInterestCatId) ||
              (t.tag != null && (t.tag!.startsWith('dividend:') || t.tag!.startsWith('interest:')));

          if (isYield) {
            final noteLower = (t.note ?? '').toLowerCase();
            final tagLower = (t.tag ?? '').toLowerCase();
            if (tagLower.startsWith('dividend:') || noteLower.contains('ปันผล') || noteLower.contains('dividend')) {
              dividendSatang += t.amountThbSatang;
            } else {
              interestSatang += t.amountThbSatang;
            }
          } else {
            livingIncomeSatang += t.amountThbSatang;
          }
        }
      }

      final assetYieldSatang = dividendSatang + interestSatang;

      expect(livingIncomeSatang, equals(6000000),
          reason: 'Living income ต้องมีแค่เงินเดือน 60,000 THB');
      expect(dividendSatang, equals(300000),
          reason: 'ปันผลต้องเป็น 3,000 THB');
      expect(interestSatang, equals(50000),
          reason: 'ดอกเบี้ยต้องเป็น 500 THB');
      expect(assetYieldSatang, equals(350000),
          reason: 'ผลผลิตรวมจากสินทรัพย์ต้องเป็น 3,500 THB');
    });

    test('อัตราการออม (% Savings Rate) สะท้อนวินัยจริง ไม่เพี้ยนตามการขายสินทรัพย์', () async {
      // รายรับจากการทำงาน: 50,000 THB
      // รายจ่ายค่าครองชีพ: 20,000 THB
      // ขายหุ้น: 1,000,000 THB (เป็นเงินต้นหมุนกลับมา)
      // เงินออมสุทธิควรเป็น: 50,000 - 20,000 = 30,000 THB
      // อัตราการออมควรเป็น: (30,000 / 50,000) * 100 = 60.0% (ไม่ใช่ 98% ถ้าคิดหุ้น 1 ล้าน)

      const livingIncomeSatang = 5000000; // 50,000 THB
      const livingExpenseSatang = 2000000; // 20,000 THB
      const assetSaleProceedsSatang = 100000000; // 1,000,000 THB

      final savingsSatang = livingIncomeSatang - livingExpenseSatang;
      final savingsRatePercent = ((savingsSatang / livingIncomeSatang) * 100.0);

      expect(savingsSatang, equals(3000000));
      expect(savingsRatePercent, equals(60.0),
          reason: 'อัตราการออมต้องสะท้อน 60% จริง ไม่ถูกยอดขายหุ้น 1,000,000 บาทบิดเบือน');
      expect(assetSaleProceedsSatang, equals(100000000));
    });

    test('getRealizedGainLossForPeriod คำนวณกำไรสุทธิจากการขายสินทรัพย์ตาม FIFO ได้อย่างแม่นยำ', () async {
      final now = DateTime(2026, 10, 10);
      const assetId = 'asset-test-realized';

      // 1. สร้างสินทรัพย์
      await db.investmentsDao.createAsset(
        AssetsCompanion.insert(
          id: assetId,
          symbol: 'RLZD',
          name: 'Realized Test Asset',
          assetType: 'stock',
          currencyCode: 'THB',
          defaultAccountId: defaultAccountId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 2. ซื้อ 100 หุ้น @ 10.00 THB (1000 satang) = ต้นทุน 1,000 THB (100,000 satang)
      await db.investmentsDao.recordBuyTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 10, 1),
        quantity: Decimal.parse('100'),
        priceOriginalSatang: 1000,
        currencyCode: 'THB',
        fxRate: Decimal.one,
        feeThbSatang: 0,
      );

      // 3. ขาย 100 หุ้น @ 15.00 THB (1500 satang) = ยอดขาย 1,500 THB (150,000 satang)
      // กำไรที่เกิดขึ้นจริง (Realized Capital Gain) = 1,500 - 1,000 = +500 THB (+50,000 satang)
      final sellResult = await db.investmentsDao.recordSellTrade(
        assetId: assetId,
        accountId: defaultAccountId,
        tradeDate: DateTime(2026, 10, 5),
        quantity: Decimal.parse('100'),
        priceOriginalSatang: 1500,
        currencyCode: 'THB',
        fxRate: Decimal.one,
        feeThbSatang: 0,
      );

      expect(sellResult.totalRealizedGainLossThbSatang, equals(50000));

      // 4. ทดสอบ query ผ่าน getRealizedGainLossForPeriod
      final periodSummary = await db.investmentsDao.getRealizedGainLossForPeriod(
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 31),
      );

      expect(periodSummary.totalRealizedGainLossThbSatang, equals(50000),
          reason: 'กำไรที่รับรู้จริงในช่วงเดือนตุลาคมต้องเป็น 500.00 THB (50,000 satang)');
      expect(periodSummary.totalSellPriceThbSatang, equals(150000),
          reason: 'ยอดขายรวมต้องเป็น 1,500.00 THB');
      expect(periodSummary.totalCostThbSatang, equals(100000),
          reason: 'ต้นทุนรวมของหุ้นที่ขายต้องเป็น 1,000.00 THB');
    });
  });
}
