import 'package:drift/drift.dart';

class TaxResidencyRecords extends Table {
  TextColumn get id => text()(); // UUID v4
  IntColumn get taxYear => integer()();
  IntColumn get daysInThailand => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
