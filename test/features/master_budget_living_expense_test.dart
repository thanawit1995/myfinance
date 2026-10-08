import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';

/// ทดสอบว่า Master Budget (totalLivingExpense) คิดเฉพาะรายจ่ายที่ไม่ใช่การลงทุน
/// ตรงกับ Logic ใน vault_home_screen.dart บรรทัด 2104-2116

bool _isInvestmentBuy(Transaction t) {
  return (t.tag != null && t.tag!.startsWith('investment_buy:')) ||
      (t.categoryId == 'cat-exp-0000-4000-8000-000000000099');
}

int _computeLivingExpense(List<Transaction> monthTx) {
  int total = 0;
  for (final t in monthTx) {
    if (t.transactionType == 'expense') {
      final amount = t.amountThbSatang + t.feeThbSatang;
      if (!_isInvestmentBuy(t)) {
        total += amount;
      }
    }
  }
  return total;
}

int _computeTotalExpense(List<Transaction> monthTx) {
  int total = 0;
  for (final t in monthTx) {
    if (t.transactionType == 'expense') {
      total += t.amountThbSatang + t.feeThbSatang;
    }
  }
  return total;
}

/// ดึง transactions ของเดือนที่กำหนด ตรงกับ Logic ใน vault_home_screen.dart
Future<List<Transaction>> _getMonthTx(AppDatabase db, int year, int month) {
  final start = DateTime(year, month, 1);
  final end = DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 1);
  return (db.select(db.transactions)
        ..where((t) =>
            t.deletedAt.isNull() &
            t.transactionDate.isBiggerOrEqualValue(start) &
            t.transactionDate.isSmallerThanValue(end)))
      .get();
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  group('Master Budget - Living Expense (ไม่รวมการลงทุน)', () {
    test('รายจ่ายปกติถูกนับใน totalLivingExpense ครบถ้วน', () async {
      final scb = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');
      final foodCat = (await db.categoriesDao.getActiveCategories())
          .firstWhere((c) => c.nameTh == 'อาหารและเครื่องดื่ม');
      final now = DateTime(2026, 10, 5);

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-food-1',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          categoryId: Value(foodCat.id),
          amountOriginalSatang: 50000, // 500 THB
          currencyCode: 'THB',
          amountThbSatang: 50000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final monthTx = await _getMonthTx(db, now.year, now.month);
      final living = _computeLivingExpense(monthTx);
      expect(living, equals(50000),
          reason: 'รายจ่ายอาหาร 500 THB ต้องนับใน living expense');
    });

    test('รายจ่ายที่มี tag investment_buy ถูกกรองออกจาก totalLivingExpense', () async {
      final scb = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');
      const invCatId = 'cat-exp-0000-4000-8000-000000000099';
      final now = DateTime(2026, 10, 6);

      // รายจ่ายปกติ 1,000 THB
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-normal-1',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          amountOriginalSatang: 100000,
          currencyCode: 'THB',
          amountThbSatang: 100000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // รายจ่ายการลงทุน 5,000 THB (tag = investment_buy:asset-xyz)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-invest-1',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          categoryId: const Value(invCatId),
          tag: const Value('investment_buy:asset-xyz'),
          amountOriginalSatang: 500000,
          currencyCode: 'THB',
          amountThbSatang: 500000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final monthTx = await _getMonthTx(db, now.year, now.month);
      final totalExp = _computeTotalExpense(monthTx);
      final living = _computeLivingExpense(monthTx);

      // totalExpense รวมทั้งหมด = 6,000 THB
      expect(totalExp, equals(600000),
          reason: 'totalExpense ต้องรวมทั้งรายจ่ายปกติและการลงทุน');

      // livingExpense เฉพาะรายจ่ายปกติ = 1,000 THB
      expect(living, equals(100000),
          reason: 'livingExpense ต้องกรองการลงทุนออก เหลือแค่รายจ่ายปกติ 1,000 THB');
    });

    test('รายจ่ายที่มี categoryId = cat-exp-0000-4000-8000-000000000099 ถูกกรองออก (ไม่มี tag)', () async {
      final scb = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');
      const invCatId = 'cat-exp-0000-4000-8000-000000000099';
      final now = DateTime(2026, 10, 7);

      // ลงทุน 10,000 THB โดยไม่มี tag แต่ใช้ category ID การลงทุน
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-invest-cat',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          categoryId: const Value(invCatId),
          amountOriginalSatang: 1000000,
          currencyCode: 'THB',
          amountThbSatang: 1000000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final monthTx = await _getMonthTx(db, now.year, now.month);
      final living = _computeLivingExpense(monthTx);

      expect(living, equals(0),
          reason: 'รายการที่ใช้ categoryId ลงทุนต้องไม่ถูกนับใน livingExpense');
    });

    test('remainingBudget = totalBudget - totalLivingExpense (ไม่หักการลงทุน)', () async {
      final foodCat = (await db.categoriesDao.getActiveCategories())
          .firstWhere((c) => c.nameTh == 'อาหารและเครื่องดื่ม');
      final scb = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');
      const invCatId = 'cat-exp-0000-4000-8000-000000000099';
      final now = DateTime(2026, 10, 8);

      // ตั้ง budget อาหาร 5,000 THB
      await db.budgetsDao.setBudget(
          categoryId: foodCat.id, limitSatang: 500000);

      // จ่ายอาหาร 2,000 THB
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-food-budget',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          categoryId: Value(foodCat.id),
          amountOriginalSatang: 200000,
          currencyCode: 'THB',
          amountThbSatang: 200000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // ซื้อหุ้น 20,000 THB
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-invest-budget',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          categoryId: const Value(invCatId),
          tag: const Value('investment_buy:stock-abc'),
          amountOriginalSatang: 2000000,
          currencyCode: 'THB',
          amountThbSatang: 2000000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final monthTx = await _getMonthTx(db, now.year, now.month);
      final livingExp = _computeLivingExpense(monthTx);

      // remaining = 500,000 - 200,000 = 300,000 (ไม่นับ 2,000,000 ที่เป็นการลงทุน)
      const totalBudget = 500000;
      final remaining = (totalBudget - livingExp).clamp(0, totalBudget);

      expect(livingExp, equals(200000),
          reason: 'livingExpense ต้องเป็น 2,000 THB เท่านั้น (ไม่รวมหุ้น)');
      expect(remaining, equals(300000),
          reason: 'remaining budget ต้องเป็น 3,000 THB (5,000 - 2,000) ไม่ใช่ -15,000');
    });

    test('dailyExpenses map ไม่รวมรายการลงทุน', () async {
      final scb = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');
      const invCatId = 'cat-exp-0000-4000-8000-000000000099';
      final now = DateTime(2026, 10, 9);

      // รายจ่ายปกติวันที่ 9
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-daily-1',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          amountOriginalSatang: 30000,
          currencyCode: 'THB',
          amountThbSatang: 30000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // รายการลงทุนวันที่ 9 (ต้องไม่อยู่ใน dailyExpenses)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-daily-invest',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          categoryId: const Value(invCatId),
          tag: const Value('investment_buy:etf-xyz'),
          amountOriginalSatang: 800000,
          currencyCode: 'THB',
          amountThbSatang: 800000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final monthTx = await _getMonthTx(db, now.year, now.month);

      // คำนวณ dailyExpenses แบบเดียวกับ vault_home_screen.dart
      final Map<int, int> dailyExpenses = {};
      for (int d = 1; d <= now.day; d++) {
        dailyExpenses[d] = 0;
      }
      for (final t in monthTx) {
        if (t.transactionType == 'expense') {
          final isInv = (t.tag != null && t.tag!.startsWith('investment_buy:')) ||
              (t.categoryId == invCatId);
          if (!isInv) {
            final d = t.transactionDate.day;
            if (d <= now.day) {
              dailyExpenses[d] = (dailyExpenses[d] ?? 0) + (t.amountThbSatang + t.feeThbSatang);
            }
          }
        }
      }

      // วันที่ 9 ต้องมีแค่ 300 THB ไม่ใช่ 8,300 THB
      expect(dailyExpenses[9], equals(30000),
          reason: 'dailyExpenses วันที่ 9 ต้องมีเฉพาะรายจ่ายปกติ ไม่รวมการลงทุน');
    });
  });
}
