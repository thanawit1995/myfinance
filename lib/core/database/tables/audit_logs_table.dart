import 'package:drift/drift.dart';

class AuditLogs extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get entityTable => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()(); // CREATE, UPDATE, DELETE
  TextColumn get beforeDataJson => text().nullable()();
  TextColumn get afterDataJson => text().nullable()();
  DateTimeColumn get changeTimestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
