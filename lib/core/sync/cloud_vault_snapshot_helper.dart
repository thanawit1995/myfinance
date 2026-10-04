import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../services/backup_restore_service.dart';
import '../services/sqlite_reader/sqlite_reader.dart';

class SnapshotPackResult {
  final String base64Payload;
  final int rawSizeBytes;
  final int compressedSizeBytes;

  const SnapshotPackResult({
    required this.base64Payload,
    required this.rawSizeBytes,
    required this.compressedSizeBytes,
  });
}

class CloudVaultSnapshotHelper {
  /// แพ็กฐานข้อมูล Drift SQLite ทั้งหมด (รวมตารางพอร์ตโฟลิโอ 25 ตาราง)
  /// และรูปภาพที่ผู้ใช้อัปโหลด (Mascot & Card Background) บีบอัดเป็น GZip และแปลงเป็น Base64
  static Future<SnapshotPackResult> packDatabaseToCompressedBase64(AppDatabase db) async {
    // Checkpoint WAL first
    try {
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE);');
    } catch (_) {}

    Uint8List? rawBytes;
    try {
      rawBytes = await dumpDriftDatabaseToSqliteBytes(db);
    } catch (e) {
      debugPrint('[CloudSnapshot] dumpDriftDatabaseToSqliteBytes note: $e');
    }

    if (rawBytes == null || rawBytes.isEmpty) {
      if (!kIsWeb) {
        final service = BackupRestoreService(db: db);
        final file = await service.getLocalDatabaseFile();
        if (file != null && await file.exists()) {
          rawBytes = await file.readAsBytes();
        }
      }
    }

    if (rawBytes == null || rawBytes.isEmpty) {
      throw Exception('ไม่สามารถดึงข้อมูลฐานข้อมูล SQLite ได้');
    }

    // Read custom images from SharedPreferences to pack together (safely in case of uninitialized binding in unit tests)
    String? customMascotB64;
    String? customCardBgB64;
    try {
      final prefs = await SharedPreferences.getInstance();
      customMascotB64 = prefs.getString('custom_lumi_mascot_base64');
      customCardBgB64 = prefs.getString('custom_lumi_card_bg_base64');
    } catch (_) {}

    // Archive containing database and preferences metadata
    final archive = Archive();
    archive.addFile(ArchiveFile('database.sqlite', rawBytes.length, rawBytes));

    final metaMap = <String, dynamic>{
      'version': 1,
      'packaged_at': DateTime.now().toUtc().toIso8601String(),
      'custom_lumi_mascot_base64': ?customMascotB64,
      'custom_lumi_card_bg_base64': ?customCardBgB64,
    };
    final metaBytes = utf8.encode(jsonEncode(metaMap));
    archive.addFile(ArchiveFile('metadata.json', metaBytes.length, metaBytes));

    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) {
      throw Exception('ไม่สามารถบีบอัดข้อมูลสำรองได้');
    }

    final compressed = GZipEncoder().encode(zipData);
    if (compressed == null) {
      throw Exception('ไม่สามารถบีบอัด GZip ได้');
    }

    final base64Payload = base64Encode(compressed);
    return SnapshotPackResult(
      base64Payload: base64Payload,
      rawSizeBytes: rawBytes.length,
      compressedSizeBytes: compressed.length,
    );
  }

  /// ถอดรหัส Base64 แตกไฟล์ GZip และกู้คืนฐานข้อมูล SQLite รวมถึงรูปภาพที่บันทึกไว้เข้าสู่เครื่อง
  static Future<bool> unpackCompressedBase64ToDatabase(String base64Payload, AppDatabase db) async {
    final compressedBytes = base64Decode(base64Payload.trim());
    final decompressed = GZipDecoder().decodeBytes(compressedBytes);

    Uint8List sqliteBytes;

    // Check if decompressed bytes are a ZIP container or raw SQLite file
    try {
      final archive = ZipDecoder().decodeBytes(decompressed);
      final dbFile = archive.findFile('database.sqlite');
      if (dbFile != null) {
        sqliteBytes = Uint8List.fromList(dbFile.content as List<int>);

        // Restore custom preferences & images if present
        final metaFile = archive.findFile('metadata.json');
        if (metaFile != null) {
          try {
            final metaStr = utf8.decode(metaFile.content as List<int>);
            final metaJson = jsonDecode(metaStr) as Map<String, dynamic>;
            final prefs = await SharedPreferences.getInstance();

            if (metaJson['custom_lumi_mascot_base64'] != null) {
              await prefs.setString('custom_lumi_mascot_base64', metaJson['custom_lumi_mascot_base64'] as String);
            }
            if (metaJson['custom_lumi_card_bg_base64'] != null) {
              await prefs.setString('custom_lumi_card_bg_base64', metaJson['custom_lumi_card_bg_base64'] as String);
            }
          } catch (e) {
            debugPrint('[CloudSnapshot] Error restoring metadata/images: $e');
          }
        }
      } else {
        sqliteBytes = Uint8List.fromList(decompressed);
      }
    } catch (_) {
      // Legacy snapshot format: raw SQLite file directly GZipped
      sqliteBytes = Uint8List.fromList(decompressed);
    }

    final service = BackupRestoreService(db: db);
    final ok = await service.restoreDatabase(bytes: sqliteBytes);
    return ok;
  }
}
