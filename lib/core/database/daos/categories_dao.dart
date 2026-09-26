import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<Category>> watchActiveCategories([String? type]) {
    final query = select(categories)
      ..where((c) => c.isActive.equals(true) & c.deletedAt.isNull());
    if (type != null) {
      query.where((c) => c.categoryType.equals(type));
    }
    return (query..orderBy([(c) => OrderingTerm(expression: c.sortOrder), (c) => OrderingTerm(expression: c.nameTh)])).watch();
  }

  Future<List<Category>> getActiveCategories([String? type]) async {
    if (type == null || type == 'expense') {
      await ensureEssentialTaxCategories();
    }
    final query = select(categories)..where((c) => c.isActive.equals(true) & c.deletedAt.isNull());
    if (type != null) {
      query.where((c) => c.categoryType.equals(type));
    }
    query.orderBy([(c) => OrderingTerm(expression: c.sortOrder), (c) => OrderingTerm(expression: c.nameTh)]);
    return query.get();
  }

  Future<List<Category>> getAllCategories() {
    return (select(categories)..where((c) => c.deletedAt.isNull())).get();
  }

  Future<void> updateCategorySortOrders(List<String> orderedCategoryIds) async {
    await batch((b) {
      for (var i = 0; i < orderedCategoryIds.length; i++) {
        b.update(
          categories,
          CategoriesCompanion(
            sortOrder: Value(i),
            updatedAt: Value(DateTime.now()),
          ),
          where: (c) => c.id.equals(orderedCategoryIds[i]),
        );
      }
    });
  }

  Future<void> ensureEssentialTaxCategories() async {
    final now = DateTime.now();
    final essential = [
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000014',
        nameTh: 'เงินสะสม กบข.',
        nameEn: 'GPF Pension Fund',
        categoryType: 'expense',
        icon: const Value('account_balance'),
        color: const Value('0xFF4CAF50'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-exp-0000-4000-8000-000000000015',
        nameTh: 'เบี้ยประกันชีวิตและออมทรัพย์',
        nameEn: 'Life & Savings Insurance',
        categoryType: 'expense',
        icon: const Value('health_and_safety'),
        color: const Value('0xFF009688'),
        isSystem: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    ];

    for (final cat in essential) {
      final existing = await (select(categories)
            ..where((c) => (c.nameTh.equals(cat.nameTh.value) | c.nameEn.equals(cat.nameEn.value)) & c.deletedAt.isNull()))
          .getSingleOrNull();
      if (existing == null) {
        await into(categories).insert(cat, mode: InsertMode.insertOrIgnore);
      }
    }
  }

  /// Returns or creates the system standard "ขายสินทรัพย์" (Asset Sale) category for sell trades.
  Future<Category> getOrCreateAssetSaleCategory() async {
    final existing = await (select(categories)
          ..where((c) =>
              c.deletedAt.isNull() &
              c.categoryType.equals('income') &
              (c.nameTh.equals('ขายสินทรัพย์') | c.nameEn.equals('Asset Sale'))))
        .getSingleOrNull();

    if (existing != null) return existing;

    final now = DateTime.now();
    final newCat = CategoriesCompanion.insert(
      id: 'cat-inc-0000-4000-8000-000000000099',
      nameTh: 'ขายสินทรัพย์',
      nameEn: 'Asset Sale',
      categoryType: 'income',
      taxIncomeType: const Value('non_taxable'),
      icon: const Value('sell'),
      color: const Value('0xFF2E7D32'),
      isSystem: const Value(true),
      createdAt: now,
      updatedAt: now,
    );

    await into(categories).insert(newCat, mode: InsertMode.insertOrIgnore);
    return (await getCategoryById(newCat.id.value)) ??
        (await (select(categories)..where((c) => c.nameTh.equals('ขายสินทรัพย์'))).getSingle());
  }

  /// Returns or creates the standard "การลงทุน" (Investment) expense category for buy trades.
  Future<Category> getOrCreateInvestmentExpenseCategory() async {
    final existing = await (select(categories)
          ..where((c) =>
              c.deletedAt.isNull() &
              c.categoryType.equals('expense') &
              (c.nameTh.equals('การลงทุน') | c.nameEn.equals('Investment'))))
        .getSingleOrNull();

    if (existing != null) return existing;

    final now = DateTime.now();
    final newCat = CategoriesCompanion.insert(
      id: 'cat-exp-0000-4000-8000-000000000099',
      nameTh: 'การลงทุน',
      nameEn: 'Investment',
      categoryType: 'expense',
      icon: const Value('show_chart'),
      color: const Value('0xFF1976D2'),
      isSystem: const Value(true),
      createdAt: now,
      updatedAt: now,
    );

    await into(categories).insert(newCat, mode: InsertMode.insertOrIgnore);
    return (await getCategoryById(newCat.id.value)) ??
        (await (select(categories)..where((c) => c.nameTh.equals('การลงทุน'))).getSingle());
  }

  Future<List<Category>> getActiveCategoriesOrderedByUsage([String? type]) async {
    if (type == null || type == 'expense') {
      await ensureEssentialTaxCategories();
    }
    final activeCats = await getActiveCategories(type);
    if (activeCats.isEmpty) return [];

    final rows = await db.customSelect(
      'SELECT category_id, COUNT(*) as usage_count FROM transactions WHERE deleted_at IS NULL AND category_id IS NOT NULL GROUP BY category_id',
      readsFrom: {db.transactions},
    ).get();

    final usageMap = <String, int>{};
    for (final row in rows) {
      final catId = row.read<String>('category_id');
      final count = row.read<int>('usage_count');
      usageMap[catId] = count;
    }

    final sorted = List<Category>.from(activeCats);
    sorted.sort((a, b) {
      final countA = usageMap[a.id] ?? 0;
      final countB = usageMap[b.id] ?? 0;
      if (countB != countA) {
        return countB.compareTo(countA); // Most used first
      }
      return a.nameTh.compareTo(b.nameTh);
    });

    return sorted;
  }

  Future<List<Category>> getRootCategories([String? type]) {
    final query = select(categories)
      ..where((c) => c.isActive.equals(true) & c.deletedAt.isNull() & c.parentId.isNull());
    if (type != null) {
      query.where((c) => c.categoryType.equals(type));
    }
    query.orderBy([(c) => OrderingTerm(expression: c.nameTh)]);
    return query.get();
  }

  Future<List<Category>> getSubcategories(String parentId) {
    return (select(categories)
          ..where((c) => c.isActive.equals(true) & c.deletedAt.isNull() & c.parentId.equals(parentId))
          ..orderBy([(c) => OrderingTerm(expression: c.nameTh)]))
        .get();
  }

  Future<Category?> getCategoryById(String id) {
    return (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<int> createCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  Future<bool> updateCategory(CategoriesCompanion category) {
    return update(categories).replace(category);
  }

  Future<int> deactivateCategory(String id) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<Category>> getInactiveCategories([String? type]) {
    final query = select(categories)..where((c) => c.isActive.equals(false) & c.deletedAt.isNull());
    if (type != null) {
      query.where((c) => c.categoryType.equals(type));
    }
    query.orderBy([(c) => OrderingTerm(expression: c.nameTh)]);
    return query.get();
  }

  Future<int> restoreCategory(String id) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        isActive: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> softDeleteCategory(String id) {
    final now = DateTime.now();
    return (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        isActive: const Value(false),
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }
}
