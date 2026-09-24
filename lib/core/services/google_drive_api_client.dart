import 'dart:convert';
import 'dart:typed_data';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class RemoteDriveFileInfo {
  final String id;
  final String name;
  final DateTime? modifiedTime;
  final int? sizeBytes;

  const RemoteDriveFileInfo({
    required this.id,
    required this.name,
    this.modifiedTime,
    this.sizeBytes,
  });
}

class GoogleDriveApiClient {
  final http.Client _client;
  late final drive.DriveApi _driveApi;

  static const String appFolderName = 'MyFinance_Backup';
  static const String databaseFileName = 'myfinance_vault.db';
  static const String metaFileName = 'vault_sync_meta.json';

  GoogleDriveApiClient(this._client) {
    _driveApi = drive.DriveApi(_client);
  }

  /// ค้นหาโฟลเดอร์ตามชื่อ
  Future<String?> findFolderId(String folderName) async {
    try {
      final query = "mimeType = 'application/vnd.google-apps.folder' and name = '$folderName' and trashed = false";
      final fileList = await _driveApi.files.list(
        q: query,
        spaces: 'drive',
        $fields: 'files(id, name)',
      );
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }
    } catch (_) {}
    return null;
  }

  /// ค้นหาหรือสร้างโฟลเดอร์สำหรับเก็บข้อมูลแอปบน Google Drive
  Future<String> getOrCreateAppFolderId() async {
    // 1. ลองหา MyFinance_Backup ก่อน
    final existingAppFolder = await findFolderId(appFolderName);
    if (existingAppFolder != null) return existingAppFolder;

    // 2. ถ้ามีโฟลเดอร์ VAULT ของ Desktop อยู่แล้ว ให้ใช้ VAULT
    final existingVaultFolder = await findFolderId('VAULT');
    if (existingVaultFolder != null) return existingVaultFolder;

    // 3. สร้างโฟลเดอร์ใหม่ MyFinance_Backup
    final folderMeta = drive.File()
      ..name = appFolderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final createdFolder = await _driveApi.files.create(
      folderMeta,
      $fields: 'id',
    );

    return createdFolder.id!;
  }

  /// ค้นหาไฟล์ตามชื่อในโฟลเดอร์แอป
  Future<RemoteDriveFileInfo?> findFileInAppFolder(String folderId, String fileName) async {
    final query = "'$folderId' in parents and name = '$fileName' and trashed = false";
    final fileList = await _driveApi.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id, name, modifiedTime, size)',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      final f = fileList.files!.first;
      return RemoteDriveFileInfo(
        id: f.id!,
        name: f.name ?? fileName,
        modifiedTime: f.modifiedTime,
        sizeBytes: f.size != null ? int.tryParse(f.size!) : null,
      );
    }
    return null;
  }

  /// ค้นหาไฟล์ฐานข้อมูลบน Google Drive ในทุกตำแหน่งที่เป็นไปได้
  Future<RemoteDriveFileInfo?> findDatabaseFile() async {
    // 1. ลองหาในโฟลเดอร์ MyFinance_Backup
    final appFolderId = await findFolderId(appFolderName);
    if (appFolderId != null) {
      final f = await findFileInAppFolder(appFolderId, databaseFileName);
      if (f != null) return f;
    }

    // 2. ลองหาในโฟลเดอร์ VAULT (ที่ Google Drive Desktop ซิงค์มาจาก Windows)
    final vaultFolderId = await findFolderId('VAULT');
    if (vaultFolderId != null) {
      final f = await findFileInAppFolder(vaultFolderId, databaseFileName);
      if (f != null) return f;
    }

    // 3. ค้นหาไฟล์ myfinance_vault.db หรือ myfinance.sqlite ทั่วทั้ง Drive
    final candidateNames = [databaseFileName, 'myfinance.sqlite', 'myfinance.db'];
    for (final cName in candidateNames) {
      try {
        final query = "name = '$cName' and trashed = false";
        final fileList = await _driveApi.files.list(
          q: query,
          spaces: 'drive',
          orderBy: 'modifiedTime desc',
          $fields: 'files(id, name, modifiedTime, size)',
        );
        if (fileList.files != null && fileList.files!.isNotEmpty) {
          final f = fileList.files!.first;
          return RemoteDriveFileInfo(
            id: f.id!,
            name: f.name ?? cName,
            modifiedTime: f.modifiedTime,
            sizeBytes: f.size != null ? int.tryParse(f.size!) : null,
          );
        }
      } catch (_) {}
    }

    return null;
  }

  /// อัปโหลดไฟล์ฐานข้อมูลไปยัง Google Drive (สร้างใหม่หรืออัปเดตไฟล์เดิม)
  Future<void> uploadDatabaseAndMeta({
    required Uint8List dbBytes,
    required Map<String, dynamic> metadata,
  }) async {
    final folderId = await getOrCreateAppFolderId();

    // 1. อัปโหลด/อัปเดตไฟล์ฐานข้อมูล .db
    final existingDb = await findFileInAppFolder(folderId, databaseFileName);
    final mediaStream = Stream<List<int>>.value(dbBytes);
    final uploadMedia = drive.Media(mediaStream, dbBytes.length);

    if (existingDb != null) {
      // อัปเดตไฟล์เดิม
      await _driveApi.files.update(
        drive.File(),
        existingDb.id,
        uploadMedia: uploadMedia,
      );
    } else {
      // สร้างไฟล์ใหม่
      final fileMetadata = drive.File()
        ..name = databaseFileName
        ..parents = [folderId];

      await _driveApi.files.create(
        fileMetadata,
        uploadMedia: uploadMedia,
      );
    }

    // 2. อัปโหลด/อัปเดตไฟล์ metadata .json
    final metaBytes = utf8.encode(jsonEncode(metadata));
    final metaStream = Stream<List<int>>.value(metaBytes);
    final metaMedia = drive.Media(metaStream, metaBytes.length);

    final existingMeta = await findFileInAppFolder(folderId, metaFileName);
    if (existingMeta != null) {
      await _driveApi.files.update(
        drive.File(),
        existingMeta.id,
        uploadMedia: metaMedia,
      );
    } else {
      final metaFile = drive.File()
        ..name = metaFileName
        ..parents = [folderId];

      await _driveApi.files.create(
        metaFile,
        uploadMedia: metaMedia,
      );
    }
  }

  /// ดาวน์โหลดไฟล์ฐานข้อมูลลงมาเป็น bytes
  Future<Uint8List?> downloadDatabaseBytes() async {
    final dbFile = await findDatabaseFile();
    if (dbFile == null) return null;

    final media = await _driveApi.files.get(
      dbFile.id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytesBuilder = BytesBuilder();
    await for (final chunk in media.stream) {
      bytesBuilder.add(chunk);
    }
    return bytesBuilder.toBytes();
  }

  /// อ่าน metadata จากคลาวด์
  Future<Map<String, dynamic>?> downloadMetadata() async {
    String? metaFileId;

    // 1. ลองหาใน MyFinance_Backup
    final appFolderId = await findFolderId(appFolderName);
    if (appFolderId != null) {
      final metaFile = await findFileInAppFolder(appFolderId, metaFileName);
      if (metaFile != null) metaFileId = metaFile.id;
    }

    // 2. ลองหาใน VAULT
    if (metaFileId == null) {
      final vaultFolderId = await findFolderId('VAULT');
      if (vaultFolderId != null) {
        final metaFile = await findFileInAppFolder(vaultFolderId, metaFileName);
        if (metaFile != null) metaFileId = metaFile.id;
      }
    }

    // 3. ลองค้นหาชื่อ vault_sync_meta.json ทั่วทั้ง Drive
    if (metaFileId == null) {
      try {
        final query = "name = '$metaFileName' and trashed = false";
        final fileList = await _driveApi.files.list(
          q: query,
          spaces: 'drive',
          orderBy: 'modifiedTime desc',
          $fields: 'files(id, name)',
        );
        if (fileList.files != null && fileList.files!.isNotEmpty) {
          metaFileId = fileList.files!.first.id;
        }
      } catch (_) {}
    }

    if (metaFileId == null) return null;

    try {
      final media = await _driveApi.files.get(
        metaFileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytesBuilder = BytesBuilder();
      await for (final chunk in media.stream) {
        bytesBuilder.add(chunk);
      }
      final content = utf8.decode(bytesBuilder.toBytes());
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void close() {
    _client.close();
  }
}
