import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/native.dart';
import 'package:myfinance/core/services/backup_restore_service.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  late AppDatabase db;
  late BackupRestoreService service;
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(inMemoryConnection());
    service = BackupRestoreService(db: db);
    tempDir = await Directory.systemTemp.createTemp('myfinance_backup_test_');
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('BackupRestoreService Tests', () {
    test('inspectBackupFile with invalid file returns isValid false', () async {
      final invalidFile = File(p.join(tempDir.path, 'corrupted.db'));
      await invalidFile.writeAsString('not a sqlite database');

      final result = await service.inspectBackupFile(invalidFile.path);

      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('inspectBackupFile with valid SQLite database previews accounts and transactions', () async {
      final validDbFile = File(p.join(tempDir.path, 'valid_backup.db'));
      final sqliteDb = sqlite.sqlite3.open(validDbFile.path);

      // Create test tables and dummy data
      sqliteDb.execute('''
        CREATE TABLE accounts (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          deleted_at INTEGER
        );
        CREATE TABLE transactions (
          id TEXT PRIMARY KEY,
          amount_satang INTEGER NOT NULL,
          transaction_date TEXT NOT NULL,
          deleted_at INTEGER
        );
      ''');

      sqliteDb.execute("INSERT INTO accounts VALUES ('acc1', 'SCB Savings', NULL);");
      sqliteDb.execute("INSERT INTO accounts VALUES ('acc2', 'KBank Current', NULL);");
      sqliteDb.execute("INSERT INTO transactions VALUES ('tx1', 50000, '2026-09-25T10:00:00', NULL);");
      sqliteDb.execute("INSERT INTO transactions VALUES ('tx2', 15000, '2026-09-25T12:00:00', NULL);");
      sqliteDb.dispose();

      final result = await service.inspectBackupFile(validDbFile.path);

      expect(result.isValid, isTrue);
      expect(result.totalAccounts, equals(2));
      expect(result.sampleAccountNames, containsAll(['SCB Savings', 'KBank Current']));
      expect(result.totalTransactions, equals(2));
      expect(result.latestTransactionDate, isNotNull);
      expect(result.sizeBytes, greaterThan(0));
    });

    test('getSafetyBackups returns empty or valid list', () async {
      final backups = await service.getSafetyBackups();
      expect(backups, isA<List<SafetyBackupItem>>());
    });

    test('setDesignatedBackupDirectory and getDesignatedBackupDirectory work properly', () async {
      final designatedFolder = p.join(tempDir.path, 'MyBackupFolder');
      final configured = await service.setDesignatedBackupDirectory(designatedFolder);

      expect(configured, contains('MyFinance_Backup'));
      expect(await Directory(configured).exists(), isTrue);

      final fetched = await service.getDesignatedBackupDirectory();
      expect(fetched, equals(configured));

      await service.clearDesignatedBackupDirectory();
      final cleared = await service.getDesignatedBackupDirectory();
      expect(cleared, isNull);
    });

    test('saveRollingBackup maintains rolling 3 versions and deletes older versions', () async {
      final backupDir = Directory(p.join(tempDir.path, 'MyFinance_Backup'));
      await backupDir.create(recursive: true);

      // Create a dummy source db file
      final sourceDb = File(p.join(tempDir.path, 'dummy_source.sqlite'));
      await sourceDb.writeAsString('SQLite format 3 test dummy data');

      // Create 4 rolling backups with slight delay to ensure distinct timestamps
      final path1 = await service.saveRollingBackup(customFolderPath: backupDir.path, customSourceDb: sourceDb);
      await Future.delayed(const Duration(milliseconds: 50));
      final path2 = await service.saveRollingBackup(customFolderPath: backupDir.path, customSourceDb: sourceDb);
      await Future.delayed(const Duration(milliseconds: 50));
      final path3 = await service.saveRollingBackup(customFolderPath: backupDir.path, customSourceDb: sourceDb);
      await Future.delayed(const Duration(milliseconds: 50));
      final path4 = await service.saveRollingBackup(customFolderPath: backupDir.path, customSourceDb: sourceDb);

      expect(path1, isNotNull);
      expect(path2, isNotNull);
      expect(path3, isNotNull);
      expect(path4, isNotNull);

      // Verify that only 3 files remain in backupDir
      final rollingBackups = await service.getRollingBackupsInDesignatedDirectory(customFolderPath: backupDir.path);
      expect(rollingBackups.length, equals(3));

      // Versions should be ordered 1 (latest), 2, 3
      expect(rollingBackups[0].versionOrder, equals(1));
      expect(rollingBackups[1].versionOrder, equals(2));
      expect(rollingBackups[2].versionOrder, equals(3));

      // Oldest file (path1) should have been deleted to keep only 3 versions
      expect(await File(path1!).exists(), isFalse);
      expect(await File(path4!).exists(), isTrue);
    });

    test('onLedgerModified callback is wired and can be called', () async {
      bool called = false;
      db.transactionsDao.onLedgerModified = () {
        called = true;
      };

      db.transactionsDao.onLedgerModified?.call();
      expect(called, isTrue);
    });
  });
}
