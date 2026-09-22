import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../database/app_database.dart';
import '../database/daos/accounts_dao.dart';
import '../database/daos/sync_dao.dart';
import '../database/daos/transactions_dao.dart';

class GoogleDriveSyncStatus {
  final bool isConnected;
  final String? driveFolderPath;
  final bool isAutoSync;
  final bool isWifiOnly;
  final DateTime? lastSyncTime;
  final int pendingCount;
  final DateTime? remoteLastModified;
  final bool hasRemoteUpdate;
  final String? lastError;
  final int? remoteTotalTransactions;
  final int? remoteTotalAccounts;

  const GoogleDriveSyncStatus({
    required this.isConnected,
    this.driveFolderPath,
    this.isAutoSync = false,
    this.isWifiOnly = false,
    this.lastSyncTime,
    required this.pendingCount,
    this.remoteLastModified,
    this.hasRemoteUpdate = false,
    this.lastError,
    this.remoteTotalTransactions,
    this.remoteTotalAccounts,
  });
}

class GoogleDriveSyncResult {
  final bool success;
  final String message;
  final int totalAccounts;
  final int totalTransactions;
  final DateTime timestamp;
  final String? backupFilePath;

  const GoogleDriveSyncResult({
    required this.success,
    required this.message,
    this.totalAccounts = 0,
    this.totalTransactions = 0,
    required this.timestamp,
    this.backupFilePath,
  });
}

class PreSyncBackupInfo {
  final String path;
  final String fileName;
  final DateTime createdAt;
  final int sizeBytes;

  const PreSyncBackupInfo({
    required this.path,
    required this.fileName,
    required this.createdAt,
    required this.sizeBytes,
  });
}

class GoogleDriveSyncService {
  final AppDatabase db;
  final TransactionsDao transactionsDao;
  final AccountsDao accountsDao;
  final SyncDao syncDao;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final File? customDbFile;
  final Directory? customDocDir;

  static const _keyFolder = 'gdrive_sync_folder_path';
  static const _keyDisconnected = 'gdrive_sync_disconnected';
  static const _keyAutoSync = 'gdrive_sync_auto_sync';
  static const _keyWifiOnly = 'gdrive_sync_wifi_only';
  static const _keyLastSync = 'gdrive_sync_last_time';

  static const String databaseFileName = 'myfinance_vault.db';
  static const String metaFileName = 'vault_sync_meta.json';

  GoogleDriveSyncService({
    required this.db,
    required this.transactionsDao,
    required this.accountsDao,
    required this.syncDao,
    this.customDbFile,
    this.customDocDir,
  });

  Future<Directory> _getDocumentsDir() async {
    if (customDocDir != null) return customDocDir!;
    return getApplicationDocumentsDirectory();
  }

  /// ค้นหาและตรวจสอบโฟลเดอร์ Google Drive for Desktop ในเครื่อง Windows 11 อัตโนมัติ
  Future<String?> detectOrGetDriveFolder() async {
    // 1. ถ้าผู้ใช้กดตัดการเชื่อมต่อไว้ ไม่ต้อง auto-detect อัตโนมัติ
    final isDisconnected = await _secureStorage.read(key: _keyDisconnected);
    if (isDisconnected == 'true') {
      return null;
    }

    // 2. ตรวจสอบจากค่าที่เคยบันทึกไว้ใน Secure Storage ก่อน
    final savedPath = await _secureStorage.read(key: _keyFolder);
    if (savedPath != null && savedPath.isNotEmpty) {
      final dir = Directory(savedPath);
      if (await dir.exists()) {
        return dir.path;
      }
    }

    // 3. ถ้าเป็น Windows ให้ค้นหาตำแหน่งปกติของ Google Drive for Desktop
    if (!kIsWeb && Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'] ?? '';
      final candidates = [
        r'G:\My Drive\VAULT',
        r'G:\My Drive',
        r'G:\VAULT',
        r'G:\',
        if (userProfile.isNotEmpty) p.join(userProfile, 'Google Drive', 'VAULT'),
        if (userProfile.isNotEmpty) p.join(userProfile, 'Google Drive'),
        if (userProfile.isNotEmpty) p.join(userProfile, 'My Drive', 'VAULT'),
        if (userProfile.isNotEmpty) p.join(userProfile, 'My Drive'),
      ];

      for (final candidate in candidates) {
        final dir = Directory(candidate);
        if (await dir.exists()) {
          String targetPath = candidate;
          if (!candidate.endsWith('VAULT')) {
            final vaultDir = Directory(p.join(candidate, 'VAULT'));
            if (!await vaultDir.exists()) {
              try {
                await vaultDir.create(recursive: true);
                targetPath = vaultDir.path;
              } catch (_) {
                targetPath = candidate;
              }
            } else {
              targetPath = vaultDir.path;
            }
          }
          await setDriveFolder(targetPath);
          return targetPath;
        }
      }
    }

    // 4. บน Android, iOS หรือ Desktop ที่ไม่มี G:\ ให้สร้างโฟลเดอร์ GoogleDrive_Backup ใน Documents ของแอป
    if (!kIsWeb) {
      final docDir = await _getDocumentsDir();
      final backupDir = Directory(p.join(docDir.path, 'GoogleDrive_Backup'));
      if (!await backupDir.exists()) {
        try {
          await backupDir.create(recursive: true);
        } catch (_) {}
      }
      await setDriveFolder(backupDir.path);
      return backupDir.path;
    }

    return null;
  }

  /// บันทึกเส้นทางโฟลเดอร์ Google Drive ที่ผู้ใช้เลือก
  Future<void> setDriveFolder(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await _secureStorage.delete(key: _keyDisconnected);
    await _secureStorage.write(key: _keyFolder, value: dir.path);
  }

  /// ลบการเชื่อมต่อโฟลเดอร์ Google Drive
  Future<void> clearDriveFolder() async {
    await _secureStorage.delete(key: _keyFolder);
    await _secureStorage.write(key: _keyDisconnected, value: 'true');
  }

  Future<bool> isAutoSyncEnabled() async {
    final val = await _secureStorage.read(key: _keyAutoSync);
    return val == 'true';
  }

  Future<void> setAutoSyncEnabled(bool value) async {
    await _secureStorage.write(key: _keyAutoSync, value: value.toString());
  }

  Future<bool> isWifiOnly() async {
    final val = await _secureStorage.read(key: _keyWifiOnly);
    return val == 'true';
  }

  Future<void> setWifiOnly(bool value) async {
    await _secureStorage.write(key: _keyWifiOnly, value: value.toString());
  }

  Future<DateTime?> getLastSyncTime() async {
    final val = await _secureStorage.read(key: _keyLastSync);
    if (val == null) return null;
    return DateTime.tryParse(val);
  }

  Future<void> _setLastSyncTime(DateTime time) async {
    await _secureStorage.write(key: _keyLastSync, value: time.toIso8601String());
  }

  /// ดึงไฟล์ฐานข้อมูล SQLite ปัจจุบันของแอป
  Future<File?> getLocalDatabaseFile() async {
    if (customDbFile != null) return customDbFile;
    final docDir = await _getDocumentsDir();
    final dbFile = File(p.join(docDir.path, 'myfinance.sqlite'));
    if (await dbFile.exists()) {
      return dbFile;
    }
    return null;
  }

  /// ดึงข้อมูลสถานะปัจจุบันของการซิงค์ Google Drive
  Future<GoogleDriveSyncStatus> getStatus() async {
    final folderPath = await detectOrGetDriveFolder();
    final autoSync = await isAutoSyncEnabled();
    final wifiOnly = await isWifiOnly();
    final lastSync = await getLastSyncTime();
    final pending = await syncDao.countPendingSync(lastSync);

    if (folderPath == null) {
      return GoogleDriveSyncStatus(
        isConnected: false,
        isAutoSync: autoSync,
        isWifiOnly: wifiOnly,
        lastSyncTime: lastSync,
        pendingCount: pending,
        lastError: 'ยังไม่ได้เลือกหรือตรวจไม่พบโฟลเดอร์ Google Drive for Desktop',
      );
    }

    // ตรวจสอบ metadata บน Google Drive
    DateTime? remoteModified;
    int? remoteTxCount;
    int? remoteAccCount;
    bool hasRemoteUpdate = false;

    try {
      final metaFile = File(p.join(folderPath, metaFileName));
      if (await metaFile.exists()) {
        final content = await metaFile.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        if (json.containsKey('lastModified')) {
          remoteModified = DateTime.tryParse(json['lastModified'] as String);
          remoteTxCount = json['totalTransactions'] as int?;
          remoteAccCount = json['totalAccounts'] as int?;

          if (remoteModified != null && lastSync != null) {
            hasRemoteUpdate = remoteModified.isAfter(lastSync.add(const Duration(seconds: 2)));
          } else if (remoteModified != null && lastSync == null) {
            hasRemoteUpdate = true;
          }
        }
      }
    } catch (_) {}

    return GoogleDriveSyncStatus(
      isConnected: true,
      driveFolderPath: folderPath,
      isAutoSync: autoSync,
      isWifiOnly: wifiOnly,
      lastSyncTime: lastSync,
      pendingCount: pending,
      remoteLastModified: remoteModified,
      hasRemoteUpdate: hasRemoteUpdate,
      remoteTotalTransactions: remoteTxCount,
      remoteTotalAccounts: remoteAccCount,
    );
  }

  /// อัปโหลดฐานข้อมูลขึ้น Google Drive (สร้าง Snapshot + Metadata ป้องกันไฟล์เสีย)
  Future<GoogleDriveSyncResult> uploadToGoogleDrive() async {
    final now = DateTime.now();
    final folderPath = await detectOrGetDriveFolder();
    if (folderPath == null) {
      return GoogleDriveSyncResult(
        success: false,
        message: 'กรุณาเลือกโฟลเดอร์ Google Drive for Desktop ก่อนทำการซิงค์',
        timestamp: now,
      );
    }

    final localDb = await getLocalDatabaseFile();
    if (localDb == null || !await localDb.exists()) {
      return GoogleDriveSyncResult(
        success: false,
        message: 'ไม่พบไฟล์ฐานข้อมูลในเครื่อง',
        timestamp: now,
      );
    }

    // ตรวจสอบเงื่อนไข Wi-Fi
    if (await isWifiOnly()) {
      try {
        final connectivity = await Connectivity().checkConnectivity();
        if (!connectivity.contains(ConnectivityResult.wifi)) {
          return GoogleDriveSyncResult(
            success: false,
            message: 'ตั้งค่าให้ซิงค์ผ่าน Wi-Fi เท่านั้น (ขณะนี้ไม่ได้เชื่อมต่อ Wi-Fi)',
            timestamp: now,
          );
        }
      } catch (_) {}
    }

    try {
      // 1. ตรวจนับข้อมูลสถิติ
      final accounts = await accountsDao.getAllAccounts();
      final transactions = await transactionsDao.getAllTransactions();

      // 2. ปล่อย WAL Checkpoint เพื่อให้ข้อมูลทั้งหมดลงสู่ไฟล์หลักอย่างสมบูรณ์
      try {
        await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
      } catch (_) {}

      // 3. คำนวณ SHA-256 Checksum ของฐานข้อมูล
      final dbBytes = await localDb.readAsBytes();
      final sha256Hash = sha256.convert(dbBytes).toString();

      // 4. เขียนไฟล์ฐานข้อมูลไปยัง Google Drive ชั่วคราวแล้วเปลี่ยนชื่อ (Atomic Write)
      final targetDbFile = File(p.join(folderPath, databaseFileName));
      final tempTargetDb = File(p.join(folderPath, '$databaseFileName.tmp'));
      await tempTargetDb.writeAsBytes(dbBytes, flush: true);
      if (await targetDbFile.exists()) {
        await targetDbFile.delete();
      }
      await tempTargetDb.rename(targetDbFile.path);

      // 5. เขียนไฟล์ Metadata
      final metaData = {
        'version': 1,
        'app': 'MyFinance VAULT',
        'platform': Platform.operatingSystem,
        'lastModified': now.toIso8601String(),
        'totalAccounts': accounts.length,
        'totalTransactions': transactions.length,
        'sha256': sha256Hash,
        'fileSizeBytes': dbBytes.length,
      };

      final metaFile = File(p.join(folderPath, metaFileName));
      final tempMeta = File(p.join(folderPath, '$metaFileName.tmp'));
      await tempMeta.writeAsString(jsonEncode(metaData), flush: true);
      if (await metaFile.exists()) {
        await metaFile.delete();
      }
      await tempMeta.rename(metaFile.path);

      // 6. อัปเดตเวลาซิงค์ล่าสุด
      await _setLastSyncTime(now);

      return GoogleDriveSyncResult(
        success: true,
        message: 'ส่งข้อมูลขึ้น Google Drive สำเร็จเรียบร้อย (${accounts.length} บัญชี, ${transactions.length} รายการ)',
        totalAccounts: accounts.length,
        totalTransactions: transactions.length,
        timestamp: now,
      );
    } catch (e) {
      return GoogleDriveSyncResult(
        success: false,
        message: 'เกิดข้อผิดพลาดในการอัปโหลด: $e',
        timestamp: now,
      );
    }
  }

  /// ดาวน์โหลดและกู้คืนฐานข้อมูลจาก Google Drive (พร้อมสร้างไฟล์สำรองฉุกเฉินเสมอ)
  Future<GoogleDriveSyncResult> downloadAndRestoreFromGoogleDrive() async {
    final now = DateTime.now();
    final folderPath = await detectOrGetDriveFolder();
    if (folderPath == null) {
      return GoogleDriveSyncResult(
        success: false,
        message: 'กรุณาเลือกโฟลเดอร์ Google Drive for Desktop ก่อนทำการซิงค์',
        timestamp: now,
      );
    }

    final remoteDbFile = File(p.join(folderPath, databaseFileName));
    final metaFile = File(p.join(folderPath, metaFileName));

    if (!await remoteDbFile.exists()) {
      return GoogleDriveSyncResult(
        success: false,
        message: 'ไม่พบไฟล์ฐานข้อมูล ($databaseFileName) ในโฟลเดอร์ Google Drive',
        timestamp: now,
      );
    }

    try {
      // 1. ตรวจสอบความถูกต้องของ Checksum จาก Metadata
      String? expectedHash;
      int remoteAcc = 0;
      int remoteTx = 0;
      DateTime? remoteTime;

      if (await metaFile.exists()) {
        final metaJson = jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
        expectedHash = metaJson['sha256'] as String?;
        remoteAcc = metaJson['totalAccounts'] as int? ?? 0;
        remoteTx = metaJson['totalTransactions'] as int? ?? 0;
        if (metaJson['lastModified'] != null) {
          remoteTime = DateTime.tryParse(metaJson['lastModified'] as String);
        }
      }

      final remoteBytes = await remoteDbFile.readAsBytes();
      if (expectedHash != null) {
        final actualHash = sha256.convert(remoteBytes).toString();
        if (actualHash != expectedHash) {
          return GoogleDriveSyncResult(
            success: false,
            message: 'ไฟล์บน Google Drive เสียหายหรือกำลังถูกเขียน (SHA-256 ไม่ตรงกัน) เพื่อความปลอดภัยจึงยกเลิกการกู้คืน',
            timestamp: now,
          );
        }
      }

      // 2. ระบบความปลอดภัย: สำรองไฟล์เดิมในเครื่องไว้เสมอ (Safety Pre-Sync Backup)
      final localDb = await getLocalDatabaseFile();
      String? backupPath;
      if (localDb != null && await localDb.exists()) {
        final docDir = await _getDocumentsDir();
        final backupDir = Directory(p.join(docDir.path, 'backups'));
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }

        final timeStr = DateFormat('yyyyMMdd_HHmmss').format(now);
        final safetyBackup = File(p.join(backupDir.path, 'backup_before_sync_$timeStr.db'));
        await localDb.copy(safetyBackup.path);
        backupPath = safetyBackup.path;
      }

      // 3. นำไฟล์จาก Google Drive เข้ามาแทนที่ฐานข้อมูลในเครื่อง
      if (localDb != null) {
        try {
          await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
        } catch (_) {}

        await remoteDbFile.copy(localDb.path);

        final walFile = File('${localDb.path}-wal');
        final shmFile = File('${localDb.path}-shm');
        if (await walFile.exists()) await walFile.delete();
        if (await shmFile.exists()) await shmFile.delete();
      }

      // 4. บันทึกเวลาซิงค์
      await _setLastSyncTime(remoteTime ?? now);

      return GoogleDriveSyncResult(
        success: true,
        message: 'ดึงข้อมูลและกู้คืนจาก Google Drive สำเร็จเรียบร้อย ($remoteAcc บัญชี, $remoteTx รายการ)',
        totalAccounts: remoteAcc,
        totalTransactions: remoteTx,
        timestamp: now,
        backupFilePath: backupPath,
      );
    } catch (e) {
      return GoogleDriveSyncResult(
        success: false,
        message: 'เกิดข้อผิดพลาดในการกู้คืนข้อมูล: $e',
        timestamp: now,
      );
    }
  }

  /// เรียกดูรายการไฟล์สำรองฉุกเฉินก่อนซิงค์ (Safety Pre-Sync Backups)
  Future<List<PreSyncBackupInfo>> getPreSyncBackups() async {
    final docDir = await _getDocumentsDir();
    final backupDir = Directory(p.join(docDir.path, 'backups'));
    if (!await backupDir.exists()) {
      return [];
    }

    final files = await backupDir
        .list()
        .where((e) => e is File && e.path.contains('backup_before_sync_'))
        .toList();
    final List<PreSyncBackupInfo> results = [];

    for (final entity in files) {
      final file = entity as File;
      final stat = await file.stat();
      results.add(
        PreSyncBackupInfo(
          path: file.path,
          fileName: p.basename(file.path),
          createdAt: stat.modified,
          sizeBytes: stat.size,
        ),
      );
    }

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  /// กู้คืนข้อมูลจากไฟล์สำรองฉุกเฉิน
  Future<bool> restoreFromPreSyncBackup(String backupFilePath) async {
    final backupFile = File(backupFilePath);
    if (!await backupFile.exists()) return false;

    final localDb = await getLocalDatabaseFile();
    if (localDb == null) return false;

    try {
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
    } catch (_) {}

    await backupFile.copy(localDb.path);

    final walFile = File('${localDb.path}-wal');
    final shmFile = File('${localDb.path}-shm');
    if (await walFile.exists()) await walFile.delete();
    if (await shmFile.exists()) await shmFile.delete();

    return true;
  }
}
