import 'package:drift/drift.dart';

@DataClassName('ImportBatch')
class ImportBatches extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get fileName => text()();
  TextColumn get templateType => text().withDefault(const Constant('custom'))(); // notion_income, notion_expense, custom
  IntColumn get totalImported => integer()();
  DateTimeColumn get importedAt => dateTime()();
  BoolColumn get isRolledBack => boolean().withDefault(const Constant(false))();
  DateTimeColumn get rolledBackAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
