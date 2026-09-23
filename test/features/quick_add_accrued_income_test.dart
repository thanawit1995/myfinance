import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/features/import/domain/csv_import_parser.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  const uuid = Uuid();

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());

    // Insert test account
    await db.accountsDao.createAccount(
      AccountsCompanion.insert(
        id: 'acc_main',
        name: 'Main Bank Account',
        accountType: 'cash',
        currencyCode: 'THB',
        isDomestic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Quick Add & Accrued Income Integration Tests', () {
    test('Quick Add can create an Accrued Income transaction with work period', () async {
      final now = DateTime.now();
      final txId = uuid.v4();

      final newTx = TransactionsCompanion.insert(
        id: txId,
        transactionType: 'income',
        sourceAccountId: const Value('acc_main'),
        amountOriginalSatang: 1000000, // 10,000 THB
        currencyCode: 'THB',
        amountThbSatang: 1000000,
        taxCategory: const Value('40_2'),
        workPeriod: const Value('2026-08'),
        expectedAmountSatang: const Value(1000000),
        isCleared: const Value(false),
        note: const Value('ค่าเวรเหมา รพ.'),
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await db.transactionsDao.insertTransaction(newTx);

      final retrieved = await db.transactionsDao.getTransactionById(txId);
      expect(retrieved, isNotNull);
      expect(retrieved!.isCleared, isFalse);
      expect(retrieved.workPeriod, '2026-08');
      expect(retrieved.expectedAmountSatang, 1000000);
      expect(retrieved.taxCategory, '40_2');
      expect(retrieved.note, 'ค่าเวรเหมา รพ.');
    });

    test('Tax category auto-inference works accurately for medical items', () {
      final now = DateTime(2026, 8, 15);
      // Top up -> non_taxable
      expect(
        CsvImportParser.classifyIncomeTax(name: 'เงิน Top up เพิ่มเติม', date: now, amountSatang: 50000).taxCategory,
        'non_taxable',
      );
      // P4P after July 2026 -> 40_1 with 5% WHT
      final p4p = CsvImportParser.classifyIncomeTax(name: 'P4P ประจำงวด', date: now, amountSatang: 100000);
      expect(p4p.taxCategory, '40_1');
      expect(p4p.withholdingTaxSatang, 5000);

      // เวรเหมา -> 40_2 with 0 WHT
      final duty = CsvImportParser.classifyIncomeTax(name: 'เวรเหมาพิเศษ', date: now, amountSatang: 100000);
      expect(duty.taxCategory, '40_2');
      expect(duty.withholdingTaxSatang, 0);
    });

    test('Soft delete records transaction to audit log and excludes from search', () async {
      final now = DateTime.now();
      final txId = uuid.v4();

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'expense',
          sourceAccountId: const Value('acc_main'),
          amountOriginalSatang: 35000,
          currencyCode: 'THB',
          amountThbSatang: 35000,
          note: const Value('ค่ากาแฟ'),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Verify it exists in search
      var searchList = await db.transactionsDao.searchTransactions(query: 'ค่ากาแฟ');
      expect(searchList.length, 1);

      // Soft delete
      final success = await db.transactionsDao.softDeleteTransaction(txId);
      expect(success, isTrue);

      // Verify it is excluded from normal search
      searchList = await db.transactionsDao.searchTransactions(query: 'ค่ากาแฟ');
      expect(searchList.isEmpty, isTrue);

      // Verify audit log has both CREATE and DELETE entries
      final logs = await (db.select(db.auditLogs)..where((l) => l.entityId.equals(txId))).get();
      expect(logs.length, 2);
      expect(logs.any((l) => l.action == 'CREATE'), isTrue);
      expect(logs.any((l) => l.action == 'DELETE'), isTrue);
    });
  });
}
