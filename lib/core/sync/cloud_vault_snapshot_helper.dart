import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
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
  /// แพ็กฐานข้อมูล Drift SQLite ทั้งหมด (25 ตาราง) บีบอัดเป็น GZip และแปลงเป็น Base64
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

    final compressed = GZipEncoder().encode(rawBytes);
    if (compressed == null) {
      throw Exception('ไม่สามารถบีบอัดข้อมูลฐานข้อมูลได้');
    }

    final base64Payload = base64Encode(compressed);
    return SnapshotPackResult(
      base64Payload: base64Payload,
      rawSizeBytes: rawBytes.length,
      compressedSizeBytes: compressed.length,
    );
  }

  /// ถอดรหัส Base64 แตกไฟล์ GZip และกู้คืนฐานข้อมูล SQLite ทั้ง 25 ตารางเข้าสู่เครื่อง
  static Future<bool> unpackCompressedBase64ToDatabase(String base64Payload, AppDatabase db) async {
    final compressedBytes = base64Decode(base64Payload.trim());
    final decompressed = GZipDecoder().decodeBytes(compressedBytes);
    final sqliteBytes = Uint8List.fromList(decompressed);

    final service = BackupRestoreService(db: db);
    final ok = await service.restoreDatabase(bytes: sqliteBytes);
    return ok;
  }
}
