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

    test('deduplicateTransactions NEVER deletes manual user transactions with identical name, amount, and date', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');
      final today = DateTime(2026, 10, 24);

      // Simulate user recording two cups of coffee at 60 baht on the same day (morning & afternoon)
      for (int i = 1; i <= 2; i++) {
        await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            id: 'tx-manual-coffee-$i',
            transactionType: 'expense',
            amountOriginalSatang: 6000,
            currencyCode: 'THB',
            amountThbSatang: 6000,
            sourceAccountId: Value(scb.id),
            transactionDate: today.add(Duration(hours: i == 1 ? 9 : 14)),
            note: const Value('กาแฟ'),
            tag: const Value(null),
            createdAt: today.add(Duration(hours: i == 1 ? 9 : 14)),
            updatedAt: today.add(Duration(hours: i == 1 ? 9 : 14)),
          ),
        );
      }

      var txs = await db.transactionsDao.getAllTransactions();
      expect(txs.where((t) => t.note == 'กาแฟ').length, equals(2));

      // Run deduplicateTransactions
      final deletedIds = await db.transactionsDao.deduplicateTransactions();
      expect(deletedIds, isEmpty); // Must NOT delete any manual transaction!

      txs = await db.transactionsDao.getAllTransactions();
      expect(txs.where((t) => t.note == 'กาแฟ').length, equals(2));
    });

    test('processDueRules advances nextRunDate when rule is due but occurrence is already posted', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');
      final oct10 = DateTime(2026, 10, 10);
      final oct16 = DateTime(2026, 10, 16);

      // Create a transaction posted on Oct 10th
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: 'tx-oct10-posted',
          transactionType: 'expense',
          amountOriginalSatang: 120000,
          currencyCode: 'THB',
          amountThbSatang: 120000,
          sourceAccountId: Value(scb.id),
          transactionDate: oct10,
          note: const Value('ค่าบริการ อินเทอร์เน็ต'),
          tag: const Value('recurring_auto'),
          createdAt: oct10,
          updatedAt: oct10,
        ),
      );

      // Create rule with nextRunDate = oct10, lastPostedDate = oct10 (so calculateDueDates returns empty)
      const ruleId = 'rule-internet-due';
      await db.recurringTransactionsDao.createRule(
        RecurringRulesCompanion.insert(
          id: ruleId,
          title: 'ค่าบริการ อินเทอร์เน็ต',
          transactionType: 'expense',
          amountSatang: 120000,
          currencyCode: 'THB',
          frequency: 'monthly',
          dayOfMonth: const Value(10),
          nextRunDate: oct10,
          lastPostedDate: Value(oct10),
          autoPost: const Value(true),
          sourceAccountId: scb.id,
          createdAt: DateTime(2026, 9, 10),
          updatedAt: oct10,
        ),
      );

      // Run processDueRules on Oct 16th: should detect it's already posted and advance nextRunDate to Nov 10th
      final posted = await db.recurringTransactionsDao.processDueRules(nowOverride: oct16);
      expect(posted, equals(0));

      final updatedRule = await db.recurringTransactionsDao.getRuleById(ruleId);
      expect(updatedRule!.nextRunDate.month, equals(11));
      expect(updatedRule.nextRunDate.day, equals(10));
    });

    test('getUpcoming30Days excludes occurrences that have already been posted in current month', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');
      final oct10 = DateTime(2026, 10, 10);
      final oct16 = DateTime(2026, 10, 16);

      // Early posted transaction on Oct 10th
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: 'tx-intern-early',
          transactionType: 'expense',
          amountOriginalSatang: 500000,
          currencyCode: 'THB',
          amountThbSatang: 500000,
          sourceAccountId: Value(scb.id),
          transactionDate: oct10,
          note: const Value('ค่า ER Intern - จ่ายเลขาแนน'),
          tag: const Value('recurring_early_posted'),
          createdAt: oct10,
          updatedAt: oct10,
        ),
      );

      // Recurring rule for ER Intern
      const ruleId = 'rule-intern';
      await db.recurringTransactionsDao.createRule(
        RecurringRulesCompanion.insert(
          id: ruleId,
          title: 'ค่า ER Intern - จ่ายเลขาแนน',
          transactionType: 'expense',
          amountSatang: 500000,
          currencyCode: 'THB',
          frequency: 'monthly',
          dayOfMonth: const Value(10),
          nextRunDate: oct10,
          autoPost: const Value(false),
          sourceAccountId: scb.id,
          createdAt: DateTime(2026, 9, 10),
          updatedAt: oct10,
        ),
      );

      // getUpcoming30Days from Oct 16th: should NOT include the already posted Oct 10th occurrence
      final upcoming = await db.recurringTransactionsDao.getUpcoming30Days(fromDate: oct16);
      final hasInternForOctober = upcoming.any(
        (item) => item.rule.id == ruleId && item.projectedDate.month == 10,
      );
      expect(hasInternForOctober, isFalse);
    });
  });
}
