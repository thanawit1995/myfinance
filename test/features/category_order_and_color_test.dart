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

  group('Category Order & Color Preservation Tests', () {
    test('Custom category color is not overwritten by ensureEssentialTaxCategories or getActiveCategories', () async {
      // 1. Get initial categories
      final categories = await db.categoriesDao.getActiveCategories('expense');
      final foodCategory = categories.firstWhere((c) => c.nameTh == 'อาหารและเครื่องดื่ม');

      // 2. Customize food category color to custom color
      const customColor = '0xFF4A90E2';
      await (db.update(db.categories)..where((c) => c.id.equals(foodCategory.id))).write(
        const CategoriesCompanion(
          color: Value(customColor),
        ),
      );

      // Verify it was updated
      var updated = await (db.select(db.categories)..where((c) => c.id.equals(foodCategory.id))).getSingle();
      expect(updated.color, equals(customColor));

      // 3. Call ensureEssentialTaxCategories() and updateDefaultCategoryColors()
      await db.categoriesDao.ensureEssentialTaxCategories();
      await db.categoriesDao.updateDefaultCategoryColors();

      // Verify custom color is still preserved!
      updated = await (db.select(db.categories)..where((c) => c.id.equals(foodCategory.id))).getSingle();
      expect(updated.color, equals(customColor));

      // 4. Call getActiveCategories()
      final refreshed = await db.categoriesDao.getActiveCategories('expense');
      final refreshedFood = refreshed.firstWhere((c) => c.id == foodCategory.id);
      expect(refreshedFood.color, equals(customColor));
    });

    test('Categories are sorted by sortOrder and createdAt rather than Thai alphabetical order', () async {
      // Insert categories with specific sortOrder
      await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          id: 'cat-z-first',
          nameTh: 'ฮ.นกฮูก (ตัวอักษรท้ายสุด)',
          nameEn: 'Owl Z',
          categoryType: 'expense',
          sortOrder: const Value(1),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );

      await db.into(db.categories).insert(
        CategoriesCompanion.insert(
          id: 'cat-a-second',
          nameTh: 'ก.ไก่ (ตัวอักษรแรกสุด)',
          nameEn: 'Chicken A',
          categoryType: 'expense',
          sortOrder: const Value(2),
          createdAt: DateTime(2026, 1, 2),
          updatedAt: DateTime(2026, 1, 2),
        ),
      );

      final active = await db.categoriesDao.getActiveCategories('expense');
      final catZ = active.firstWhere((c) => c.id == 'cat-z-first');
      final catA = active.firstWhere((c) => c.id == 'cat-a-second');

      // catZ has sortOrder 1, catA has sortOrder 2
      // catZ should appear before catA despite 'ฮ' being alphabetically after 'ก'
      final indexZ = active.indexOf(catZ);
      final indexA = active.indexOf(catA);
      expect(indexZ, lessThan(indexA));
    });
  });
}
