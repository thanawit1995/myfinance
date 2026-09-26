import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/features/import/domain/csv_import_models.dart';
import 'package:myfinance/features/import/domain/csv_import_parser.dart';
import 'package:myfinance/features/import/domain/import_executor.dart';

void main() {
  group('Notion Income Parser & Medical Income Logic', () {
    test('parseNotionWorkPeriod accurately extracts YYYY-MM from diverse formats', () {
      expect(CsvImportParser.parseNotionWorkPeriod('December 25'), '2025-12');
      expect(CsvImportParser.parseNotionWorkPeriod('December 25 (https://www.notion.so/...)'), '2025-12');
      expect(CsvImportParser.parseNotionWorkPeriod('July 26'), '2026-07');
      expect(CsvImportParser.parseNotionWorkPeriod('Jan 24'), '2024-01');
      expect(CsvImportParser.parseNotionWorkPeriod('August 2025'), '2025-08');
      expect(CsvImportParser.parseNotionWorkPeriod('2025-12'), '2025-12');
      expect(CsvImportParser.parseNotionWorkPeriod(null), isNull);
      expect(CsvImportParser.parseNotionWorkPeriod(''), isNull);
    });

    test('Thai medical income tax categories classify correctly', () {
      final date = DateTime(2026, 1, 1);
      // 40_1: เงินเดือน, พตส., ประจำตำแหน่ง, เวรเหมา, รายชั่วโมง, DF, ไม่ทำเวชฯ
      expect(CsvImportParser.classifyIncomeTax(name: 'เงินเดือน สสจ.', date: date, amountSatang: 5000000).taxCategory, '40_1');
      expect(CsvImportParser.classifyIncomeTax(name: 'เงิน พตส.', date: date, amountSatang: 1000000).taxCategory, '40_1');
      expect(CsvImportParser.classifyIncomeTax(name: 'เงินประจำตำแหน่ง', date: date, amountSatang: 1000000).taxCategory, '40_1');
      expect(CsvImportParser.classifyIncomeTax(name: 'เวรเหมา 1หมื่น', date: date, amountSatang: 1000000).taxCategory, '40_1');
      expect(CsvImportParser.classifyIncomeTax(name: 'เงินหมื่น ไม่ทำเวชฯ', date: date, amountSatang: 1000000).taxCategory, '40_1');
      expect(CsvImportParser.classifyIncomeTax(name: 'เงินรายชั่วโมง', date: date, amountSatang: 1000000).taxCategory, '40_1');
      expect(CsvImportParser.classifyIncomeTax(name: 'DF cost', date: date, amountSatang: 1000000).taxCategory, '40_1');
    });

    test('Notion Income CSV rows parse budget, amount, property, and isCleared correctly', () {
      const csvContent = '''Date,Income,Category,Budget,Amount,Property,Monthly Overview,Type
"December 29, 2025",เวรเหมา 1หมื่น,On duty,THB 10000.00,,No,December 25 (https://notion.so/dec25),👝เงินเวรเหมา_DEC25
"January 5, 2026",เงินหมื่น ไม่ทำเวชฯ,Extra,THB 10000.00,THB 10000.00,Yes,December 25 (https://notion.so/dec25),💼เงินหมื่น_DEC25
''';

      final rawRows = CsvImportParser.parseRawCsv(csvContent);
      final headers = rawRows.first.map((e) => e.toString()).toList();
      final mapping = CsvImportParser.detectMapping(headers);

      expect(mapping, isNotNull);
      expect(mapping!.budgetCol, 3);
      expect(mapping.amountCol, 4);
      expect(mapping.propertyCol, 5);
      expect(mapping.periodCol, 6);

      final parsed = CsvImportParser.parseRows(
        rawRows: rawRows,
        mapping: mapping,
        templateType: 'notion_income',
      );

      expect(parsed.length, 2);

      // Row 1: Property: No -> Uncleared/Accrued
      final row1 = parsed[0];
      expect(row1.name, 'เวรเหมา 1หมื่น');
      expect(row1.isCleared, isFalse);
      expect(row1.workPeriod, '2025-12');
      expect(row1.expectedAmountSatang, 1000000); // 10,000 THB = 1,000,000 satang
      expect(row1.amountSatang, 1000000);
      expect(row1.taxCategory, '40_1');
      expect(row1.isValid, isTrue);

      // Row 2: Property: Yes -> Cleared/Received
      final row2 = parsed[1];
      expect(row2.name, 'เงินหมื่น ไม่ทำเวชฯ');
      expect(row2.isCleared, isTrue);
      expect(row2.workPeriod, '2025-12');
      expect(row2.expectedAmountSatang, 1000000);
      expect(row2.amountSatang, 1000000);
      expect(row2.taxCategory, '40_1');
      expect(row2.isValid, isTrue);
      // Aligned from Jan 5, 2026 to Dec 5, 2025 because Monthly Overview is December 25
      expect(row2.date!.year, 2025);
      expect(row2.date!.month, 12);
      expect(row2.date!.day, 5);
      expect(row2.note, contains('รับเงินจริง: 05/01/2026'));
    });

    test('P4P received in September with August Monthly Overview aligns date to August and notes pay date', () {
      const csvContent = '''Date,Income,Category,Budget,Amount,Property,Monthly Overview,Type
"September 25, 2026",P4P,Salary,"THB9,840.93","THB9,348.88",Yes,August 26 (https://notion.so/aug26),Salary_AUG26
"September 25, 2026",เงินเดือน,Salary,"THB24,220.00","THB24,220.00",Yes,September 26 (https://notion.so/sep26),Salary_SEP26
''';

      final rawRows = CsvImportParser.parseRawCsv(csvContent);
      final headers = rawRows.first.map((e) => e.toString()).toList();
      final mapping = CsvImportParser.detectMapping(headers);

      final parsed = CsvImportParser.parseRows(
        rawRows: rawRows,
        mapping: mapping!,
        templateType: 'notion_income',
      );

      expect(parsed.length, 2);

      // P4P: date aligns to August 2026!
      final p4pRow = parsed[0];
      expect(p4pRow.name, 'P4P');
      expect(p4pRow.workPeriod, '2026-08');
      expect(p4pRow.date!.year, 2026);
      expect(p4pRow.date!.month, 8);
      expect(p4pRow.date!.day, 25);
      expect(p4pRow.note, contains('รับเงินจริง: 25/09/2026'));

      // Salary: date stays September 2026
      final salaryRow = parsed[1];
      expect(salaryRow.name, 'เงินเดือน');
      expect(salaryRow.workPeriod, '2026-09');
      expect(salaryRow.date!.year, 2026);
      expect(salaryRow.date!.month, 9);
      expect(salaryRow.date!.day, 25);
    });

    test('Real Notion Income CSV file parses successfully if present', () async {
      var file = File('Notion data/Notion_income/Income logs 4284ecd2c833405cbace2fd2764bf989.csv');
      if (!await file.exists()) {
        file = File('Notion_income/Income logs 4284ecd2c833405cbace2fd2764bf989.csv');
      }
      if (!await file.exists()) return;

      final content = await file.readAsString();
      final rawRows = CsvImportParser.parseRawCsv(content);
      final headers = rawRows.first.map((e) => e.toString()).toList();
      final mapping = CsvImportParser.detectMapping(headers);

      expect(mapping, isNotNull);

      final parsed = CsvImportParser.parseRows(
        rawRows: rawRows,
        mapping: mapping!,
        templateType: 'notion_income',
      );

      expect(parsed.isNotEmpty, isTrue);

      final unclearedRows = parsed.where((r) => !r.isCleared).toList();
      expect(unclearedRows.isNotEmpty, isTrue);
      for (final r in unclearedRows) {
        expect(r.expectedAmountSatang, greaterThan(0));
        expect(r.workPeriod, isNotNull);
      }
    });
  });

  group('Accrued Income & Ledger Invariant Integration Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Uncleared income is NOT added to account balance until markIncomeAsReceived', () async {
      final now = DateTime.now();

      // 1. Create a bank account
      const accountId = 'acc-ktb-1';
      await db.accountsDao.createAccount(
        AccountsCompanion.insert(
          id: accountId,
          name: 'KTB Payroll',
          accountType: 'cash',
          currencyCode: 'THB',
          isDomestic: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Add cleared income 5,000 THB (500,000 satang)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-initial',
          transactionType: 'income',
          sourceAccountId: const Value(accountId),
          amountOriginalSatang: 500000,
          currencyCode: 'THB',
          amountThbSatang: 500000,
          isCleared: const Value(true),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Verify balance
      final initialBalance = await db.accountsDao.getAccountBalanceSatang(accountId);
      expect(initialBalance, 500000);

      // 2. Insert an Accrued Income (เวรเหมา 10,000 THB, isCleared: false)
      const txId = 'tx-duty-1';
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'income',
          sourceAccountId: const Value(accountId),
          amountOriginalSatang: 1000000,
          currencyCode: 'THB',
          fxRate: const Value('1.0'),
          amountThbSatang: 1000000,
          feeThbSatang: const Value(0),
          taxCategory: const Value('40(2)'),
          workPeriod: const Value('2025-12'),
          expectedAmountSatang: const Value(1000000),
          isCleared: const Value(false), // UNCLEARED
          transactionDate: now,
          note: const Value('เวรเหมา ธ.ค.'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // INVARIANT CHECK: Bank account balance must STILL be 5,000 THB (uncleared income must NOT enter cash balance!)
      final balanceAfterAccrued = await db.accountsDao.getAccountBalanceSatang(accountId);
      expect(balanceAfterAccrued, 500000);

      // Verify watchAccruedIncomes / getAccruedIncomes returns this transaction
      final accruedList = await db.transactionsDao.getAccruedIncomes();
      expect(accruedList.length, 1);
      expect(accruedList.first.id, txId);
      expect(accruedList.first.workPeriod, '2025-12');
      expect(accruedList.first.isCleared, isFalse);

      // 3. Doctor marks income as received (Mark as Received)
      final depositDate = DateTime(2026, 1, 15);
      final markSuccess = await db.transactionsDao.markIncomeAsReceived(
        txId,
        accountId: accountId,
        receivedDate: depositDate,
        actualAmountSatang: 1000000,
      );
      expect(markSuccess, isTrue);

      // 4. Verify ledger state after marking received:
      // A. Bank account balance must now include the 10,000 THB -> 5,000 + 10,000 = 15,000 THB (1,500,000 satang)
      final balanceAfterCleared = await db.accountsDao.getAccountBalanceSatang(accountId);
      expect(balanceAfterCleared, 1500000);

      // B. Accrued list must now be empty!
      final accruedAfter = await db.transactionsDao.getAccruedIncomes();
      expect(accruedAfter.isEmpty, isTrue);

      // C. Transaction is now cleared with updated transactionDate
      final updatedTx = await db.transactionsDao.getTransactionById(txId);
      expect(updatedTx, isNotNull);
      expect(updatedTx!.isCleared, isTrue);
      expect(updatedTx.transactionDate, depositDate);

      // D. Audit log must record the action
      final auditLogs = await db.select(db.auditLogs).get();
      expect(auditLogs.any((a) => a.entityId == txId && a.action == 'UPDATE'), isTrue);
    });

    test('ImportExecutor end-to-end creates accrued income records with workPeriod', () async {
      final now = DateTime.now();
      const fallbackAccId = 'acc-default';
      await db.accountsDao.createAccount(
        AccountsCompanion.insert(
          id: fallbackAccId,
          name: 'Main Cash',
          accountType: 'cash',
          currencyCode: 'THB',
          isDomestic: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final executor = ImportExecutor(
        db: db,
        accountsDao: db.accountsDao,
        categoriesDao: db.categoriesDao,
        transactionsDao: db.transactionsDao,
        importBatchesDao: db.importBatchesDao,
      );
      final rows = [
        ParsedCsvRow(
          rowIndex: 1,
          date: DateTime(2025, 12, 29),
          rawDateString: 'December 29, 2025',
          name: 'เวรเหมา 1หมื่น',
          categoryName: 'On duty',
          accountName: 'Main Cash',
          amountSatang: 1000000,
          transactionType: 'income',
          taxCategory: '40(2)',
          workPeriod: '2025-12',
          expectedAmountSatang: 1000000,
          isCleared: false,
          rawRow: ['December 29, 2025', 'เวรเหมา 1หมื่น', 'On duty', '10000.00'],
        ),
      ];

      final result = await executor.executeImport(
        rows: rows,
        templateType: 'notion_income',
        fileName: 'Income_logs_test.csv',
        defaultAccountId: fallbackAccId,
      );

      expect(result.importedCount, 1);

      final accrued = await db.transactionsDao.getAccruedIncomes();
      expect(accrued.length, 1);
      expect(accrued.first.note, 'เวรเหมา 1หมื่น');
      expect(accrued.first.workPeriod, '2025-12');
      expect(accrued.first.isCleared, isFalse);

      // Account balance must remain 0
      final bal = await db.accountsDao.getAccountBalanceSatang(fallbackAccId);
      expect(bal, 0);
    });

    test('cleanDistortedNotionNotes cleans up legacy transactions with Notion URLs', () async {
      final now = DateTime.now();
      final legacyId = 'legacy-tx-1';
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: legacyId,
          transactionType: 'income',
          sourceAccountId: const Value('acc-ktb-1'),
          amountOriginalSatang: 5000000,
          currencyCode: 'THB',
          amountThbSatang: 5000000,
          note: const Value('เงินเดือน (🏧เงินเดือนจาก สสจ._SEP26 (https://app.notion.com/p/12345))'),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final cleanedCount = await db.transactionsDao.cleanDistortedNotionNotes();
      expect(cleanedCount, 1);

      final tx = await db.transactionsDao.getTransactionById(legacyId);
      expect(tx, isNotNull);
      expect(tx!.note, 'เงินเดือน');
    });

    test('alignIncomeDatesWithWorkPeriod updates legacy transactions to match workPeriod', () async {
      final txId = 'test_p4p_legacy';
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'income',
          sourceAccountId: const Value('acc-ktb-1'),
          amountOriginalSatang: 934888,
          currencyCode: 'THB',
          amountThbSatang: 934888,
          transactionDate: DateTime(2026, 9, 25),
          workPeriod: const Value('2026-08'),
          isCleared: const Value(true),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final updated = await db.transactionsDao.alignIncomeDatesWithWorkPeriod();
      expect(updated, greaterThanOrEqualTo(1));

      final updatedTx = await (db.select(db.transactions)..where((t) => t.id.equals(txId))).getSingle();
      expect(updatedTx.transactionDate.year, 2026);
      expect(updatedTx.transactionDate.month, 8);
      expect(updatedTx.transactionDate.day, 25);
      expect(updatedTx.note, contains('รับเงินจริง: 25/09/2026'));
    });
  });
}
