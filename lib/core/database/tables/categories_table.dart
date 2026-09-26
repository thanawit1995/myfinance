import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get nameTh => text()();
  TextColumn get nameEn => text()();
  TextColumn get categoryType => text()(); // income, expense, transfer
  TextColumn get parentId => text().nullable().references(Categories, #id)();
  TextColumn get taxIncomeType => text().nullable()(); // 40_1, 40_2, 40_4, 40_8, null
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
