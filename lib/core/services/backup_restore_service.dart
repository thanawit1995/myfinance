import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'backup_crypto_helper.dart';
import 'backup_inspect/backup_inspector.dart';
import 'web_db_helper/web_db_helper.dart';
import 'sqlite_reader/sqlite_reader.dart';

export 'backup_inspect/backup_inspector.dart';

class SafetyBackupItem {
  final String path;
  final String fileName;
  final DateTime createdAt;
  final int sizeBytes;

  const SafetyBackupItem({
    required this.path,
    required this.fileName,
    required this.createdAt,
    required this.sizeBytes,
  });
}

class RollingBackupItem {
  final String path;
  final String fileName;
  final DateTime createdAt;
  final int sizeBytes;
  final int versionOrder; // 1 = latest, 2 = previous, 3 = older

  const RollingBackupItem({
    required this.path,
    required this.fileName,
    required this.createdAt,
    required this.sizeBytes,
    required this.versionOrder,
  });
}

final backupRestoreServiceProvider = Provider<BackupRestoreService>((ref) {
  final db = ref.watch(databaseProvider);
  final service = BackupRestoreService(db: db);
  ref.onDispose(() => service.dispose());
  return service;
});

class BackupRestoreService {
  final AppDatabase db;
  StreamSubscription? _txSubscription;
  Timer? _autoBackupDebounceTimer;

  static const String designatedFolderKey = 'designated_backup_folder';
  static const String _backupMasterKeyName = 'backup_encryption_master_key';
  final FlutterSecureStorage _secureStorage;

  BackupRestoreService({required this.db, FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    _initAutoBackupListener();
  }

  Future<String> getOrCreateMasterBackupKey() async {
    try {
      final existingKey = await _secureStorage.read(key: _backupMasterKeyName);
      if (existingKey != null && existingKey.isNotEmpty) {
        return existingKey;
      }
      final newKey = base64UrlEncode(List<int>.generate(32, (_) => Random.secure().nextInt(256)));
      await _secureStorage.write(key: _backupMasterKeyName, value: newKey);
      return newKey;
    } catch (_) {
      return 'MyFinance_Vault_EncKey_Default';
    }
  }

  void _initAutoBackupListener() {
    if (kIsWeb) return;
    try {
      db.transactionsDao.onLedgerModified = triggerAutoBackup;
      _txSubscription = db.select(db.transactions).watch().skip(1).listen((_) {
        triggerAutoBackup();
      });
    } catch (_) {}
  }

  void dispose() {
    _autoBackupDebounceTimer?.cancel();
    _txSubscription?.cancel();
    try {
      if (db.transactionsDao.onLedgerModified == triggerAutoBackup) {
        db.transactionsDao.onLedgerModified = null;
      }
    } catch (_) {}
  }

  /// ค้นหาไฟล์ฐานข้อมูล SQLite ปัจจุบันของแอปในเครื่อง
  Future<File?> getLocalDatabaseFile() async {
    if (kIsWeb) return null;

    final candidateNames = [
      'myfinance_vault.sqlite',
      'myfinance.sqlite',
      'myfinance_vault.db',
      'myfinance.db',
    ];

    final searchDirs = <Directory>[];
    try {
      searchDirs.add(await getApplicationDocumentsDirectory());
    } catch (_) {}

    try {
      searchDirs.add(await getApplicationSupportDirectory());
    } catch (_) {}

    final extraDirs = <Directory>[];
    for (final d in searchDirs) {
      try {
        final parent = d.parent;
        extraDirs.add(Directory(p.join(parent.path, 'databases')));
        extraDirs.add(Directory(p.join(parent.path, 'app_flutter')));
        extraDirs.add(Directory(p.join(parent.path, 'files')));
      } catch (_) {}
    }
    searchDirs.addAll(extraDirs);

    for (final dir in searchDirs) {
      for (final name in candidateNames) {
        final f = File(p.join(dir.path, name));
        if (await f.exists()) {
          return f;
        }
      }
    }

    // Default fallback
    try {
      final docDir = await getApplicationDocumentsDirectory();
      return File(p.join(docDir.path, 'myfinance_vault.sqlite'));
    } catch (_) {
      return null;
    }
  }

  /// ตรวจสอบและดึงข้อมูลสรุปจากไฟล์สำรอง (.db) ก่อนกดยืนยันกู้คืน
  Future<BackupInspectionResult> inspectBackupFile(
    String filePath, {
    Uint8List? bytes,
    String? name,
    String? password,
  }) async {
    // 1. ถ้ามีรหัสผ่านส่งมา ให้ลองถอดด้วยรหัสผ่านนั้น
    if (password != null && password.isNotEmpty) {
      return inspectSqliteDatabaseFile(filePath, bytes: bytes, name: name, password: password);
    }

    // 2. ถ้าไม่ได้ส่งรหัสผ่าน ให้ลองถอดด้วย Master Key ประจำเครื่องก่อน (กรณีไฟล์แบ็กอัปในเครื่องตัวเอง)
    final masterKey = await getOrCreateMasterBackupKey();
    final firstTry = await inspectSqliteDatabaseFile(filePath, bytes: bytes, name: name, password: masterKey);
    if (!firstTry.requiresPassword) {
      return firstTry;
    }

    // 3. ถ้า master key ถอดไม่ได้ (เช่น มาจากเครื่องอื่นที่มีรหัสผ่าน) ให้ส่งผลตรวจว่า requiresPassword = true
    return inspectSqliteDatabaseFile(filePath, bytes: bytes, name: name, password: null);
  }

  /// ส่งออกและเปิดแชร์ไฟล์สำรอง (.db) แบบเข้ารหัส AES-256
  /// - บนมือถือ / Webapp บนมือถือ: เปิด Share sheet (บันทึกลง Drive, ส่งเข้า Line, บันทึกลงเครื่อง)
  /// - บน Windows: เปิด FilePicker ให้เลือกที่บันทึก
  /// - บน Web: ถ้าแชร์ไม่ได้ จะดาวน์โหลดไฟล์ .db ลงเบราว์เซอร์อัตโนมัติ
  /// ส่งออกและเปิดแชร์ไฟล์สำรอง (.db)
  /// - หากไม่ระบุรหัสผ่าน: ส่งออกเป็น SQLite ไบนารีมาตรฐาน เปิดบนมือถือ/คอมเครื่องอื่นได้ทันที 100%
  /// - หากระบุรหัสผ่าน: เข้ารหัสระดับ AES-256 (MYFINANCE_ENC_V1)
  Future<String?> exportAndShareBackup({bool isThai = true, String? customPassword}) async {
    final nowStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final exportFileName = 'myfinance_backup_$nowStr.db';
    final trimmedPassword = customPassword != null && customPassword.trim().isNotEmpty ? customPassword.trim() : null;
    final hasPassword = trimmedPassword != null;

    // Flush WAL to make sure database is fully checkpointed to the main file (both Web and Native)
    try {
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
    } catch (_) {}

    if (kIsWeb) {
      Uint8List? bytes;
      try {
        bytes = await dumpDriftDatabaseToSqliteBytes(db);
      } catch (e) {
        debugPrint('dumpDriftDatabaseToSqliteBytes error: $e');
      }
      if (bytes == null || bytes.isEmpty) {
        bytes = await exportWebDatabase();
      }
      if (bytes == null || bytes.isEmpty) {
        throw Exception(isThai ? 'ไม่พบข้อมูลในเบราว์เซอร์' : 'No database in browser storage');
      }

      // เข้ารหัสเฉพาะเมื่อผู้ใช้ตั้งรหัสผ่านเอง หากไม่ตั้งรหัสให้ส่งออกเป็น SQLite แท้
      final bytesToExport = trimmedPassword != null
          ? BackupCryptoHelper.encryptDatabase(bytes, trimmedPassword)
          : bytes;

      final shareFileName = hasPassword ? 'myfinance_backup_$nowStr.txt' : exportFileName;
      final xFile = XFile.fromData(
        bytesToExport,
        name: shareFileName,
        mimeType: hasPassword ? 'text/plain' : 'application/octet-stream',
      );

      try {
        await Share.shareXFiles(
          [xFile],
          text: isThai ? 'ไฟล์สำรองข้อมูล MyFinance ($nowStr)' : 'MyFinance Backup ($nowStr)',
        );
        return shareFileName;
      } catch (_) {
        downloadFileWeb(bytesToExport, exportFileName);
        return exportFileName;
      }
    }

    final localDb = await getLocalDatabaseFile();
    if (localDb == null || !await localDb.exists()) {
      throw Exception(isThai ? 'ไม่พบไฟล์ฐานข้อมูลในเครื่อง' : 'Local database file not found');
    }

    final rawBytes = await localDb.readAsBytes();
    final bytesToExport = trimmedPassword != null
        ? BackupCryptoHelper.encryptDatabase(rawBytes, trimmedPassword)
        : rawBytes;

    if (Platform.isWindows) {
      // Windows Desktop: Save File dialog
      final destinationPath = await FilePicker.platform.saveFile(
        dialogTitle: isThai ? 'เลือกตำแหน่งที่ต้องการบันทึกไฟล์สำรอง' : 'Save Backup File',
        fileName: exportFileName,
        type: FileType.custom,
        allowedExtensions: ['db', 'sqlite'],
      );

      if (destinationPath != null && destinationPath.isNotEmpty) {
        final destFile = File(destinationPath);
        await destFile.writeAsBytes(bytesToExport, flush: true);
        return destFile.path;
      }
      return null;
    } else {
      // Mobile (Android / iOS): Copy encrypted data to temp & Share Sheet
      final tempDir = await getTemporaryDirectory();
      final shareFile = File(p.join(tempDir.path, exportFileName));
      await shareFile.writeAsBytes(bytesToExport, flush: true);

      final xFile = XFile(
        shareFile.path,
        mimeType: 'application/octet-stream',
        name: exportFileName,
      );

      final result = await Share.shareXFiles(
        [xFile],
        text: isThai ? 'ไฟล์สำรองข้อมูล MyFinance ($nowStr)' : 'MyFinance Backup ($nowStr)',
      );

      return result.status == ShareResultStatus.success ? shareFile.path : shareFile.path;
    }
  }

  /// ดาวน์โหลดไฟล์สำรอง (.db) ตรงๆ สู่เครื่อง (สำหรับ Web)
  Future<String?> downloadBackupDirectly({bool isThai = true, String? customPassword}) async {
    final nowStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final exportFileName = 'myfinance_backup_$nowStr.db';
    final trimmedPassword = customPassword != null && customPassword.trim().isNotEmpty ? customPassword.trim() : null;

    // Flush WAL to make sure database is fully checkpointed to the main file (both Web and Native)
    try {
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
    } catch (_) {}

    if (kIsWeb) {
      Uint8List? bytes;
      try {
        bytes = await dumpDriftDatabaseToSqliteBytes(db);
      } catch (e) {
        debugPrint('dumpDriftDatabaseToSqliteBytes error: $e');
      }
      if (bytes == null || bytes.isEmpty) {
        bytes = await exportWebDatabase();
      }
      if (bytes == null || bytes.isEmpty) {
        throw Exception(isThai ? 'ไม่พบข้อมูลในเบราว์เซอร์' : 'No database in browser storage');
      }
      final bytesToExport = trimmedPassword != null
          ? BackupCryptoHelper.encryptDatabase(bytes, trimmedPassword)
          : bytes;
      downloadFileWeb(bytesToExport, exportFileName);
      return exportFileName;
    } else {
      return exportAndShareBackup(isThai: isThai, customPassword: customPassword);
    }
  }

  /// กู้คืนฐานข้อมูลจากไฟล์ พร้อม Live Drift Table Injection
  Future<bool> restoreDatabase({
    String? filePath,
    Uint8List? bytes,
    String? password,
    bool isThai = true,
  }) async {
    Uint8List? rawBytes = bytes;
    if (rawBytes == null && filePath != null && filePath.isNotEmpty) {
      final sourceFile = File(filePath);
      if (!await sourceFile.exists()) return false;
      rawBytes = await sourceFile.readAsBytes();
    }

    if (rawBytes == null || rawBytes.isEmpty) return false;

    // ถ้าเป็นไฟล์ที่ถูกเข้ารหัส ให้ถอดรหัสก่อนกู้คืน
    Uint8List dbBytesToWrite = rawBytes;
    if (BackupCryptoHelper.isEncrypted(rawBytes)) {
      bool decrypted = false;
      if (password != null && password.isNotEmpty) {
        try {
          dbBytesToWrite = BackupCryptoHelper.decryptDatabase(rawBytes, password);
          decrypted = true;
        } catch (_) {}
      }
      if (!decrypted) {
        try {
          final masterKey = await getOrCreateMasterBackupKey();
          dbBytesToWrite = BackupCryptoHelper.decryptDatabase(rawBytes, masterKey);
          decrypted = true;
        } catch (_) {}
      }

      if (!decrypted) {
        throw Exception(isThai
            ? 'รหัสผ่านไฟล์สำรองข้อมูลไม่ถูกต้อง หรือไฟล์ถูกล็อกเฉพาะเครื่องเดิม'
            : 'Invalid backup password or file locked to another device');
      }
    }

    // 1. Live Data Injection: นำข้อมูลทุกตารางเข้า Drift Database สดๆ ทันที
    try {
      final backupData = await readSqliteBackupData(dbBytesToWrite);
      await _applyBackupDataToDrift(backupData);
    } catch (e) {
      debugPrint('Live injection note: $e');
    }

    // 2. Persist to storage
    if (kIsWeb) {
      final ok = await restoreWebDatabase(dbBytesToWrite);
      return ok;
    }

    final localDb = await getLocalDatabaseFile();
    if (localDb == null) return true;

    // 1. สร้าง Safety Backup อัตโนมัติกันเหนียว
    await _createSafetyBackup(localDb);

    // 2. ปิดหรือ flush การเชื่อมต่อ
    try {
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
    } catch (_) {}

    // 3. เขียนทับไฟล์ฐานข้อมูล
    await localDb.writeAsBytes(dbBytesToWrite, flush: true);

    // 4. ลบไฟล์ -wal และ -shm เก่าที่อาจค้างอยู่
    try {
      final walFile = File('${localDb.path}-wal');
      final shmFile = File('${localDb.path}-shm');
      if (await walFile.exists()) await walFile.delete();
      if (await shmFile.exists()) await shmFile.delete();
    } catch (_) {}

    return true;
  }

  /// เขียนทับข้อมูลทุกตารางลง Drift DB ที่กำลังรันอยู่สดๆ เพื่อให้อัปเดตทันที
  Future<void> _applyBackupDataToDrift(SqliteBackupData data) async {
    try {
      await db.customStatement('PRAGMA foreign_keys = OFF;');
      Future<void> insertTableRows(String table, List<Map<String, dynamic>> rows) async {
        if (rows.isEmpty) return;
        for (final row in rows) {
          final cols = row.keys.map((c) => '"$c"').join(', ');
          final placeholders = row.keys.map((_) => '?').join(', ');
          final values = row.values.toList();
          await db.customStatement(
            'INSERT OR REPLACE INTO "$table" ($cols) VALUES ($placeholders);',
            values,
          );
        }
      }

      await db.transaction(() async {
        if (data.allTables.isNotEmpty) {
          final skipTables = {'sqlite_sequence', 'android_metadata'};
          for (final entry in data.allTables.entries) {
            final table = entry.key;
            if (skipTables.contains(table) || table.startsWith('sqlite_') || table.startsWith('_drift_')) {
              continue;
            }
            await db.customStatement('DELETE FROM "$table";');
            final rows = entry.value;
            if (rows.isNotEmpty) {
              await insertTableRows(table, rows);
            }
          }
        } else {
          if (data.accounts.isNotEmpty) {
            await db.customStatement('DELETE FROM accounts;');
            await insertTableRows('accounts', data.accounts);
          }
          if (data.categories.isNotEmpty) {
            await db.customStatement('DELETE FROM categories;');
            await insertTableRows('categories', data.categories);
          }
          if (data.transactions.isNotEmpty) {
            await db.customStatement('DELETE FROM transactions;');
            await insertTableRows('transactions', data.transactions);
          }
          if (data.assets.isNotEmpty) {
            await db.customStatement('DELETE FROM assets;');
            await insertTableRows('assets', data.assets);
          }
          if (data.insurancePolicies.isNotEmpty) {
            await db.customStatement('DELETE FROM insurance_policies;');
            await insertTableRows('insurance_policies', data.insurancePolicies);
          }
          if (data.liabilities.isNotEmpty) {
            await db.customStatement('DELETE FROM liabilities;');
            await insertTableRows('liabilities', data.liabilities);
          }
          if (data.budgets.isNotEmpty) {
            await db.customStatement('DELETE FROM budgets;');
            await insertTableRows('budgets', data.budgets);
          }
          if (data.recurringRules.isNotEmpty) {
            await db.customStatement('DELETE FROM recurring_rules;');
            await insertTableRows('recurring_rules', data.recurringRules);
          }
          if (data.projects.isNotEmpty) {
            await db.customStatement('DELETE FROM projects;');
            await insertTableRows('projects', data.projects);
          }
          if (data.creditCardInstallments.isNotEmpty) {
            await db.customStatement('DELETE FROM credit_card_installments;');
            await insertTableRows('credit_card_installments', data.creditCardInstallments);
          }
          if (data.investmentLots.isNotEmpty) {
            await db.customStatement('DELETE FROM investment_lots;');
            await insertTableRows('investment_lots', data.investmentLots);
          }
          if (data.investmentSales.isNotEmpty) {
            await db.customStatement('DELETE FROM investment_sales;');
            await insertTableRows('investment_sales', data.investmentSales);
          }
          if (data.investmentIncomes.isNotEmpty) {
            await db.customStatement('DELETE FROM investment_incomes;');
            await insertTableRows('investment_incomes', data.investmentIncomes);
          }
          if (data.taxDeductions.isNotEmpty) {
            await db.customStatement('DELETE FROM tax_deductions;');
            await insertTableRows('tax_deductions', data.taxDeductions);
          }
        }
      });
    } catch (e) {
      debugPrint('Error applying backup data to drift: $e');
    } finally {
      try {
        await db.customStatement('PRAGMA foreign_keys = ON;');
        await db.customStatement('PRAGMA user_version = ${db.schemaVersion};');
      } catch (_) {}
    }

    try {
      db.transactionsDao.onLedgerModified?.call();
    } catch (_) {}
  }

  /// สร้างไฟล์สำรองฉุกเฉิน (Safety Backup) ก่อนเขียนทับ
  Future<void> _createSafetyBackup(File localDb) async {
    if (!await localDb.exists()) return;
    try {
      final dir = await _getSafetyBackupDir();
      final nowStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final backupFile = File(p.join(dir.path, 'safety_backup_$nowStr.db'));
      await localDb.copy(backupFile.path);

      // Clean up old safety backups, keep last 10
      final allFiles = dir.listSync().whereType<File>().toList();
      if (allFiles.length > 10) {
        allFiles.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
        for (var i = 0; i < allFiles.length - 10; i++) {
          try {
            await allFiles[i].delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  Future<Directory> _getSafetyBackupDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    final safetyDir = Directory(p.join(docDir.path, 'safety_backups'));
    if (!await safetyDir.exists()) {
      await safetyDir.create(recursive: true);
    }
    return safetyDir;
  }

  /// ดึงรายการไฟล์สำรองฉุกเฉินทั้งหมด
  Future<List<SafetyBackupItem>> getSafetyBackups() async {
    if (kIsWeb) return [];
    try {
      final dir = await _getSafetyBackupDir();
      final files = dir.listSync().whereType<File>().toList();
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      return files.map((f) {
        return SafetyBackupItem(
          path: f.path,
          fileName: p.basename(f.path),
          createdAt: f.lastModifiedSync(),
          sizeBytes: f.lengthSync(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// ย้อนกลับไปใช้ไฟล์สำรองฉุกเฉิน
  Future<bool> rollbackSafetyBackup(String backupFilePath) async {
    return restoreDatabase(filePath: backupFilePath);
  }

  /// อ่านโฟลเดอร์สำหรับสำรองข้อมูลที่ผู้ใช้ตั้งค่าไว้
  Future<String?> getDesignatedBackupDirectory() async {
    if (kIsWeb) return null;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(designatedFolderKey);
    if (path == null || path.trim().isEmpty) return null;
    final dir = Directory(path);
    if (!await dir.exists()) {
      try {
        await dir.create(recursive: true);
      } catch (_) {
        return null;
      }
    }
    return dir.path;
  }

  /// กำหนดและจดจำโฟลเดอร์สำหรับสำรองข้อมูลอัตโนมัติ
  Future<String> setDesignatedBackupDirectory(String folderPath) async {
    final prefs = await SharedPreferences.getInstance();
    var targetDir = Directory(folderPath);
    final baseName = p.basename(targetDir.path).toLowerCase();
    if (!baseName.contains('myfinance')) {
      targetDir = Directory(p.join(targetDir.path, 'MyFinance_Backup'));
    }
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    await prefs.setString(designatedFolderKey, targetDir.path);
    // ทำการสำรองข้อมูลลงโฟลเดอร์นี้ทันที 1 เวอร์ชั่น
    await saveRollingBackup(customFolderPath: targetDir.path);
    return targetDir.path;
  }

  /// ล้างการตั้งค่าโฟลเดอร์สำรองข้อมูล
  Future<void> clearDesignatedBackupDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(designatedFolderKey);
  }

  /// ทำการสำรองข้อมูลลงโฟลเดอร์ปลายทางที่กำหนด และดูแลให้มี 3 เวอร์ชั่นล่าสุดเสมอ
  Future<String?> saveRollingBackup({String? customFolderPath, File? customSourceDb}) async {
    if (kIsWeb) return null;

    final folderPath = customFolderPath ?? await getDesignatedBackupDirectory();
    if (folderPath == null || folderPath.isEmpty) return null;

    final targetDir = Directory(folderPath);
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    // Flush WAL checkpoint เพื่อให้ข้อมูลล่าสุดลงไฟล์หลักครบ 100%
    try {
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
    } catch (_) {}

    final localDb = customSourceDb ?? await getLocalDatabaseFile();
    if (localDb == null || !await localDb.exists()) return null;

    final nowStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    var backupFileName = 'myfinance_backup_$nowStr.db';
    var targetFile = File(p.join(targetDir.path, backupFileName));
    if (await targetFile.exists()) {
      backupFileName = 'myfinance_backup_${nowStr}_${DateTime.now().millisecond}.db';
      targetFile = File(p.join(targetDir.path, backupFileName));
    }

    final rawBytes = await localDb.readAsBytes();
    final masterKey = await getOrCreateMasterBackupKey();
    final encryptedBytes = BackupCryptoHelper.encryptDatabase(rawBytes, masterKey);
    await targetFile.writeAsBytes(encryptedBytes, flush: true);

    // ดูแลรักษาไฟล์สำรองให้มีเพียง 3 เวอร์ชั่นล่าสุด
    await _maintainRollingVersions(targetDir, keepCount: 3);

    return targetFile.path;
  }

  Future<void> _maintainRollingVersions(Directory dir, {int keepCount = 3}) async {
    try {
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) {
            final name = p.basename(f.path).toLowerCase();
            return name.startsWith('myfinance_backup_') && name.endsWith('.db');
          })
          .toList();

      if (files.length <= keepCount) return;

      // เรียงจากใหม่ไปเก่า (เวลาแก้ไขล่าสุดมาก่อน)
      files.sort((a, b) {
        final cmp = b.lastModifiedSync().compareTo(a.lastModifiedSync());
        if (cmp != 0) return cmp;
        return b.path.compareTo(a.path);
      });

      // ลบไฟล์ที่เกินโควตา 3 เวอร์ชั่นออก
      for (var i = keepCount; i < files.length; i++) {
        try {
          await files[i].delete();
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// ดึงรายการไฟล์สำรอง 3 เวอร์ชั่นล่าสุดในโฟลเดอร์หลัก
  Future<List<RollingBackupItem>> getRollingBackupsInDesignatedDirectory({String? customFolderPath}) async {
    if (kIsWeb) return [];

    final folderPath = customFolderPath ?? await getDesignatedBackupDirectory();
    if (folderPath == null || folderPath.isEmpty) return [];

    final dir = Directory(folderPath);
    if (!await dir.exists()) return [];

    try {
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) {
            final name = p.basename(f.path).toLowerCase();
            return (name.startsWith('myfinance_backup_') || name.startsWith('myfinance')) &&
                (name.endsWith('.db') || name.endsWith('.sqlite'));
          })
          .toList();

      files.sort((a, b) {
        final cmp = b.lastModifiedSync().compareTo(a.lastModifiedSync());
        if (cmp != 0) return cmp;
        return b.path.compareTo(a.path);
      });

      final limited = files.take(3).toList();
      return List.generate(limited.length, (index) {
        final f = limited[index];
        return RollingBackupItem(
          path: f.path,
          fileName: p.basename(f.path),
          createdAt: f.lastModifiedSync(),
          sizeBytes: f.lengthSync(),
          versionOrder: index + 1,
        );
      });
    } catch (_) {
      return [];
    }
  }

  /// สั่งสำรองข้อมูลอัตโนมัติ (พร้อม Debounce 1.5 วินาที เพื่อประสิทธิภาพ)
  void triggerAutoBackup() {
    if (kIsWeb) return;
    _autoBackupDebounceTimer?.cancel();
    _autoBackupDebounceTimer = Timer(const Duration(milliseconds: 1500), () async {
      try {
        await saveRollingBackup();
      } catch (e) {
        debugPrint('Auto-backup error: $e');
      }
    });
  }
}
