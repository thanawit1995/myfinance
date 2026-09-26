import 'dart:convert';
import 'dart:typed_data';
import '../backup_crypto_helper.dart';
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

  return BackupInspectionResult(
    isValid: true,
    isEncrypted: isEnc,
    fileName: fileName,
    sizeBytes: size,
  );
}

