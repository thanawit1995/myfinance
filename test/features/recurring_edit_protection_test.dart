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

  group('Recurring Transactions - Edit Protection & Supabase Safety Tests', () {
    test('Editing time/date of a recurring transaction must NOT be soft-deleted by repair routine', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');

      // Rule scheduled for the 25th of every month
      const ruleId = 'rule-edit-protection-25th';
      final nov25 = DateTime(2026, 11, 25);
      await db.recurringTransactionsDao.createRule(
        RecurringRulesCompanion.insert(
          id: ruleId,
          title: 'ค่าบริการอินเทอร์เน็ต AIS Fibre',
          transactionType: 'expense',
          amountSatang: 64093, // ฿640.93
          currencyCode: 'THB',
          frequency: 'monthly',
          dayOfMonth: const Value(25),
          nextRunDate: nov25,
          autoPost: const Value(true),
          sourceAccountId: scb.id,
          createdAt: DateTime(2026, 11, 1),
          updatedAt: DateTime(2026, 11, 1),
        ),
      );

      // Auto-posted on Nov 25th
      const txId = 'tx-recurring-ais-nov';
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'expense',
          amountOriginalSatang: 64093,
          currencyCode: 'THB',
          amountThbSatang: 64093,
          sourceAccountId: Value(scb.id),
          transactionDate: nov25,
          note: const Value('สร้างอัตโนมัติจากกฎ: ค่าบริการอินเทอร์เน็ต AIS Fibre'),
          tag: const Value('recurring_auto'),
          createdAt: nov25,
          updatedAt: nov25,
        ),
      );

      // User edits the transaction:
      // Time or date is adjusted to Nov 24th (e.g. user paid one day early or time adjusted)
      final nov24 = DateTime(2026, 11, 24, 14, 30);
      await db.transactionsDao.updateTransaction(
        TransactionsCompanion(
          id: const Value(txId),
          transactionDate: Value(nov24),
          tag: const Value('recurring_manual_confirmed'),
          updatedAt: Value(nov24),
        ),
      );

      // Run repairErroneousAutoPostsAndAlignDates
      final repaired = await db.recurringTransactionsDao.repairErroneousAutoPostsAndAlignDates(
        nowOverride: DateTime(2026, 11, 28),
      );

      // Must NOT soft-delete this user-edited transaction!
      expect(repaired.contains(txId), isFalse);

      final tx = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingle();
      expect(tx.deletedAt, isNull);
      expect(tx.transactionDate.toLocal().day, equals(24));
    });

    test('Edited recurring transaction remains satisfied and does NOT reappear in upcoming bell notifications', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');

      const ruleId = 'rule-bell-protection';
      final nov25 = DateTime(2026, 11, 25);
      final nextRun = DateTime(2026, 12, 25);

      await db.recurringTransactionsDao.createRule(
        RecurringRulesCompanion.insert(
          id: ruleId,
          title: 'ค่าน้ำประปา',
          transactionType: 'expense',
          amountSatang: 25000,
          currencyCode: 'THB',
          frequency: 'monthly',
          dayOfMonth: const Value(25),
          nextRunDate: nextRun,
          autoPost: const Value(true),
          sourceAccountId: scb.id,
          lastPostedDate: Value(nov25),
          createdAt: DateTime(2026, 11, 1),
          updatedAt: DateTime(2026, 11, 25),
        ),
      );

      const txId = 'tx-water-nov';
      // User modified date to 24th and amount to 260.00 THB (adjusted utility bill)
      final nov24 = DateTime(2026, 11, 24, 10, 15);
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'expense',
          amountOriginalSatang: 26000, // adjusted from 25000
          currencyCode: 'THB',
          amountThbSatang: 26000,
          sourceAccountId: Value(scb.id),
          transactionDate: nov24,
          note: const Value('ค่าน้ำประปา เดือน พ.ย.'),
          tag: const Value('recurring_manual_confirmed'),
          createdAt: nov24,
          updatedAt: nov24,
        ),
      );

      final rule = await db.recurringTransactionsDao.getRuleById(ruleId);
      expect(rule, isNotNull);

      // isOccurrenceAlreadyPosted should recognize that November was satisfied
      final isPosted = await db.recurringTransactionsDao.isOccurrenceAlreadyPosted(
        rule: rule!,
        targetDate: nov25,
      );
      expect(isPosted, isTrue);

      // On Nov 26th, upcoming for next 7 days should NOT show the November occurrence
      final upcoming = await db.recurringTransactionsDao.getUpcoming30Days(
        windowDays: 7,
        fromDate: DateTime(2026, 11, 26),
      );
      final hasNovWater = upcoming.any((u) => u.rule.id == ruleId && u.projectedDate.month == 11);
      expect(hasNovWater, isFalse);
    });

    test('Auto-restores legitimate transactions that were previously soft-deleted outside the Oct 15 bug', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');

      const txId = 'tx-accidental-delete-nov';
      final nov20 = DateTime(2026, 11, 20);

      // Simulate transaction that was soft-deleted by the previous bug
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'expense',
          amountOriginalSatang: 30000,
          currencyCode: 'THB',
          amountThbSatang: 30000,
          sourceAccountId: Value(scb.id),
          transactionDate: nov20,
          note: const Value('ค่าทำความสะอาดคอนโด'),
          tag: const Value('recurring_auto'),
          deletedAt: Value(nov20),
          createdAt: nov20,
          updatedAt: nov20,
        ),
      );

      // Simulate the audit log recorded by SOFT_DELETE_ERRONEOUS_RECURRING
      await db.into(db.auditLogs).insert(
        AuditLogsCompanion.insert(
          id: 'audit-soft-delete-1',
          entityTable: 'transactions',
          entityId: txId,
          action: 'SOFT_DELETE_ERRONEOUS_RECURRING',
          changeTimestamp: nov20,
          createdAt: nov20,
          updatedAt: nov20,
        ),
      );

      // Run repairErroneousAutoPostsAndAlignDates
      await db.recurringTransactionsDao.repairErroneousAutoPostsAndAlignDates(
        nowOverride: DateTime(2026, 11, 28),
      );

      // Verify the transaction was automatically un-deleted and restored!
      final restoredTx = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingle();
      expect(restoredTx.deletedAt, isNull);

      // Verify audit log for restore was recorded
      final logs = await (db.select(db.auditLogs)..where((a) => a.entityId.equals(txId))).get();
      final hasRestoreLog = logs.any((l) => l.action == 'RESTORE_LEGITIMATE_RECURRING');
      expect(hasRestoreLog, isTrue);
    });

    test('Oct 15 2026 sync bug erroneous transactions are still properly cleaned up', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final scb = accounts.firstWhere((a) => a.name == 'SCB');

      const ruleId = 'rule-oct15-bug-test';
      final oct15 = DateTime(2026, 10, 15);
      await db.recurringTransactionsDao.createRule(
        RecurringRulesCompanion.insert(
          id: ruleId,
          title: 'YouTube Premium รายเดือน',
          transactionType: 'expense',
          amountSatang: 17900,
          currencyCode: 'THB',
          frequency: 'monthly',
          dayOfMonth: const Value(28), // Should be 28th!
          nextRunDate: oct15,
          autoPost: const Value(true),
          sourceAccountId: scb.id,
          createdAt: oct15,
          updatedAt: oct15,
        ),
      );

      const txId = 'tx-erroneous-yt-oct15';
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'expense',
          amountOriginalSatang: 17900,
          currencyCode: 'THB',
          amountThbSatang: 17900,
          sourceAccountId: Value(scb.id),
          transactionDate: oct15,
          note: const Value('สร้างอัตโนมัติจากกฎ: YouTube Premium รายเดือน'),
          tag: const Value('recurring_auto'),
          createdAt: oct15,
          updatedAt: oct15,
        ),
      );

      final repaired = await db.recurringTransactionsDao.repairErroneousAutoPostsAndAlignDates(nowOverride: oct15);
      expect(repaired, contains(txId));

      final deletedTx = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingle();
      expect(deletedTx.deletedAt, isNotNull);
    });
  });
}
