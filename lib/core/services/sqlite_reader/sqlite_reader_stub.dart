import 'dart:typed_data';
import '../../database/app_database.dart';
import 'sqlite_backup_data.dart';

Future<SqliteBackupData> readSqliteBackupData(Uint8List sqliteBytes) async {
  throw UnsupportedError('readSqliteBackupData is not supported on this platform');
}

Future<Uint8List> dumpDriftDatabaseToSqliteBytes(AppDatabase db) async {
  throw UnsupportedError('dumpDriftDatabaseToSqliteBytes is not supported on this platform');
}
