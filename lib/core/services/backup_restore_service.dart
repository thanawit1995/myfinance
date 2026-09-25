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

import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'backup_inspect/backup_inspector.dart';
import 'web_db_helper/web_db_helper.dart';

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

  BackupRestoreService({required this.db}) {
    _initAutoBackupListener();
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
  Future<BackupInspectionResult> inspectBackupFile(String filePath, {Uint8List? bytes, String? name}) async {
    return inspectSqliteDatabaseFile(filePath, bytes: bytes, name: name);
  }

  /// ส่งออกและเปิดแชร์ไฟล์สำรอง (.db)
  /// - บนมือถือ: เปิด Share sheet (บันทึกลง Drive, ส่งเข้า Line, บันทึกลงเครื่อง)
  /// - บน Windows: เปิด FilePicker ให้เลือกที่บันทึก
  /// - บน Web: ดาวน์โหลดไฟล์ .db ลงเบราว์เซอร์
  Future<String?> exportAndShareBackup({bool isThai = true}) async {
    final nowStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final exportFileName = 'myfinance_backup_$nowStr.db';

    if (kIsWeb) {
      final bytes = await exportWebDatabase();
      if (bytes == null || bytes.isEmpty) {
        throw Exception(isThai ? 'ไม่พบข้อมูลในเบราว์เซอร์' : 'No database in browser storage');
      }
      downloadFileWeb(bytes, exportFileName);
      return exportFileName;
    }

    // Flush WAL to make sure database is fully checkpointed to the main file
    try {
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
    } catch (_) {}

    final localDb = await getLocalDatabaseFile();
    if (localDb == null || !await localDb.exists()) {
      throw Exception(isThai ? 'ไม่พบไฟล์ฐานข้อมูลในเครื่อง' : 'Local database file not found');
    }

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
        await localDb.copy(destFile.path);
        return destFile.path;
      }
      return null;
    } else {
      // Mobile (Android / iOS): Copy to temp & Share Sheet
      final tempDir = await getTemporaryDirectory();
      final shareFile = File(p.join(tempDir.path, exportFileName));
      await localDb.copy(shareFile.path);

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

  /// กู้คืนฐานข้อมูลจากไฟล์ พร้อมสร้าง Safety Backup อัตโนมัติก่อนเขียนทับเสมอ
  Future<bool> restoreDatabase({String? filePath, Uint8List? bytes, bool isThai = true}) async {
    if (kIsWeb) {
      if (bytes == null || bytes.isEmpty) return false;
      final ok = await restoreWebDatabase(bytes);
      if (ok) {
        Future.delayed(const Duration(milliseconds: 1000), reloadWebPage);
      }
      return ok;
    }

    final localDb = await getLocalDatabaseFile();
    if (localDb == null) return false;

    // 1. สร้าง Safety Backup อัตโนมัติกันเหนียว
    await _createSafetyBackup(localDb);

    // 2. ปิดหรือ flush การเชื่อมต่อ
    try {
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
    } catch (_) {}

    // 3. เขียนทับไฟล์ฐานข้อมูล
    if (bytes != null && bytes.isNotEmpty) {
      await localDb.writeAsBytes(bytes, flush: true);
    } else if (filePath != null && filePath.isNotEmpty) {
      final sourceFile = File(filePath);
      if (!await sourceFile.exists()) return false;
      final readBytes = await sourceFile.readAsBytes();
      await localDb.writeAsBytes(readBytes, flush: true);
    } else {
      return false;
    }

    // 4. ลบไฟล์ -wal และ -shm เก่าที่อาจค้างอยู่
    try {
      final walFile = File('${localDb.path}-wal');
      final shmFile = File('${localDb.path}-shm');
      if (await walFile.exists()) await walFile.delete();
      if (await shmFile.exists()) await shmFile.delete();
    } catch (_) {}

    return true;
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

    await localDb.copy(targetFile.path);

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
