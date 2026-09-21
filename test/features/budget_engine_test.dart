import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
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

  group('BudgetsDao - Non-rollover & Threshold Alert Tests', () {
    test('Budgets calculate spending accurately and do NOT rollover to next month', () async {
      final foodCat = (await db.categoriesDao.getActiveCategories())
          .firstWhere((c) => c.nameTh == 'อาหารและเครื่องดื่ม');
      final scb = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');

      // 1. Set Food Budget: 10,000 THB / month (1,000,000 satang)
      await db.budgetsDao.setBudget(categoryId: foodCat.id, limitSatang: 1000000);

      // 2. Spend 8,500 THB in September 2026 (85% -> Warning trigger!)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-food-sep',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          categoryId: Value(foodCat.id),
          amountOriginalSatang: 850000,
          currencyCode: 'THB',
          amountThbSatang: 850000,
          transactionDate: DateTime(2026, 9, 10),
          createdAt: DateTime(2026, 9, 10),
          updatedAt: DateTime(2026, 9, 10),
        ),
      );

      // Check September status:
      var statusSep = await db.budgetsDao.getBudgetStatusForMonth(2026, 9);
      expect(statusSep.length, equals(1));
      final foodSep = statusSep.first;
      expect(foodSep.spentSatang, equals(850000));
      expect(foodSep.remainingSatang, equals(150000)); // 1,500 THB left
      expect(foodSep.percentUsed, equals(0.85));
      expect(foodSep.isWarning, isTrue);
      expect(foodSep.isExceeded, isFalse);

      // 3. Strict Non-Rollover test: Check October 2026 status!
      // In October, spent starts from 0, full 10,000 THB available, no rollover of remaining 1,500 THB!
      var statusOct = await db.budgetsDao.getBudgetStatusForMonth(2026, 10);
      expect(statusOct.length, equals(1));
      final foodOct = statusOct.first;
      expect(foodOct.spentSatang, equals(0)); // Reset to 0!
      expect(foodOct.remainingSatang, equals(1000000)); // Full budget
      expect(foodOct.percentUsed, equals(0.0));
      expect(foodOct.isWarning, isFalse);
    });

    test('Budget exceeds 100% trigger', () async {
      final foodCat = (await db.categoriesDao.getActiveCategories())
          .firstWhere((c) => c.nameTh == 'อาหารและเครื่องดื่ม');
      final scb = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');

      await db.budgetsDao.setBudget(categoryId: foodCat.id, limitSatang: 500000); // 5,000 THB

      // Spend 5,500 THB (110%)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-food-over',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          categoryId: Value(foodCat.id),
          amountOriginalSatang: 550000,
          currencyCode: 'THB',
          amountThbSatang: 550000,
          transactionDate: DateTime(2026, 9, 20),
          createdAt: DateTime(2026, 9, 20),
          updatedAt: DateTime(2026, 9, 20),
        ),
      );

      final status = await db.budgetsDao.getBudgetStatusForMonth(2026, 9);
      final food = status.first;
      expect(food.isExceeded, isTrue);
      expect(food.remainingSatang, equals(-50000)); // Over budget by 500 THB
    });
  });
}
