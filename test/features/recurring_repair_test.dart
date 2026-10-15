import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  group('RecurringTransactionsDao - Erroneous Auto-Post Repair & Alignment Tests', () {
    test('repairErroneousAutoPostsAndAlignDates soft-deletes erroneous Oct 15 transaction and realigns rule to Oct 25', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');

      final initialBalance = await db.accountsDao.getAccountBalanceSatang(scb.id);

      // Simulating a rule scheduled for the 25th of the month
      const ruleId = 'rule-salary-or-bill-25th';
      final oct15 = DateTime(2026, 10, 15);
      await db.recurringTransactionsDao.createRule(
        RecurringRulesCompanion.insert(
          id: ruleId,
          title: 'ค่าสมาชิก Netflix รายเดือน',
          transactionType: 'expense',
          amountSatang: 8400, // ฿84.00
          currencyCode: 'THB',
          frequency: 'monthly',
          dayOfMonth: const Value(25), // Should run on 25th!
          nextRunDate: oct15, // Erroneously set to 15th
          autoPost: const Value(true),
          sourceAccountId: scb.id,
          lastPostedDate: Value(oct15), // Erroneously posted on 15th
          createdAt: oct15,
          updatedAt: oct15,
        ),
      );

      // Simulating the mistakenly auto-posted transaction on Oct 15th
      const txId = 'tx-erroneous-netflix-15';
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'expense',
          amountOriginalSatang: 8400,
          currencyCode: 'THB',
          amountThbSatang: 8400,
          sourceAccountId: Value(scb.id),
          transactionDate: oct15,
          note: const Value('สร้างอัตโนมัติจากกฎ: ค่าสมาชิก Netflix รายเดือน'),
          tag: const Value('recurring_auto'),
          createdAt: oct15,
          updatedAt: oct15,
        ),
      );

      // Verify the erroneous transaction lowered the balance
      final balanceAfterError = await db.accountsDao.getAccountBalanceSatang(scb.id);
      expect(balanceAfterError, equals(initialBalance - 8400));

      // Run repair
      final repairedCount = await db.recurringTransactionsDao.repairErroneousAutoPostsAndAlignDates();
      expect(repairedCount, equals(1));

      // 1. Transaction should now be soft-deleted
      final repairedTx = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingle();
      expect(repairedTx.deletedAt, isNotNull);

      // 2. Account balance should be automatically restored to initialBalance!
      final restoredBalance = await db.accountsDao.getAccountBalanceSatang(scb.id);
      expect(restoredBalance, equals(initialBalance));

      // 3. Rule should be realigned to Oct 25th and lastPostedDate cleared from Oct 15th
      final ruleAfter = await db.recurringTransactionsDao.getRuleById(ruleId);
      expect(ruleAfter, isNotNull);
      expect(ruleAfter!.dayOfMonth, equals(25));
      expect(ruleAfter.nextRunDate.year, equals(2026));
      expect(ruleAfter.nextRunDate.month, equals(10));
      expect(ruleAfter.nextRunDate.day, equals(25));
      expect(ruleAfter.lastPostedDate, isNull);

      // 4. Running processDueRules on Oct 15th should post 0 transactions
      final postedOnOct15 = await db.recurringTransactionsDao.processDueRules(nowOverride: oct15);
      expect(postedOnOct15, equals(0));

      // 5. When Oct 25th arrives, processDueRules will properly post on the 25th
      final oct25 = DateTime(2026, 10, 25);
      final postedOnOct25 = await db.recurringTransactionsDao.processDueRules(nowOverride: oct25);
      expect(postedOnOct25, equals(1));
    });

    test('Legitimate transactions on the correct dayOfMonth are preserved', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');

      // Rule legitimately scheduled for the 15th
      const ruleId = 'rule-15th-legit';
      final oct15 = DateTime(2026, 10, 15);
      await db.recurringTransactionsDao.createRule(
        RecurringRulesCompanion.insert(
          id: ruleId,
          title: 'รายการวันที่ 15 แท้จริง',
          transactionType: 'expense',
          amountSatang: 50000,
          currencyCode: 'THB',
          frequency: 'monthly',
          dayOfMonth: const Value(15),
          nextRunDate: oct15,
          autoPost: const Value(true),
          sourceAccountId: scb.id,
          lastPostedDate: Value(oct15),
          createdAt: oct15,
          updatedAt: oct15,
        ),
      );

      const txId = 'tx-legit-15';
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'expense',
          amountOriginalSatang: 50000,
          currencyCode: 'THB',
          amountThbSatang: 50000,
          sourceAccountId: Value(scb.id),
          transactionDate: oct15,
          note: const Value('สร้างอัตโนมัติจากกฎ: รายการวันที่ 15 แท้จริง'),
          tag: const Value('recurring_auto'),
          createdAt: oct15,
          updatedAt: oct15,
        ),
      );

      final repairedCount = await db.recurringTransactionsDao.repairErroneousAutoPostsAndAlignDates();
      // Should not repair legitimate transactions!
      expect(repairedCount, equals(0));

      final tx = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingle();
      expect(tx.deletedAt, isNull);
    });
  });
}
