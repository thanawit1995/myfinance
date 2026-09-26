import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../backup_crypto_helper.dart';
import 'backup_inspection_result.dart';

Future<BackupInspectionResult> inspectSqliteDatabaseFile(
  String filePath, {
  List<int>? bytes,
  String? name,
  String? password,
}) async {
  final fileName = name ?? p.basename(filePath);
  File tempFile;
  bool isTemp = false;

  Uint8List fileBytes;
  if (bytes != null) {
    fileBytes = Uint8List.fromList(bytes);
  } else {
    final originalFile = File(filePath);
    if (!await originalFile.exists()) {
      return BackupInspectionResult(
        isValid: false,
        errorMessage: 'ไม่พบไฟล์ที่เลือก',
        fileName: fileName,
      );
    }
    fileBytes = await originalFile.readAsBytes();
  }

  final fileSize = fileBytes.length;
  if (fileSize < 16) {
    return BackupInspectionResult(
      isValid: false,
      errorMessage: 'ขนาดไฟล์เล็กเกินไป ไม่ใช่ไฟล์ฐานข้อมูล SQLite ที่ถูกต้อง',
      fileName: fileName,
      sizeBytes: fileSize,
    );
  }

  // Check if encrypted
  final isEnc = BackupCryptoHelper.isEncrypted(fileBytes);
  if (isEnc) {
    if (password == null || password.isEmpty) {
      return BackupInspectionResult(
        isValid: false,
        isEncrypted: true,
        requiresPassword: true,
        errorMessage: 'ไฟล์สำรองข้อมูลนี้ถูกเข้ารหัสไว้ (AES-256) กรุณาระบุรหัสผ่านหรือรหัส PIN เพื่อเปิดดู',
        fileName: fileName,
        sizeBytes: fileSize,
      );
    }

    try {
      fileBytes = BackupCryptoHelper.decryptDatabaseBytes(fileBytes, password);
    } catch (e) {
      return BackupInspectionResult(
        isValid: false,
        isEncrypted: true,
        requiresPassword: true,
        errorMessage: 'รหัสผ่านหรือรหัส PIN ไม่ถูกต้อง ไม่สามารถถอดรหัสได้',
        fileName: fileName,
        sizeBytes: fileSize,
      );
    }
  }

  // Check valid SQLite format 3 magic header
  final headerStr = utf8.decode(fileBytes.sublist(0, 15), allowMalformed: true);
  if (headerStr != 'SQLite format 3') {
    return BackupInspectionResult(
      isValid: false,
      isEncrypted: isEnc,
      errorMessage: 'ไฟล์ที่เลือกไม่ใช่ฐานข้อมูล SQLite หรือรหัสผ่านไม่ถูกต้อง',
      fileName: fileName,
      sizeBytes: fileSize,
    );
  }

  Directory tempDir;
  try {
    tempDir = await getTemporaryDirectory();
  } catch (_) {
    tempDir = Directory.systemTemp;
  }
  tempFile = File(p.join(tempDir.path, 'inspect_${DateTime.now().millisecondsSinceEpoch}.db'));
  await tempFile.writeAsBytes(fileBytes);
  isTemp = true;

  try {
    final inspectedDb = sqlite.sqlite3.open(tempFile.path, mode: sqlite.OpenMode.readOnly);
    try {
      int accountsCount = 0;
      final sampleNames = <String>[];
      try {
        final accRow = inspectedDb.select('SELECT count(*) as cnt FROM accounts WHERE deleted_at IS NULL');
        accountsCount = accRow.first['cnt'] as int? ?? 0;
        final nameRows = inspectedDb.select('SELECT name FROM accounts WHERE deleted_at IS NULL LIMIT 5');
        for (final r in nameRows) {
          final n = r['name'];
          if (n is String && n.isNotEmpty) sampleNames.add(n);
        }
      } catch (_) {
        try {
          final accRow = inspectedDb.select('SELECT count(*) as cnt FROM accounts');
          accountsCount = accRow.first['cnt'] as int? ?? 0;
          final nameRows = inspectedDb.select('SELECT name FROM accounts LIMIT 5');
          for (final r in nameRows) {
            final n = r['name'];
            if (n is String && n.isNotEmpty) sampleNames.add(n);
          }
        } catch (_) {}
      }

      int txCount = 0;
      DateTime? latestDate;
      try {
        final txRow = inspectedDb.select(
          'SELECT count(*) as cnt, max(transaction_date) as max_date FROM transactions WHERE deleted_at IS NULL',
        );
        txCount = txRow.first['cnt'] as int? ?? 0;
        final maxD = txRow.first['max_date'];
        if (maxD is String && maxD.isNotEmpty) {
          latestDate = DateTime.tryParse(maxD);
        } else if (maxD is int) {
          latestDate = DateTime.fromMillisecondsSinceEpoch(maxD);
        }
      } catch (_) {
        try {
          final txRow = inspectedDb.select(
            'SELECT count(*) as cnt, max(transaction_date) as max_date FROM transactions',
          );
          txCount = txRow.first['cnt'] as int? ?? 0;
          final maxD = txRow.first['max_date'];
          if (maxD is String && maxD.isNotEmpty) {
            latestDate = DateTime.tryParse(maxD);
          } else if (maxD is int) {
            latestDate = DateTime.fromMillisecondsSinceEpoch(maxD);
          }
        } catch (_) {}
      }

      return BackupInspectionResult(
        isValid: true,
        totalAccounts: accountsCount,
        sampleAccountNames: sampleNames,
        totalTransactions: txCount,
        latestTransactionDate: latestDate,
        sizeBytes: fileSize,
        fileName: fileName,
      );
    } finally {
      inspectedDb.dispose();
    }
  } catch (e) {
    return BackupInspectionResult(
      isValid: false,
      errorMessage: 'ไม่สามารถอ่านโครงสร้างฐานข้อมูลได้: $e',
      fileName: fileName,
      sizeBytes: fileSize,
    );
  } finally {
    if (isTemp) {
      await tempFile.delete().catchError((_) => tempFile);
    }
  }
}
