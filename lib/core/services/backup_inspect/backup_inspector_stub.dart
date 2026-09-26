import 'dart:convert';
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

  // SQLite header check: "SQLite format 3\0"
  if (bytes != null) {
    final header = ascii.decode(bytes.sublist(0, 16), allowInvalid: true);
    if (!header.startsWith('SQLite format 3')) {
      return BackupInspectionResult(
        isValid: false,
        errorMessage: 'ไฟล์ที่เลือกไม่ใช่ฐานข้อมูล SQLite ของ MyFinance',
        fileName: fileName,
        sizeBytes: size,
      );
    }
  }

  return BackupInspectionResult(
    isValid: true,
    fileName: fileName,
    sizeBytes: size,
  );
}
