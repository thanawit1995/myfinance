import 'backup_inspection_result.dart';

Future<BackupInspectionResult> inspectSqliteDatabaseFile(
  String filePath, {
  List<int>? bytes,
  String? name,
}) async {
  final fileName = name ?? filePath;
  final size = bytes?.length ?? 0;
  return BackupInspectionResult(
    isValid: size > 0,
    fileName: fileName,
    sizeBytes: size,
  );
}
