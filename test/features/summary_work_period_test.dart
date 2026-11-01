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
  });
}
