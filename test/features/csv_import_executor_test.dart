import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:myfinance/features/import/domain/csv_import_models.dart';
import 'package:myfinance/features/import/domain/import_executor.dart';

void main() {
  late AppDatabase db;
  late ImportExecutor executor;

  setUp(() {
    db = AppDatabase.forTesting(inMemoryConnection());
    executor = ImportExecutor(
      db: db,
      transactionsDao: db.transactionsDao,
      accountsDao: db.accountsDao,
      categoriesDao: db.categoriesDao,
      importBatchesDao: db.importBatchesDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('ImportExecutor & Batch Rollback Integration Tests', () {
    test('Import batch creates missing categories & accounts and inserts transactions with batch ID', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final defaultAcc = accounts.first;

      final rows = [
        ParsedCsvRow(
          rowIndex: 1,
          date: DateTime(2026, 9, 10),
          rawDateString: '10-Sep-26',
          name: 'ก๋วยเตี๋ยวเรือ',
          categoryName: 'มื้อพิเศษชาบู', // Brand new category
          accountName: 'TrueMoney Wallet', // Brand new account
          amountSatang: 12000,
          transactionType: 'expense',
          rawRow: ['10-Sep-26', 'ก๋วยเตี๋ยวเรือ', 'มื้อพิเศษชาบู', 'TrueMoney Wallet', '120.00'],
        ),
        ParsedCsvRow(
          rowIndex: 2,
          date: DateTime(2026, 9, 11),
          rawDateString: '11-Sep-26',
          name: 'P4P ประจำเดือน',
          categoryName: 'P4P',
          accountName: null,
          amountSatang: 2000000,
          transactionType: 'income',
          taxCategory: '40_1',
          withholdingTaxSatang: 100000,
          rawRow: ['11-Sep-26', 'P4P ประจำเดือน', 'P4P', '', '20,000.00'],
        ),
      ];

      // Execute import
      final result = await executor.executeImport(
        fileName: 'notion_september.csv',
        templateType: 'notion_expense',
        rows: rows,
        defaultAccountId: defaultAcc.id,
      );

      expect(result.importedCount, 2);
      expect(result.createdCategories, contains('มื้อพิเศษชาบู'));
      expect(result.createdAccounts, contains('TrueMoney Wallet'));

      // Check transactions in database
      final allTx = await db.transactionsDao.getAllTransactions();
      final importedTxs = allTx.where((t) => t.importBatchId == result.batchId).toList();
      expect(importedTxs.length, 2);

      // Verify category was auto-created in database
      final cats = await db.categoriesDao.getActiveCategories();
      expect(cats.any((c) => c.nameTh == 'มื้อพิเศษชาบู'), isTrue);

      // Verify account was auto-created in database
      final accs = await db.accountsDao.getActiveAccounts();
      expect(accs.any((a) => a.name == 'TrueMoney Wallet'), isTrue);

      // Verify P4P income withholding tax was saved
      final p4pTx = importedTxs.firstWhere((t) => t.transactionType == 'income');
      expect(p4pTx.withholdingTaxSatang, 100000);
      expect(p4pTx.taxCategory, '40_1');
    });

    test('1-Click Rollback removes all transactions of the batch and marks batch rolled back', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final defaultAcc = accounts.first;

      // 1. Manually insert an unrelated existing transaction
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'manual-existing-tx',
          transactionType: 'expense',
          sourceAccountId: Value(defaultAcc.id),
          amountOriginalSatang: 50000,
          currencyCode: 'THB',
          amountThbSatang: 50000,
          transactionDate: DateTime(2026, 9, 1),
          createdAt: DateTime(2026, 9, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
      );

      // 2. Import a batch with 2 transactions
      final rows = [
        ParsedCsvRow(
          rowIndex: 1,
          date: DateTime(2026, 9, 5),
          rawDateString: '05-Sep-26',
          name: 'กาแฟสด',
          categoryName: 'อาหารและเครื่องดื่ม',
          amountSatang: 6500,
          transactionType: 'expense',
          rawRow: ['05-Sep-26', 'กาแฟสด', 'อาหารและเครื่องดื่ม', '', '65.00'],
        ),
        ParsedCsvRow(
          rowIndex: 2,
          date: DateTime(2026, 9, 6),
          rawDateString: '06-Sep-26',
          name: 'หนังสือการเงิน',
          categoryName: 'การศึกษา',
          amountSatang: 35000,
          transactionType: 'expense',
          rawRow: ['06-Sep-26', 'หนังสือการเงิน', 'การศึกษา', '', '350.00'],
        ),
      ];

      final importRes = await executor.executeImport(
        fileName: 'batch_test.csv',
        templateType: 'custom',
        rows: rows,
        defaultAccountId: defaultAcc.id,
      );

      var txs = await db.transactionsDao.getAllTransactions();
      expect(txs.length, 3); // 1 manual + 2 imported

      // 3. Rollback the batch!
      final deletedCount = await db.importBatchesDao.rollbackBatch(importRes.batchId);
      expect(deletedCount, 2);

      // 4. Check that imported transactions are gone, but manual tx remains intact
      txs = await db.transactionsDao.getAllTransactions();
      expect(txs.length, 1);
      expect(txs.first.id, 'manual-existing-tx');

      // Check batch record
      final batch = await db.importBatchesDao.getBatchById(importRes.batchId);
      expect(batch, isNotNull);
      expect(batch!.isRolledBack, isTrue);
      expect(batch.rolledBackAt, isNotNull);
    });

    test('Duplicate checking flags transactions with identical date, amount, and name', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final defaultAcc = accounts.first;

      // Insert pre-existing transaction
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'dup-seed-tx',
          transactionType: 'expense',
          sourceAccountId: Value(defaultAcc.id),
          amountOriginalSatang: 9900,
          currencyCode: 'THB',
          amountThbSatang: 9900,
          note: const Value('อาหารกลางวัน ข้าวผัดปู'),
          transactionDate: DateTime(2026, 9, 15),
          createdAt: DateTime(2026, 9, 15),
          updatedAt: DateTime(2026, 9, 15),
        ),
      );

      final incomingRows = [
        ParsedCsvRow(
          rowIndex: 1,
          date: DateTime(2026, 9, 15),
          rawDateString: '15-Sep-26',
          name: 'ข้าวผัดปู', // Matches date, amount, and name substring in note
          categoryName: 'อาหาร',
          amountSatang: 9900,
          transactionType: 'expense',
          rawRow: [],
        ),
        ParsedCsvRow(
          rowIndex: 2,
          date: DateTime(2026, 9, 15),
          rawDateString: '15-Sep-26',
          name: 'ชานมไข่มุก', // Different amount
          categoryName: 'อาหาร',
          amountSatang: 5000,
          transactionType: 'expense',
          rawRow: [],
        ),
      ];

      final checked = await executor.checkDuplicates(incomingRows);
      expect(checked[0].isDuplicate, isTrue);
      expect(checked[1].isDuplicate, isFalse);
    });
  });
}
