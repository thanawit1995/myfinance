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

  group('TransactionsDao - Quick Entry & Audit Log Tests', () {
    test('Can retrieve last transaction for Duplicate Last button', () async {
      final scb = (await db.accountsDao.getActiveAccounts()).firstWhere((a) => a.name == 'SCB');
      final foodCat = (await db.categoriesDao.getActiveCategories()).firstWhere((c) => c.nameTh == 'อาหารและเครื่องดื่ม');

      // Insert transaction 1
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-1',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          categoryId: Value(foodCat.id),
          amountOriginalSatang: 6500, // 65.00 THB
          currencyCode: 'THB',
          amountThbSatang: 6500,
          note: const Value('ข้าวกะเพราไข่ดาว'),
          transactionDate: DateTime(2026, 9, 15, 12, 30),
          createdAt: DateTime(2026, 9, 15, 12, 30),
          updatedAt: DateTime(2026, 9, 15, 12, 30),
        ),
      );

      // Verify getLastTransaction
      final last = await db.transactionsDao.getLastTransaction();
      expect(last, isNotNull);
      expect(last!.id, equals('tx-1'));
      expect(last.amountThbSatang, equals(6500));
      expect(last.note, equals('ข้าวกะเพราไข่ดาว'));
    });

    test('Cross-currency transfer automatically records FX rate in fx_rates table', () async {
      final dimeSave = (await db.accountsDao.getActiveAccounts()).firstWhere((a) => a.name == 'Dime! Save');
      final dimeFcd = (await db.accountsDao.getActiveAccounts()).firstWhere((a) => a.name == 'Dime! FCD');

      // Transfer 35,500.00 THB to buy $1,000.00 USD (rate = 35.500000)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-fx-1',
          transactionType: 'transfer',
          sourceAccountId: Value(dimeSave.id),
          destinationAccountId: Value(dimeFcd.id),
          amountOriginalSatang: 100000, // $1,000.00 (100,000 cents)
          currencyCode: 'USD',
          fxRate: const Value('35.500000'),
          amountThbSatang: 3550000, // 35,500.00 THB (3,550,000 satang)
          transactionDate: DateTime(2026, 9, 15),
          createdAt: DateTime(2026, 9, 15),
          updatedAt: DateTime(2026, 9, 15),
        ),
      );

      // Check that fx_rates table has this record
      final rates = await db.select(db.fxRates).get();
      expect(rates.any((r) => r.baseCurrency == 'USD' && r.rate == '35.500000'), isTrue);
    });

    test('Updating or deleting a transaction generates an append-only Audit Log', () async {
      final scb = (await db.accountsDao.getActiveAccounts()).firstWhere((a) => a.name == 'SCB');

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-audit-test',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          amountOriginalSatang: 10000, // 100.00 THB
          currencyCode: 'THB',
          amountThbSatang: 10000,
          transactionDate: DateTime(2026, 9, 15),
          createdAt: DateTime(2026, 9, 15),
          updatedAt: DateTime(2026, 9, 15),
        ),
      );

      // Check CREATE audit log
      var logs = await db.select(db.auditLogs).get();
      expect(logs.any((l) => l.entityId == 'tx-audit-test' && l.action == 'CREATE'), isTrue);

      // Update transaction amount to 150.00 THB
      await db.transactionsDao.updateTransaction(
        TransactionsCompanion(
          id: const Value('tx-audit-test'),
          transactionType: const Value('expense'),
          sourceAccountId: Value(scb.id),
          amountOriginalSatang: const Value(15000),
          currencyCode: const Value('THB'),
          amountThbSatang: const Value(15000),
          transactionDate: Value(DateTime(2026, 9, 15)),
          updatedAt: Value(DateTime.now()),
        ),
      );

      logs = await db.select(db.auditLogs).get();
      expect(logs.any((l) => l.entityId == 'tx-audit-test' && l.action == 'UPDATE'), isTrue);

      // Soft delete transaction
      await db.transactionsDao.softDeleteTransaction('tx-audit-test');
      logs = await db.select(db.auditLogs).get();
      expect(logs.any((l) => l.entityId == 'tx-audit-test' && l.action == 'DELETE'), isTrue);
    });
  });
}
