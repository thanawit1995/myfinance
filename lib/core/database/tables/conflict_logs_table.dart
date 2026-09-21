import 'package:drift/drift.dart';

@DataClassName('ConflictLog')
class ConflictLogs extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get targetTable => text()();
  TextColumn get recordId => text()();
  TextColumn get conflictType => text()(); // update_collision, delete_collision
  TextColumn get localDataJson => text()();
  TextColumn get remoteDataJson => text()();
  TextColumn get resolvedAction => text()(); // last_write_wins_local, last_write_wins_remote
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
