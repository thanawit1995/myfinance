import 'dart:convert';
import 'dart:typed_data';
import '../backup_crypto_helper.dart';
import '../sqlite_reader/sqlite_reader.dart';
import 'backup_inspection_result.dart';

Future<BackupInspectionResult> inspectSqliteDatabaseFile(
  String filePath, {
  List<int>? bytes,
  String? name,
  String? password,
}) async {
  final fileName = name ?? filePath;
  final size = bytes?.length ?? 0;

  if (size < 16) {
    return BackupInspectionResult(
      isValid: false,
      errorMessage: 'ไฟล์มีขนาดเล็กเกินไปหรือไม่ถูกต้อง',
      fileName: fileName,
      sizeBytes: size,
    );
  }

  final fileBytes = bytes != null ? Uint8List.fromList(bytes) : Uint8List(0);
  final isEnc = BackupCryptoHelper.isEncrypted(fileBytes);
  Uint8List decryptedBytes = fileBytes;

  if (isEnc) {
    if (password == null || password.isEmpty) {
      return BackupInspectionResult(
        isValid: false,
        isEncrypted: true,
        requiresPassword: true,
        errorMessage: 'ไฟล์สำรองข้อมูลนี้ถูกเข้ารหัสไว้ (AES-256) กรุณาระบุรหัสผ่านหรือรหัส PIN เพื่อเปิดดู',
        fileName: fileName,
        sizeBytes: size,
      );
    }

    try {
      decryptedBytes = BackupCryptoHelper.decryptDatabase(fileBytes, password);
    } catch (_) {
      return BackupInspectionResult(
        isValid: false,
        isEncrypted: true,
        requiresPassword: true,
        errorMessage: 'รหัสผ่านหรือรหัส PIN ไม่ถูกต้อง ไม่สามารถถอดรหัสได้',
        fileName: fileName,
        sizeBytes: size,
      );
    }
  }

  // SQLite header check: "SQLite format 3\0"
  if (decryptedBytes.length >= 16) {
    final header = ascii.decode(decryptedBytes.sublist(0, 16), allowInvalid: true);
    if (!header.startsWith('SQLite format 3')) {
      return BackupInspectionResult(
        isValid: false,
        isEncrypted: isEnc,
        errorMessage: 'ไฟล์ที่เลือกไม่ใช่ฐานข้อมูล SQLite ของ MyFinance',
        fileName: fileName,
        sizeBytes: size,
      );
    }
  } else {
    return BackupInspectionResult(
      isValid: false,
      isEncrypted: isEnc,
      errorMessage: 'ไฟล์ที่เลือกไม่ใช่ฐานข้อมูล SQLite ของ MyFinance',
      fileName: fileName,
      sizeBytes: size,
    );
  }

  try {
    final backupData = await readSqliteBackupData(decryptedBytes);
    final sampleNames = backupData.accounts
        .where((a) => a['deleted_at'] == null)
        .map((a) => a['name']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .take(5)
        .toList();

    return BackupInspectionResult(
      isValid: true,
      isEncrypted: isEnc,
      totalAccounts: backupData.accountsCount,
      sampleAccountNames: sampleNames,
      totalTransactions: backupData.transactionsCount,
      latestTransactionDate: backupData.latestTransactionDate,
      totalCategories: backupData.categories.where((c) => c['deleted_at'] == null).length,
      totalBudgets: backupData.budgets.where((b) => b['deleted_at'] == null).length,
      totalAssets: backupData.assets.where((a) => a['deleted_at'] == null).length,
      totalInsurance: backupData.insurancePolicies.where((i) => i['deleted_at'] == null).length,
      totalLiabilities: backupData.liabilities.where((l) => l['deleted_at'] == null).length,
      totalProjects: backupData.projects.where((p) => p['deleted_at'] == null).length,
      totalRecurringRules: backupData.recurringRules.where((r) => r['deleted_at'] == null).length,
      fileName: fileName,
      sizeBytes: size,
    );
  } catch (e) {
    // If table inspection fails, fallback to basic valid format
    return BackupInspectionResult(
      isValid: true,
      isEncrypted: isEnc,
      fileName: fileName,
      sizeBytes: size,
    );
  }
}
