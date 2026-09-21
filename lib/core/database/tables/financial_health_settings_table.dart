import 'package:drift/drift.dart';

class FinancialHealthSettings extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get metricCode => text().unique()();
  TextColumn get targetOperator => text()(); // >, >=, <, <=
  TextColumn get targetValue => text()();
  TextColumn get warningValue => text().nullable()();
  IntColumn get userParam1Satang => integer().nullable()(); // Family reserve or Sum insured
  IntColumn get userParam2Satang => integer().nullable()(); // Estimated medical cost
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
