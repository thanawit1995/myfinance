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
  });
}
