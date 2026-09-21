import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/budgets_table.dart';
import '../tables/categories_table.dart';
import '../tables/transactions_table.dart';

part 'budgets_dao.g.dart';

class CategoryBudgetStatus {
  final String budgetId;
  final String categoryId;
  final String categoryNameTh;
  final String categoryNameEn;
  final String? color;
  final String? icon;
  final int limitSatang;
  final int spentSatang;
  final int remainingSatang;
  final double percentUsed;

  const CategoryBudgetStatus({
    required this.budgetId,
    required this.categoryId,
    required this.categoryNameTh,
    required this.categoryNameEn,
    this.color,
    this.icon,
    required this.limitSatang,
    required this.spentSatang,
    required this.remainingSatang,
    required this.percentUsed,
  });

  bool get isWarning => percentUsed >= 0.8 && percentUsed < 1.0;
  bool get isExceeded => percentUsed >= 1.0;
}

@DriftAccessor(tables: [Budgets, Categories, Transactions])
class BudgetsDao extends DatabaseAccessor<AppDatabase> with _$BudgetsDaoMixin {
  BudgetsDao(super.db);

  static const _uuid = Uuid();

  Stream<List<Budget>> watchBudgets() {
    return (select(budgets)..where((b) => b.isActive.equals(true) & b.deletedAt.isNull())).watch();
  }

  Future<List<Budget>> getActiveBudgets() {
    return (select(budgets)..where((b) => b.isActive.equals(true) & b.deletedAt.isNull())).get();
  }

  Future<int> setBudget({required String categoryId, required int limitSatang}) async {
    final now = DateTime.now();
    final existing = await (select(budgets)
          ..where((b) => b.categoryId.equals(categoryId) & b.deletedAt.isNull()))
        .getSingleOrNull();

    if (existing != null) {
      return (update(budgets)..where((b) => b.id.equals(existing.id))).write(
        BudgetsCompanion(
          limitSatang: Value(limitSatang),
          isActive: const Value(true),
          updatedAt: Value(now),
        ),
      );
    } else {
      return into(budgets).insert(
        BudgetsCompanion.insert(
          id: _uuid.v4(),
          categoryId: categoryId,
          limitSatang: limitSatang,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  Future<int> deleteBudget(String id) {
    return (update(budgets)..where((b) => b.id.equals(id))).write(
      BudgetsCompanion(
        isActive: const Value(false),
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Calculates monthly spending vs budget per category (strictly non-rollover).
  Future<List<CategoryBudgetStatus>> getBudgetStatusForMonth(int year, int month) async {
    final activeBudgets = await (select(budgets)
          ..where((b) => b.isActive.equals(true) & b.deletedAt.isNull()))
        .get();

    final allCats = await select(categories).get();
    final catLookup = {for (final c in allCats) c.id: c};

    final start = DateTime(year, month, 1);
    final end = DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 1);

    final result = <CategoryBudgetStatus>[];

    for (final b in activeBudgets) {
      final trans = await (select(transactions)
            ..where((t) =>
                t.deletedAt.isNull() &
                t.transactionType.equals('expense') &
                t.categoryId.equals(b.categoryId) &
                t.transactionDate.isBiggerOrEqualValue(start) &
                t.transactionDate.isSmallerThanValue(end)))
          .get();

      int spent = 0;
      for (final t in trans) {
        spent += (t.amountThbSatang + t.feeThbSatang);
      }

      final remaining = b.limitSatang - spent;
      final percent = b.limitSatang > 0 ? (spent / b.limitSatang) : 0.0;
      final cat = catLookup[b.categoryId];

      result.add(CategoryBudgetStatus(
        budgetId: b.id,
        categoryId: b.categoryId,
        categoryNameTh: cat?.nameTh ?? '',
        categoryNameEn: cat?.nameEn ?? '',
        color: cat?.color,
        icon: cat?.icon,
        limitSatang: b.limitSatang,
        spentSatang: spent,
        remainingSatang: remaining,
        percentUsed: percent,
      ));
    }

    return result;
  }
}
