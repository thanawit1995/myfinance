import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/daos/accounts_dao.dart';
import 'package:myfinance/core/database/daos/categories_dao.dart';
import 'package:myfinance/core/database/daos/import_batches_dao.dart';
import 'package:myfinance/core/database/daos/transactions_dao.dart';
import 'package:myfinance/core/database/daos/recurring_transactions_dao.dart';
import 'package:myfinance/features/import/domain/csv_import_parser.dart';
import 'package:myfinance/features/import/domain/import_executor.dart';

void main() {
  group('Notion Bill Import & Tagging Test', () {
    test('detectMapping recognizes Notion Bill CSV headers', () {
      final headers = [
        'Date',
        'Bill',
        'Category',
        'Amount',
        'Property',
        'Detail',
        'Monthly Overview',
        'Proportion',
        'Related to Proportion (1) (💳 Bill tracker)',
      ];

      final mapping = CsvImportParser.detectMapping(headers, template: 'notion_bills');
      expect(mapping, isNotNull);
      expect(mapping!.dateCol, 0);
      expect(mapping.nameCol, 1);
      expect(mapping.categoryCol, 2);
      expect(mapping.amountCol, 3);
      expect(mapping.propertyCol, 4);
      expect(mapping.noteCol, 5);
      expect(mapping.periodCol, 6);
    });

    test('parseRows auto-categorizes bills and tags GPF & Insurance for tax deduction', () {
      const csvContent = '''Date,Bill,Category,Amount,Property,Detail,Monthly Overview,Proportion,Related to Proportion (1) (💳 Bill tracker)
"October 1, 2023",Netflix,Monthly,THB 105.00,Yes,โอนให้ใช้,October 23 (https://notion.so/oct23),,
"October 30, 2023",Water bill,Monthly,THB 235.00,Yes,Finn condo 4,October 23 (https://notion.so/oct23),,
"May 23, 2024",Rental condo,Monthly,"THB 9,000.00",Yes,จ่ายให้คุณตั้ม,May 24 (https://notion.so/may24),,
"January 26, 2024",ส่ง กบข.,Monthly,"THB 3,424.50",Yes,,January 24 (https://notion.so/jan24),,
"December 1, 2023",ประกันออมทรัพย์,Yearly,"THB 45,000.00",Yes,จ่ายถึงปี 77,December 23 (https://notion.so/dec23),Insurance (https://notion.so/ins),
"March 4, 2024",Electronic bill,Monthly,THB 601.36,Yes,Finn condo 4,February 24 (https://notion.so/feb24),,
"February 17, 2024",TAX 2566,Yearly,"THB 7,820.70",Yes,,February 24 (https://notion.so/feb24),,
''';

      final rawRows = CsvImportParser.parseRawCsv(csvContent);
      final headers = rawRows.first.map((e) => e.toString()).toList();
      final mapping = CsvImportParser.detectMapping(headers, template: 'notion_bills')!;

      final parsed = CsvImportParser.parseRows(
        rawRows: rawRows,
        mapping: mapping,
        templateType: 'notion_bills',
      );

      expect(parsed.length, 7);

      // 1. Netflix -> Entertainment
      expect(parsed[0].name, 'Netflix');
      expect(parsed[0].categoryName, 'Entertainment');
      expect(parsed[0].amountSatang, 10500);
      expect(parsed[0].transactionType, 'expense');
      expect(parsed[0].tag, isNull);

      // 2. Water bill -> Utilities
      expect(parsed[1].name, 'Water bill');
      expect(parsed[1].categoryName, 'Utilities');
      expect(parsed[1].amountSatang, 23500);
      expect(parsed[1].transactionType, 'expense');

      // 3. Rental condo -> Housing
      expect(parsed[2].name, 'Rental condo');
      expect(parsed[2].categoryName, 'Housing');
      expect(parsed[2].amountSatang, 900000);
      expect(parsed[2].transactionType, 'expense');

      // 4. ส่ง กบข. -> เงินสะสม กบข. with tag 'deduction:gpf'
      expect(parsed[3].name, 'ส่ง กบข.');
      expect(parsed[3].categoryName, 'เงินสะสม กบข.');
      expect(parsed[3].amountSatang, 342450);
      expect(parsed[3].transactionType, 'expense');
      expect(parsed[3].tag, 'deduction:gpf');

      // 5. ประกันออมทรัพย์ -> Healthcare with tag 'deduction:life_insurance'
      expect(parsed[4].name, 'ประกันออมทรัพย์');
      expect(parsed[4].categoryName, 'Healthcare');
      expect(parsed[4].amountSatang, 4500000);
      expect(parsed[4].transactionType, 'expense');
      expect(parsed[4].tag, 'deduction:life_insurance');

      // 6. Electronic bill -> Utilities
      expect(parsed[5].name, 'Electronic bill');
      expect(parsed[5].categoryName, 'Utilities');
      expect(parsed[5].amountSatang, 60136);

      // 7. TAX 2566 -> Financial Fees
      expect(parsed[6].name, 'TAX 2566');
      expect(parsed[6].categoryName, 'Financial Fees');
      expect(parsed[6].amountSatang, 782070);
    });

    test('executeImport saves Notion bills into expense transactions and creates 0 recurring rules', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final transactionsDao = TransactionsDao(db);
      final accountsDao = AccountsDao(db);
      final categoriesDao = CategoriesDao(db);
      final importBatchesDao = ImportBatchesDao(db);
      final recurringDao = RecurringTransactionsDao(db);

      final executor = ImportExecutor(
        db: db,
        transactionsDao: transactionsDao,
        accountsDao: accountsDao,
        categoriesDao: categoriesDao,
        importBatchesDao: importBatchesDao,
      );

      // Create default account
      final now = DateTime.now();
      await accountsDao.createAccount(
        AccountsCompanion.insert(
          id: 'acc-test-1',
          name: 'Main Cash',
          accountType: 'cash',
          currencyCode: 'THB',
          isDomestic: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      const csvContent = '''Date,Bill,Category,Amount,Property,Detail,Monthly Overview,Proportion,Related to Proportion (1) (💳 Bill tracker)
"January 26, 2024",ส่ง กบข.,Monthly,"THB 3,424.50",Yes,,January 24 (https://notion.so/jan24),,
"December 1, 2024",ประกันออมทรัพย์,Yearly,"THB 45,000.00",Yes,จ่ายถึงปี 77,December 24 (https://notion.so/dec24),Insurance (https://notion.so/ins),
"March 4, 2024",Electronic bill,Monthly,THB 601.36,Yes,Finn condo 4,February 24 (https://notion.so/feb24),,
''';

      final rawRows = CsvImportParser.parseRawCsv(csvContent);
      final headers = rawRows.first.map((e) => e.toString()).toList();
      final mapping = CsvImportParser.detectMapping(headers, template: 'notion_bills')!;
      final parsed = CsvImportParser.parseRows(
        rawRows: rawRows,
        mapping: mapping,
        templateType: 'notion_bills',
      );

      final result = await executor.executeImport(
        fileName: 'bills_test.csv',
        templateType: 'notion_bills',
        rows: parsed,
        defaultAccountId: 'acc-test-1',
      );

      expect(result.importedCount, 3);

      // Verify transactions inserted
      final allTx = await transactionsDao.getAllTransactions();
      expect(allTx.length, 3);

      // Verify all are expense transactions
      for (final tx in allTx) {
        expect(tx.transactionType, 'expense');
      }

      // Verify GPF tag and category
      final gpfTx = allTx.firstWhere((tx) => tx.note?.contains('ส่ง กบข.') == true);
      expect(gpfTx.tag, 'deduction:gpf');
      expect(gpfTx.amountThbSatang, 342450);

      // Verify Life Insurance tag
      final insTx = allTx.firstWhere((tx) => tx.note?.contains('ประกันออมทรัพย์') == true);
      expect(insTx.tag, 'deduction:life_insurance');
      expect(insTx.amountThbSatang, 4500000);

      // Crucial: Verify 0 recurring rules created!
      final recurringRules = await recurringDao.getAllRules();
      expect(recurringRules.isEmpty, isTrue);

      await db.close();
    });
  });
}
