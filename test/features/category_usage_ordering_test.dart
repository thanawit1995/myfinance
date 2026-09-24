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

    // Insert 3 test categories
    await db.categoriesDao.createCategory(
      CategoriesCompanion.insert(
        id: 'cat_coffee',
        nameTh: 'กาแฟ',
        nameEn: 'Coffee',
        categoryType: 'expense',
        icon: const Value('coffee'),
        color: const Value('#000000'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    await db.categoriesDao.createCategory(
      CategoriesCompanion.insert(
        id: 'cat_food',
        nameTh: 'อาหาร',
        nameEn: 'Food',
        categoryType: 'expense',
        icon: const Value('restaurant'),
        color: const Value('#000000'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    await db.categoriesDao.createCategory(
      CategoriesCompanion.insert(
        id: 'cat_transport',
        nameTh: 'เดินทาง',
        nameEn: 'Transport',
        categoryType: 'expense',
        icon: const Value('directions_car'),
        color: const Value('#000000'),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Category Usage Ordering & Tax Inference Tests', () {
    test('getActiveCategoriesOrderedByUsage returns most frequently used category first', () async {
      final now = DateTime.now();

      // Insert 3 transactions for food, 1 for coffee, 0 for transport
      for (int i = 0; i < 3; i++) {
        await db.transactionsDao.insertTransaction(
          TransactionsCompanion.insert(
            id: uuid.v4(),
            transactionType: 'expense',
            sourceAccountId: const Value('acc_main'),
            categoryId: const Value('cat_food'),
            amountOriginalSatang: 5000,
            currencyCode: 'THB',
            amountThbSatang: 5000,
            transactionDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: uuid.v4(),
          transactionType: 'expense',
          sourceAccountId: const Value('acc_main'),
          categoryId: const Value('cat_coffee'),
          amountOriginalSatang: 6000,
          currencyCode: 'THB',
          amountThbSatang: 6000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final ordered = await db.categoriesDao.getActiveCategoriesOrderedByUsage('expense');

      expect(ordered.length, greaterThanOrEqualTo(3));
      expect(ordered[0].id, 'cat_food'); // 3 usages -> 1st
      expect(ordered[1].id, 'cat_coffee'); // 1 usage -> 2nd
      final remainingIds = ordered.sublist(2).map((c) => c.id).toList();
      expect(remainingIds.contains('cat_transport'), isTrue);
    });

    test('Tax category inference correctly maps keywords to tax types', () {
      final salaryInference = CsvImportParser.classifyIncomeTax(
        name: 'เงินเดือนประจำ Salary',
        date: DateTime.now(),
        amountSatang: 5000000,
      );
      expect(salaryInference.taxCategory, '40_1');

      final shiftInference = CsvImportParser.classifyIncomeTax(
        name: 'ค่าเวรเหมา DF รพ.',
        date: DateTime.now(),
        amountSatang: 1500000,
      );
      expect(shiftInference.taxCategory, '40_2');

      final topUpInference = CsvImportParser.classifyIncomeTax(
        name: 'Top up เติมเงินพอร์ต',
        date: DateTime.now(),
        amountSatang: 1000000,
      );
      expect(topUpInference.taxCategory, 'non_taxable');
    });
  });
}
