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
        color: const Value('0xFF27AE60'),
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
        color: const Value('0xFF10AC84'),
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

    // Update standard tax types for existing databases
    await updateStandardIncomeCategoryTaxTypes();
    // Update default categories with vibrant colors
    await updateDefaultCategoryColors();
  }

  Future<void> updateDefaultCategoryColors() async {
    const defaultColorMap = <String, String>{
      // Incomes
      'cat-inc-0000-4000-8000-000000000001': '0xFF10AC84',
      'cat-inc-0000-4000-8000-000000000002': '0xFF1DD1A1',
      'cat-inc-0000-4000-8000-000000000003': '0xFFFECA57',
      'cat-inc-0000-4000-8000-000000000004': '0xFFFF9F43',
      'cat-inc-0000-4000-8000-000000000005': '0xFF00D2D3',
      'cat-inc-0000-4000-8000-000000000099': '0xFF27AE60',
      // Expenses
      'cat-exp-0000-4000-8000-000000000001': '0xFFFF6B6B',
      'cat-exp-0000-4000-8000-000000000002': '0xFFFF9F43',
      'cat-exp-0000-4000-8000-000000000003': '0xFF2E86DE',
      'cat-exp-0000-4000-8000-000000000004': '0xFF00D2D3',
      'cat-exp-0000-4000-8000-000000000005': '0xFFEE5253',
      'cat-exp-0000-4000-8000-000000000006': '0xFF9B59B6',
      'cat-exp-0000-4000-8000-000000000007': '0xFF5F27CD',
      'cat-exp-0000-4000-8000-000000000008': '0xFF34495E',
      'cat-exp-0000-4000-8000-000000000009': '0xFF54A0FF',
      'cat-exp-0000-4000-8000-000000000010': '0xFFE056FD',
      'cat-exp-0000-4000-8000-000000000011': '0xFFFF6B8B',
      'cat-exp-0000-4000-8000-000000000012': '0xFFA0522D',
      'cat-exp-0000-4000-8000-000000000013': '0xFF2E86DE',
      'cat-exp-0000-4000-8000-000000000014': '0xFF27AE60',
      'cat-exp-0000-4000-8000-000000000015': '0xFF10AC84',
      // Transfer
      'cat-trf-0000-4000-8000-000000000001': '0xFF54A0FF',
    };

    const nameColorMap = <String, String>{
      'อาหารและเครื่องดื่ม': '0xFFFF6B6B',
      'Food & Dining': '0xFFFF6B6B',
      'ที่อยู่อาศัย': '0xFFFF9F43',
      'Housing': '0xFFFF9F43',
      'การเดินทาง': '0xFF2E86DE',
      'Transportation': '0xFF2E86DE',
      'สาธารณูปโภค': '0xFF00D2D3',
      'Utilities': '0xFF00D2D3',
      'สุขภาพและรักษาพยาบาล': '0xFFEE5253',
      'Healthcare': '0xFFEE5253',
      'ช้อปปิ้ง': '0xFF9B59B6',
      'Shopping': '0xFF9B59B6',
      'บันเทิงและการพักผ่อน': '0xFF5F27CD',
      'Entertainment': '0xFF5F27CD',
      'การศึกษาและพัฒนาตนเอง': '0xFF34495E',
      'Education': '0xFF34495E',
      'ค่าธรรมเนียมและการเงิน': '0xFF54A0FF',
      'Financial Fees': '0xFF54A0FF',
      'ค่าใช้จ่ายอื่นๆ': '0xFFE056FD',
      'Other Expense': '0xFFE056FD',
      'ของขวัญ / ของฝาก': '0xFFFF6B8B',
      'Gifts': '0xFFFF6B8B',
      'ยูซุ': '0xFFA0522D',
      'Yuzu': '0xFFA0522D',
      'ท่องเที่ยว': '0xFF2E86DE',
      'Travel': '0xFF2E86DE',
      'เงินสะสม กบข.': '0xFF27AE60',
      'GPF Pension Fund': '0xFF27AE60',
      'เบี้ยประกันชีวิตและออมทรัพย์': '0xFF10AC84',
      'Life & Savings Insurance': '0xFF10AC84',
      'เงินเดือน': '0xFF10AC84',
      'Salary': '0xFF10AC84',
      'รับจ้าง / ค่าอยู่เวร': '0xFF1DD1A1',
      'Freelance / Shift': '0xFF1DD1A1',
      'ดอกเบี้ยและเงินปันผล': '0xFFFECA57',
      'Interest & Dividends': '0xFFFECA57',
      'ธุรกิจ / ขายของ': '0xFFFF9F43',
      'Business / Sales': '0xFFFF9F43',
      'รายรับอื่นๆ': '0xFF00D2D3',
      'Other Income': '0xFF00D2D3',
      'ขายสินทรัพย์': '0xFF27AE60',
      'Asset Sale': '0xFF27AE60',
      'โอนเงินระหว่างบัญชี': '0xFF54A0FF',
      'Account Transfer': '0xFF54A0FF',
    };

    for (final entry in defaultColorMap.entries) {
      await (update(categories)..where((c) => c.id.equals(entry.key)))
          .write(CategoriesCompanion(color: Value(entry.value)));
    }

    for (final entry in nameColorMap.entries) {
      await (update(categories)
            ..where((c) =>
                c.isSystem.equals(true) &
                (c.nameTh.equals(entry.key) | c.nameEn.equals(entry.key))))
          .write(CategoriesCompanion(color: Value(entry.value)));
    }
  }

  Future<void> updateStandardIncomeCategoryTaxTypes() async {
    // 1. รับจ้าง / ค่าอยู่เวร -> 40_1
    await (update(categories)
          ..where((c) =>
              c.id.equals('cat-inc-0000-4000-8000-000000000002') |
              c.nameTh.equals('รับจ้าง / ค่าอยู่เวร') |
              c.nameEn.equals('Freelance / Shift')))
        .write(const CategoriesCompanion(taxIncomeType: Value('40_1')));

    // 2. รายรับอื่นๆ -> non_taxable
    await (update(categories)
          ..where((c) =>
              c.id.equals('cat-inc-0000-4000-8000-000000000005') |
              c.nameTh.equals('รายรับอื่นๆ') |
              c.nameEn.equals('Other Income')))
        .write(const CategoriesCompanion(taxIncomeType: Value('non_taxable')));

    // 3. ดอกเบี้ยและเงินปันผล -> 40_4
    await (update(categories)
          ..where((c) =>
              c.id.equals('cat-inc-0000-4000-8000-000000000003') |
              c.nameTh.equals('ดอกเบี้ยและเงินปันผล') |
              c.nameEn.equals('Interest & Dividends')))
        .write(const CategoriesCompanion(taxIncomeType: Value('40_4')));
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
