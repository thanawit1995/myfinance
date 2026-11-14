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

  group('TransactionsDao - Summary Work Period Attribution Tests', () {
    test('Accrued income for Sep 2026 recorded on Oct 10 2026 belongs to Sep summary, not Oct', () async {
      final now = DateTime.now();
      const txId = 'tx-accrued-sep-in-oct';

      // Insert transaction "เงินหมื่นไม่ทำเวช":
      // transactionDate is 2026-10-10, but workPeriod is '2026-09' (Sep 2026 income)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'income',
          amountOriginalSatang: 1000000, // 10,000 THB
          currencyCode: 'THB',
          amountThbSatang: 1000000,
          feeThbSatang: const Value(0),
          note: const Value('เงินหมื่นไม่ทำเวช'),
          transactionDate: DateTime(2026, 10, 10),
          workPeriod: const Value('2026-09'),
          isCleared: const Value(false),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Query for September 2026 summary
      final sepTxs = await db.transactionsDao.getTransactionsForSummary(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 30, 23, 59, 59, 999),
        targetWorkPeriod: '2026-09',
      );

      expect(sepTxs.any((t) => t.id == txId), isTrue,
          reason: 'Sep 2026 summary must include the accrued income for Sep 2026');

      // Query for October 2026 summary
      final octTxs = await db.transactionsDao.getTransactionsForSummary(
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31, 23, 59, 59, 999),
        targetWorkPeriod: '2026-10',
      );

      expect(octTxs.any((t) => t.id == txId), isFalse,
          reason: 'Oct 2026 summary must NOT include accrued income belonging to Sep 2026');
    });

    test('Regular transactions without workPeriod are attributed by transactionDate', () async {
      final now = DateTime.now();
      const octExpenseId = 'tx-oct-expense';

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: octExpenseId,
          transactionType: 'expense',
          amountOriginalSatang: 50000,
          currencyCode: 'THB',
          amountThbSatang: 50000,
          feeThbSatang: const Value(0),
          note: const Value('Dinner'),
          transactionDate: DateTime(2026, 10, 10),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final sepTxs = await db.transactionsDao.getTransactionsForSummary(
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 30, 23, 59, 59, 999),
        targetWorkPeriod: '2026-09',
      );
      expect(sepTxs.any((t) => t.id == octExpenseId), isFalse);

      final octTxs = await db.transactionsDao.getTransactionsForSummary(
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31, 23, 59, 59, 999),
        targetWorkPeriod: '2026-10',
      );
      expect(octTxs.any((t) => t.id == octExpenseId), isTrue);
    });

    test('Cash basis mode attributes income by transactionDate regardless of workPeriod', () async {
      final now = DateTime.now();
      const p4pId = 'tx-p4p-sep-received-oct';

      // P4P of Sep 2026 (workPeriod = '2026-09') received on Oct 26, 2026
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: p4pId,
          transactionType: 'income',
          amountOriginalSatang: 1050375, // 10,503.75 THB
          currencyCode: 'THB',
          amountThbSatang: 1050375,
          feeThbSatang: const Value(0),
          note: const Value('P4P'),
          transactionDate: DateTime(2026, 10, 26),
          workPeriod: const Value('2026-09'),
          isCleared: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // In Work Period mode for October: P4P belonging to Sep must NOT be in Oct summary
      final octWorkPeriodTxs = await db.transactionsDao.getTransactionsForSummary(
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31, 23, 59, 59, 999),
        targetWorkPeriod: '2026-10',
        isCashBasis: false,
      );
      expect(octWorkPeriodTxs.any((t) => t.id == p4pId), isFalse,
          reason: 'Work period mode assigns P4P to Sep');

      // In Cash Basis mode for October: P4P received on Oct 26 MUST be included in Oct summary
      final octCashBasisTxs = await db.transactionsDao.getTransactionsForSummary(
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31, 23, 59, 59, 999),
        targetWorkPeriod: '2026-10',
        isCashBasis: true,
      );
      expect(octCashBasisTxs.any((t) => t.id == p4pId), isTrue,
          reason: 'Cash basis mode includes all money received in October');
    });

    test('markIncomeAsReceived preserves or auto-assigns workPeriod from original transaction date', () async {
      final now = DateTime.now();
      const txId = 'tx-unspecified-accrued';

      // Accrued income initially recorded on Oct 26, 2026 without workPeriod
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'income',
          amountOriginalSatang: 1000000,
          currencyCode: 'THB',
          amountThbSatang: 1000000,
          feeThbSatang: const Value(0),
          note: const Value('เงินส่งเสริมพิเศษ'),
          transactionDate: DateTime(2026, 10, 26),
          workPeriod: const Value(null),
          isCleared: const Value(false),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // User marks as received on Nov 11, 2026
      final success = await db.transactionsDao.markIncomeAsReceived(
        txId,
        accountId: 'acc-1',
        receivedDate: DateTime(2026, 11, 11),
      );
      expect(success, isTrue);

      final updated = await db.transactionsDao.getTransactionById(txId);
      expect(updated, isNotNull);
      expect(updated!.isCleared, isTrue);
      expect(updated.transactionDate, equals(DateTime(2026, 11, 11)));
      // Auto-assigned workPeriod should be '2026-10' (preserved from original transaction date)
      expect(updated.workPeriod, equals('2026-10'));
    });

    test('duplicateTransaction clones transaction with new ID and target date', () async {
      final now = DateTime.now();
      const originId = 'tx-origin-salary';

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: originId,
          transactionType: 'income',
          amountOriginalSatang: 2422000,
          currencyCode: 'THB',
          amountThbSatang: 2422000,
          feeThbSatang: const Value(0),
          note: const Value('เงินเดือน'),
          transactionDate: DateTime(2026, 10, 26),
          workPeriod: const Value('2026-10'),
          isCleared: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final duplicated = await db.transactionsDao.duplicateTransaction(
        originId,
        newDate: DateTime(2026, 11, 26),
      );

      expect(duplicated, isNotNull);
      expect(duplicated!.id, isNot(equals(originId)));
      expect(duplicated.amountOriginalSatang, equals(2422000));
      expect(duplicated.note, equals('เงินเดือน'));
      expect(duplicated.transactionDate, equals(DateTime(2026, 11, 26)));
      expect(duplicated.workPeriod, equals('2026-11'));
    });

    test('getRecentTransactionsByType filters by transactionType and sinceDate', () async {
      final now = DateTime.now();

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-recent-exp-1',
          transactionType: 'expense',
          amountOriginalSatang: 5000,
          currencyCode: 'THB',
          amountThbSatang: 5000,
          note: const Value('Coffee'),
          transactionDate: now.subtract(const Duration(days: 5)),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-old-exp-2',
          transactionType: 'expense',
          amountOriginalSatang: 12000,
          currencyCode: 'THB',
          amountThbSatang: 12000,
          note: const Value('Buffet 40 days ago'),
          transactionDate: now.subtract(const Duration(days: 40)),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-recent-inc-1',
          transactionType: 'income',
          amountOriginalSatang: 50000,
          currencyCode: 'THB',
          amountThbSatang: 50000,
          note: const Value('Part time'),
          transactionDate: now.subtract(const Duration(days: 2)),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final recentExpenses = await db.transactionsDao.getRecentTransactionsByType(
        transactionType: 'expense',
        sinceDate: now.subtract(const Duration(days: 30)),
      );

      expect(recentExpenses.any((t) => t.id == 'tx-recent-exp-1'), isTrue);
      expect(recentExpenses.any((t) => t.id == 'tx-old-exp-2'), isFalse,
          reason: 'Transactions older than 30 days must be excluded');
      expect(recentExpenses.any((t) => t.id == 'tx-recent-inc-1'), isFalse,
          reason: 'Income transactions must not appear in expense query');
    });

    test('searchTransactions correctly filters by workPeriod', () async {
      final now = DateTime.now();

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-wp-oct-1',
          transactionType: 'income',
          amountOriginalSatang: 100000,
          currencyCode: 'THB',
          amountThbSatang: 100000,
          note: const Value('พตส ต.ค.'),
          transactionDate: DateTime(2026, 11, 11), // Received in Nov!
          workPeriod: const Value('2026-10'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-wp-nov-1',
          transactionType: 'income',
          amountOriginalSatang: 100000,
          currencyCode: 'THB',
          amountThbSatang: 100000,
          note: const Value('พตส พ.ย.'),
          transactionDate: DateTime(2026, 11, 26),
          workPeriod: const Value('2026-11'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      final octResults = await db.transactionsDao.searchTransactions(
        workPeriod: '2026-10',
      );

      expect(octResults.any((t) => t.id == 'tx-wp-oct-1'), isTrue);
      expect(octResults.any((t) => t.id == 'tx-wp-nov-1'), isFalse);
    });
  });
}
