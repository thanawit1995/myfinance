import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:myfinance/core/database/daos/transactions_dao.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionsDao - Edit Transaction & Audit Log Tests', () {
    test('Updating transaction modifies fields and records Audit Log', () async {
      final now = DateTime.now();
      const txId = 'tx-edit-test-1';

      // 1. Create Initial Transaction: 500 THB expense
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'expense',
          amountOriginalSatang: 50000,
          currencyCode: 'THB',
          amountThbSatang: 50000,
          feeThbSatang: const Value(0),
          note: const Value('ค่าอาหารเที่ยง'),
          tag: const Value('อาหาร'),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      var tx = await db.transactionsDao.getTransactionById(txId);
      expect(tx, isNotNull);
      expect(tx!.amountThbSatang, equals(50000));
      expect(tx.note, equals('ค่าอาหารเที่ยง'));

      // 2. Update Transaction: change amount to 650 THB + 10 THB fee + change note
      final updated = await db.transactionsDao.updateTransaction(
        TransactionsCompanion(
          id: const Value(txId),
          amountOriginalSatang: const Value(65000),
          amountThbSatang: const Value(65000),
          feeThbSatang: const Value(1000),
          note: const Value('ค่าอาหารเที่ยง + กาแฟ'),
          tag: const Value('อาหารและเครื่องดื่ม'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      expect(updated, isTrue);

      tx = await db.transactionsDao.getTransactionById(txId);
      expect(tx!.amountThbSatang, equals(65000));
      expect(tx.feeThbSatang, equals(1000));
      expect(tx.note, equals('ค่าอาหารเที่ยง + กาแฟ'));
      expect(tx.tag, equals('อาหารและเครื่องดื่ม'));

      // 3. Verify Audit Log recorded UPDATE
      final auditLogs = await db.select(db.auditLogs).get();
      final updateLog = auditLogs.firstWhere(
        (l) => l.entityId == txId && l.action == 'UPDATE',
      );
      expect(updateLog, isNotNull);
      expect(updateLog.beforeDataJson, contains('50000'));
      expect(updateLog.afterDataJson, contains('65000'));
    });

    test('Updating accrued income workPeriod updates tag and toggling isCleared works', () async {
      final now = DateTime.now();
      const txId = 'tx-accrued-edit-1';

      // 1. Insert pending accrued income
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'income',
          amountOriginalSatang: 1000000, // 10,000 THB
          currencyCode: 'THB',
          amountThbSatang: 1000000,
          workPeriod: const Value('2026-08'),
          isCleared: const Value(false),
          note: const Value('เงินตอบแทนพิเศษ'),
          tag: const Value('รายได้ ส.ค. 2026'),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      var tx = await db.transactionsDao.getTransactionById(txId);
      expect(tx!.isCleared, isFalse);
      expect(tx.workPeriod, equals('2026-08'));

      // 2. Update to September workPeriod and mark as received (isCleared = true)
      final periodTag = TransactionsDao.formatPeriodToTag('2026-09');
      expect(periodTag, equals('รายได้ ก.ย. 2026'));

      final updated = await db.transactionsDao.updateTransaction(
        TransactionsCompanion(
          id: const Value(txId),
          workPeriod: const Value('2026-09'),
          isCleared: const Value(true),
          tag: Value(periodTag),
          updatedAt: Value(DateTime.now()),
        ),
      );

      expect(updated, isTrue);
      tx = await db.transactionsDao.getTransactionById(txId);
      expect(tx!.isCleared, isTrue);
      expect(tx.workPeriod, equals('2026-09'));
      expect(tx.tag, equals('รายได้ ก.ย. 2026'));
    });

    test('Cross-currency transfer update calculates satang, THB satang, and fxRate accurately', () async {
      final now = DateTime.now();
      const txId = 'tx-transfer-fx-1';

      // 1. Insert initial transfer THB -> USD: 3,500 THB to 100 USD (rate 35.000000)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'transfer',
          amountOriginalSatang: 10000, // 100.00 USD
          currencyCode: 'USD',
          amountThbSatang: 350000, // 3,500.00 THB
          fxRate: const Value('35.000000'),
          note: const Value('แลกเงินไป Dime! USD'),
          sourceAccountId: const Value('acc-thb-1'),
          destinationAccountId: const Value('acc-usd-1'),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      var tx = await db.transactionsDao.getTransactionById(txId);
      expect(tx!.amountOriginalSatang, equals(10000));
      expect(tx.amountThbSatang, equals(350000));
      expect(tx.fxRate, equals('35.000000'));

      // 2. User edits both source (3,400 THB) and destination (100 USD) -> new fxRate = 34.000000
      final updated = await db.transactionsDao.updateTransaction(
        TransactionsCompanion(
          id: const Value(txId),
          amountOriginalSatang: const Value(10000), // 100.00 USD
          amountThbSatang: const Value(340000), // 3,400.00 THB
          fxRate: const Value('34.000000'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      expect(updated, isTrue);
      tx = await db.transactionsDao.getTransactionById(txId);
      expect(tx!.amountThbSatang, equals(340000));
      expect(tx.fxRate, equals('34.000000'));
    });
  });
}
