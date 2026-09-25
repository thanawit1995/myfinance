import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'backup_inspection_result.dart';

Future<BackupInspectionResult> inspectSqliteDatabaseFile(
  String filePath, {
  List<int>? bytes,
  String? name,
}) async {
  final fileName = name ?? p.basename(filePath);
  File tempFile;
  bool isTemp = false;

  if (bytes != null) {
    final tempDir = await getTemporaryDirectory();
    tempFile = File(p.join(tempDir.path, 'inspect_${DateTime.now().millisecondsSinceEpoch}.db'));
    await tempFile.writeAsBytes(bytes);
    isTemp = true;
  } else {
    tempFile = File(filePath);
    if (!await tempFile.exists()) {
      return BackupInspectionResult(
        isValid: false,
        errorMessage: 'ไม่พบไฟล์ที่เลือก',
        fileName: fileName,
      );
    }
  }

  final fileSize = await tempFile.length();
  if (fileSize < 100) {
    if (isTemp) await tempFile.delete().catchError((_) => tempFile);
    return BackupInspectionResult(
      isValid: false,
      errorMessage: 'ขนาดไฟล์เล็กเกินไป ไม่ใช่ไฟล์ฐานข้อมูล SQLite ที่ถูกต้อง',
      fileName: fileName,
      sizeBytes: fileSize,
    );
  }

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
      } catch (_) {}

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
      } catch (_) {}

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
