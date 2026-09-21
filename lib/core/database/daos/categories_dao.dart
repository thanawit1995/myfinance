import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Stream<List<Category>> watchActiveCategories() {
    return (select(categories)
          ..where((c) => c.isActive.equals(true) & c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm(expression: c.nameTh)]))
        .watch();
  }

  Future<List<Category>> getActiveCategories([String? type]) {
    final query = select(categories)..where((c) => c.isActive.equals(true) & c.deletedAt.isNull());
    if (type != null) {
      query.where((c) => c.categoryType.equals(type));
    }
    query.orderBy([(c) => OrderingTerm(expression: c.nameTh)]);
    return query.get();
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
}
