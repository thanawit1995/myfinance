import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:myfinance/core/services/google_drive_sync_service.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  late AppDatabase db;
  late GoogleDriveSyncService syncService;
  late Directory tempDir;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    db = AppDatabase.forTesting(inMemoryConnection());
    tempDir = await Directory.systemTemp.createTemp('gdrive_sync_test_');
    syncService = GoogleDriveSyncService(
      db: db,
      transactionsDao: db.transactionsDao,
      accountsDao: db.accountsDao,
      syncDao: db.syncDao,
      customDocDir: tempDir,
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('GoogleDriveSyncService Tests', () {
    test('Folder lifecycle: set, get, clear', () async {
      final testFolder = p.join(tempDir.path, 'My Drive', 'VAULT');
      await syncService.setDriveFolder(testFolder);

      final detected = await syncService.detectOrGetDriveFolder();
      expect(detected, testFolder);
      expect(await Directory(testFolder).exists(), isTrue);

      await syncService.clearDriveFolder();
      // After clear, disconnected status is remembered
      expect(await syncService.detectOrGetDriveFolder(), isNull);
    });

    test('Settings persistence: auto-sync and Wi-Fi only toggles', () async {
      expect(await syncService.isAutoSyncEnabled(), isFalse);
      expect(await syncService.isWifiOnly(), isFalse);

      await syncService.setAutoSyncEnabled(true);
      await syncService.setWifiOnly(true);

      expect(await syncService.isAutoSyncEnabled(), isTrue);
      expect(await syncService.isWifiOnly(), isTrue);

      await syncService.setAutoSyncEnabled(false);
      await syncService.setWifiOnly(false);

      expect(await syncService.isAutoSyncEnabled(), isFalse);
      expect(await syncService.isWifiOnly(), isFalse);
    });

    test('Upload without configured folder returns safe error', () async {
      await syncService.clearDriveFolder();
      final res = await syncService.uploadToGoogleDrive();
      expect(res.success, isFalse);
      expect(res.message, contains('กรุณาเลือกโฟลเดอร์'));
    });

    test('Download without configured folder returns safe error', () async {
      await syncService.clearDriveFolder();
      final res = await syncService.downloadAndRestoreFromGoogleDrive();
      expect(res.success, isFalse);
      expect(res.message, contains('กรุณาเลือกโฟลเดอร์'));
    });

    test('Download when file does not exist on Drive returns safe error', () async {
      final syncDir = p.join(tempDir.path, 'GDriveVAULT');
      await syncService.setDriveFolder(syncDir);

      final res = await syncService.downloadAndRestoreFromGoogleDrive();
      expect(res.success, isFalse);
      expect(res.message, contains('ไม่พบไฟล์ฐานข้อมูล'));
    });

    test('Corrupted remote file fails checksum validation and aborts safely', () async {
      final syncDir = p.join(tempDir.path, 'GDriveVAULT');
      await syncService.setDriveFolder(syncDir);

      final remoteDb = File(p.join(syncDir, GoogleDriveSyncService.databaseFileName));
      final metaFile = File(p.join(syncDir, GoogleDriveSyncService.metaFileName));

      await remoteDb.writeAsString('corrupted sqlite bytes');
      await metaFile.writeAsString(jsonEncode({
        'version': 1,
        'app': 'MyFinance VAULT',
        'lastModified': DateTime.now().toIso8601String(),
        'totalAccounts': 2,
        'totalTransactions': 10,
        'sha256': 'fake_checksum_that_does_not_match',
      }));

      final res = await syncService.downloadAndRestoreFromGoogleDrive();
      expect(res.success, isFalse);
      expect(res.message, contains('SHA-256 ไม่ตรงกัน'));
    });

    test('Successful upload creates snapshot and metadata in Google Drive folder', () async {
      final syncDir = p.join(tempDir.path, 'GDriveVAULT');
      await syncService.setDriveFolder(syncDir);

      final localDb = File(p.join(tempDir.path, 'myfinance.sqlite'));
      await localDb.writeAsString('mock sqlite db content');

      final res = await syncService.uploadToGoogleDrive();
      expect(res.success, isTrue);
      expect(res.message, contains('ส่งข้อมูลขึ้น Google Drive สำเร็จ'));

      final targetDb = File(p.join(syncDir, GoogleDriveSyncService.databaseFileName));
      final targetMeta = File(p.join(syncDir, GoogleDriveSyncService.metaFileName));

      expect(await targetDb.exists(), isTrue);
      expect(await targetMeta.exists(), isTrue);

      final metaJson = jsonDecode(await targetMeta.readAsString());
      expect(metaJson['app'], 'MyFinance VAULT');
      expect(metaJson['sha256'], isNotEmpty);
    });

    test('Successful download restores database and creates pre-sync safety backup', () async {
      final syncDir = p.join(tempDir.path, 'GDriveVAULT');
      await syncService.setDriveFolder(syncDir);

      // Local db before download
      final localDb = File(p.join(tempDir.path, 'myfinance.sqlite'));
      await localDb.writeAsString('original local content');

      // Upload first to have valid remote file & metadata
      await syncService.uploadToGoogleDrive();

      // Now download & restore
      final res = await syncService.downloadAndRestoreFromGoogleDrive();
      expect(res.success, isTrue);
      expect(res.message, contains('ดึงข้อมูลและกู้คืนจาก Google Drive สำเร็จ'));
      expect(res.backupFilePath, isNotNull);

      // Check safety backup exists
      final safetyBackupFile = File(res.backupFilePath!);
      expect(await safetyBackupFile.exists(), isTrue);
      expect(await safetyBackupFile.readAsString(), 'original local content');

      // Check pre-sync backups list
      final backups = await syncService.getPreSyncBackups();
      expect(backups.length, 1);
      expect(backups.first.path, res.backupFilePath);
    });

    test('Pending items count tracks modified rows via syncDao', () async {
      final pending = await db.syncDao.countPendingSync(null);
      expect(pending, greaterThan(0));

      final futureDate = DateTime.now().add(const Duration(days: 1));
      final pendingAfterFuture = await db.syncDao.countPendingSync(futureDate);
      expect(pendingAfterFuture, 0);
    });

    test('Status reports correct state when remote metadata exists', () async {
      final syncDir = p.join(tempDir.path, 'GDriveVAULT');
      await syncService.setDriveFolder(syncDir);

      final now = DateTime.now();
      final metaFile = File(p.join(syncDir, GoogleDriveSyncService.metaFileName));
      await metaFile.writeAsString(jsonEncode({
        'version': 1,
        'app': 'MyFinance VAULT',
        'lastModified': now.toIso8601String(),
        'totalAccounts': 3,
        'totalTransactions': 25,
        'sha256': 'abc123hash',
      }));

      final status = await syncService.getStatus();
      expect(status.isConnected, isTrue);
      expect(status.driveFolderPath, syncDir);
      expect(status.remoteTotalAccounts, 3);
      expect(status.remoteTotalTransactions, 25);
      expect(status.hasRemoteUpdate, isTrue);
    });
  });
}
