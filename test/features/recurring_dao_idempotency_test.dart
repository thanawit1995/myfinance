import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
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

  group('RecurringTransactionsDao - Idempotency & Deduplication Tests', () {
    test('processDueRules creates transaction and subsequent calls on same day do not duplicate', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');

      // Create recurring rule due today (2026-10-09)
      final today = DateTime(2026, 10, 9);
      const ruleId = 'rule-ais-test';
      await db.recurringTransactionsDao.createRule(
        RecurringRulesCompanion.insert(
          id: ruleId,
          title: 'AIS ค่าบริการรายเดือน',
          transactionType: 'expense',
          amountSatang: 53393, // ฿533.93
          currencyCode: 'THB',
          frequency: 'monthly',
          dayOfMonth: const Value(9),
          nextRunDate: today,
          autoPost: const Value(true),
          sourceAccountId: scb.id,
          createdAt: today,
          updatedAt: today,
        ),
      );

      // 1st run of processDueRules
      final posted1 = await db.recurringTransactionsDao.processDueRules(nowOverride: today);
      expect(posted1, equals(1));

      var txs = await db.transactionsDao.getAllTransactions();
      final aisTxs = txs.where((t) => t.amountOriginalSatang == 53393).toList();
      expect(aisTxs.length, equals(1));

      // 2nd run of processDueRules on same day (simulating app reopen or restart)
      final posted2 = await db.recurringTransactionsDao.processDueRules(nowOverride: today);
      expect(posted2, equals(0));

      txs = await db.transactionsDao.getAllTransactions();
      final aisTxsAfter2 = txs.where((t) => t.amountOriginalSatang == 53393).toList();
      expect(aisTxsAfter2.length, equals(1)); // Still exactly 1!
    });

    test('If sync wiped lastPostedDate or reset nextRunDate to today, existing transaction prevents duplicate', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');
      final today = DateTime(2026, 10, 9);

      // Create rule and insert first transaction
      const ruleId = 'rule-netflix-test';
      await db.recurringTransactionsDao.createRule(
        RecurringRulesCompanion.insert(
          id: ruleId,
          title: 'Netflix',
          transactionType: 'expense',
          amountSatang: 41900,
          currencyCode: 'THB',
          frequency: 'monthly',
          dayOfMonth: const Value(9),
          nextRunDate: today,
          autoPost: const Value(true),
          sourceAccountId: scb.id,
          createdAt: today,
          updatedAt: today,
        ),
      );

      await db.recurringTransactionsDao.processDueRules(nowOverride: today);

      // Simulate stale sync pull overwriting rule with nextRunDate = today and lastPostedDate = null
      await (db.update(db.recurringRules)..where((r) => r.id.equals(ruleId))).write(
        RecurringRulesCompanion(
          nextRunDate: Value(today),
          lastPostedDate: const Value(null),
          updatedAt: Value(today),
        ),
      );

      // Run processDueRules again: idempotency check should find existing transaction for today and NOT duplicate
      final posted = await db.recurringTransactionsDao.processDueRules(nowOverride: today);
      expect(posted, equals(0));

      final allTxs = await db.transactionsDao.getAllTransactions();
      final netflixTxs = allTxs.where((t) => t.amountOriginalSatang == 41900).toList();
      expect(netflixTxs.length, equals(1));

      // Check that rule's nextRunDate was advanced to next cycle (Nov 9th)
      final updatedRule = await db.recurringTransactionsDao.getRuleById(ruleId);
      expect(updatedRule!.nextRunDate.month, equals(11));
      expect(updatedRule.lastPostedDate, isNotNull);
    });

    test('deduplicateTransactions automatically cleans up duplicate entries created previously', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');
      final today = DateTime(2026, 10, 9);

      // Insert 3 duplicate transactions manually (simulating the bug previously reported by user)
      for (int i = 1; i <= 3; i++) {
        await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            id: 'tx-ais-dup-$i',
            transactionType: 'expense',
            amountOriginalSatang: 53393,
            currencyCode: 'THB',
            amountThbSatang: 53393,
            sourceAccountId: Value(scb.id),
            transactionDate: today,
            note: const Value('สร้างอัตโนมัติจากกฎ: AIS'),
            tag: const Value('recurring_auto'),
            createdAt: today.add(Duration(minutes: i * 5)),
            updatedAt: today.add(Duration(minutes: i * 5)),
          ),
        );
      }

      var txs = await db.transactionsDao.getAllTransactions();
      expect(txs.where((t) => t.amountOriginalSatang == 53393).length, equals(3));

      // Run deduplicateTransactions
      final deletedIds = await db.transactionsDao.deduplicateTransactions();
      expect(deletedIds.length, equals(2));

      txs = await db.transactionsDao.getAllTransactions();
      expect(txs.where((t) => t.amountOriginalSatang == 53393).length, equals(1));
    });
  });
}
