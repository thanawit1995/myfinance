import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

abstract class PlatformFileSaver {
  static Future<bool> saveAndShareFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? title,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = p.join(tempDir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final xFile = XFile(file.path, mimeType: mimeType, name: fileName);
      final result = await Share.shareXFiles(
        [xFile],
        text: title ?? fileName,
      );
      return result.status == ShareResultStatus.success;
    } catch (_) {
      return false;
    }
  }
}
