import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class BackupService {
  static Future<File?> getDatabaseFile() async {
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
    return null;
  }

  /// Exports the SQLite database file and shares it via system share sheet.
  static Future<bool> exportDatabase(BuildContext context) async {
    final dbFile = await getDatabaseFile();
    if (dbFile == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบไฟล์ฐานข้อมูลในเครื่อง')),
        );
      }
      return false;
    }

    try {
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final tempDir = await getTemporaryDirectory();
      final exportFile = File(p.join(tempDir.path, 'myfinance_backup_$dateStr.db'));

      await dbFile.copy(exportFile.path);

      final xFile = XFile(exportFile.path, mimeType: 'application/x-sqlite3');
      final result = await Share.shareXFiles(
        [xFile],
        text: 'MyFinance Database Backup ($dateStr)',
      );

      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('Export error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งออก: $e')),
        );
      }
      return false;
    }
  }

  /// Restores a database file by copying over the current active database.
  static Future<bool> restoreDatabase(String sourceFilePath) async {
    final target = await getDatabaseFile();
    final docDir = await getApplicationDocumentsDirectory();
    final dbPath = target?.path ?? p.join(docDir.path, 'myfinance_vault.sqlite');
    final source = File(sourceFilePath);

    if (!await source.exists()) {
      return false;
    }

    await source.copy(dbPath);
    return true;
  }
}
