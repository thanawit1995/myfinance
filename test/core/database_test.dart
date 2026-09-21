import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  group('Database & Seed Data Tests', () {
    test('Database initializes and inserts Seed Data correctly', () async {
      // 1. Verify Currencies
      final currencies = await db.select(db.currencies).get();
      expect(currencies.length, equals(2));
      final thb = currencies.firstWhere((c) => c.code == 'THB');
      final usd = currencies.firstWhere((c) => c.code == 'USD');
      expect(thb.isBase, isTrue);
      expect(thb.symbol, equals('฿'));
      expect(usd.isBase, isFalse);
      expect(usd.symbol, equals(r'$'));

      // 2. Verify 6 Accounts
      final accounts = await db.select(db.accounts).get();
      expect(accounts.length, equals(6));

      final scb = accounts.firstWhere((a) => a.name == 'SCB');
      expect(scb.currencyCode, equals('THB'));
      expect(scb.isDomestic, isTrue);
      expect(scb.accountType, equals('bank'));

      final ktb = accounts.firstWhere((a) => a.name == 'Krungthai');
      expect(ktb.currencyCode, equals('THB'));
      expect(ktb.isDomestic, isTrue);

      final dimeSave = accounts.firstWhere((a) => a.name == 'Dime! Save');
      expect(dimeSave.currencyCode, equals('THB'));
      expect(dimeSave.isDomestic, isTrue);

      final dimeFcd = accounts.firstWhere((a) => a.name == 'Dime! FCD');
      expect(dimeFcd.currencyCode, equals('USD'));
      expect(dimeFcd.isDomestic, isTrue);
      expect(dimeFcd.accountType, equals('fcd'));

      final dimeUsd = accounts.firstWhere((a) => a.name == 'Dime! USD');
      expect(dimeUsd.currencyCode, equals('USD'));
      expect(dimeUsd.isDomestic, isFalse);
      expect(dimeUsd.accountType, equals('offshore'));

      final creditCard = accounts.firstWhere((a) => a.name == 'บัตรเครดิต');
      expect(creditCard.currencyCode, equals('THB'));
      expect(creditCard.isDomestic, isTrue);
      expect(creditCard.accountType, equals('credit_card'));
      expect(creditCard.closingDay, equals(23)); // 23rd every month
      expect(creditCard.dueDay, equals(10));

      // 3. Verify Categories
      final categories = await db.select(db.categories).get();
      expect(categories.length, greaterThanOrEqualTo(16));
      expect(categories.any((c) => c.nameTh == 'เงินเดือน' && c.taxIncomeType == '40_1'), isTrue);
      expect(categories.any((c) => c.nameTh == 'รับจ้าง / ค่าอยู่เวร' && c.taxIncomeType == '40_2'), isTrue);
      expect(categories.any((c) => c.nameTh == 'ดอกเบี้ยและเงินปันผล' && c.taxIncomeType == '40_4'), isTrue);
      expect(categories.any((c) => c.nameTh == 'ธุรกิจ / ขายของ' && c.taxIncomeType == '40_8'), isTrue);
      expect(categories.any((c) => c.nameTh == 'อาหารและเครื่องดื่ม'), isTrue);
      expect(categories.any((c) => c.nameTh == 'โอนเงินระหว่างบัญชี'), isTrue);

      // 4. Verify Financial Health Settings (8 metrics)
      final health = await db.select(db.financialHealthSettings).get();
      expect(health.length, equals(8));
      expect(health.any((h) => h.metricCode == 'liquidity' && h.targetOperator == '>'), isTrue);
      expect(health.any((h) => h.metricCode == 'emergency_fund' && h.targetOperator == '>='), isTrue);
      expect(health.any((h) => h.metricCode == 'debt_burden' && h.targetOperator == '<'), isTrue);
    });

    test('Can record append-only transaction and balance snapshot', () async {
      final now = DateTime.now();
      final accounts = await db.select(db.accounts).get();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');
      final categories = await db.select(db.categories).get();
      final salaryCat = categories.firstWhere((c) => c.nameTh == 'เงินเดือน');

      // Insert salary income
      final transId = 'test-trans-0000-0000-000000000001';
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: transId,
          transactionType: 'income',
          sourceAccountId: Value(scb.id),
          categoryId: Value(salaryCat.id),
          amountOriginalSatang: 5000000, // 50,000.00 THB
          currencyCode: 'THB',
          amountThbSatang: 5000000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final trans = await (db.select(db.transactions)..where((t) => t.id.equals(transId))).getSingle();
      expect(trans.amountThbSatang, equals(5000000));
      expect(trans.currencyCode, equals('THB'));

      // Insert snapshot
      final snapshotId = 'snap-0000-0000-000000000001';
      await db.into(db.balanceSnapshots).insert(
        BalanceSnapshotsCompanion.insert(
          id: snapshotId,
          accountId: scb.id,
          snapshotDate: now,
          closingBalanceSatang: 5000000,
          currencyCode: 'THB',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final snapshot = await (db.select(db.balanceSnapshots)..where((s) => s.id.equals(snapshotId))).getSingle();
      expect(snapshot.closingBalanceSatang, equals(5000000));
    });
  });
}
