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

  /// ค้นหาหรือสร้างโฟลเดอร์สำหรับเก็บข้อมูลแอปบน Google Drive
  Future<String> getOrCreateAppFolderId() async {
    final query = "mimeType = 'application/vnd.google-apps.folder' and name = '$appFolderName' and trashed = false";
    final fileList = await _driveApi.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id, name)',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      return fileList.files!.first.id!;
    }

    // สร้างโฟลเดอร์ใหม่
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
    final folderId = await getOrCreateAppFolderId();
    final dbFile = await findFileInAppFolder(folderId, databaseFileName);
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
    final folderId = await getOrCreateAppFolderId();
    final metaFile = await findFileInAppFolder(folderId, metaFileName);
    if (metaFile == null) return null;

    final media = await _driveApi.files.get(
      metaFile.id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final bytesBuilder = BytesBuilder();
    await for (final chunk in media.stream) {
      bytesBuilder.add(chunk);
    }
    final content = utf8.decode(bytesBuilder.toBytes());
    return jsonDecode(content) as Map<String, dynamic>;
  }

  void close() {
    _client.close();
  }
}
