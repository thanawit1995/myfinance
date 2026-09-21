import 'package:drift/drift.dart';
import 'categories_table.dart';

class Budgets extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get categoryId => text().references(Categories, #id)();
  IntColumn get limitSatang => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
