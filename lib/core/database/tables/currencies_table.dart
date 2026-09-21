import 'package:drift/drift.dart';

class Currencies extends Table {
  TextColumn get code => text()(); // THB, USD
  TextColumn get name => text()();
  TextColumn get symbol => text()();
  BoolColumn get isBase => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {code};
}
