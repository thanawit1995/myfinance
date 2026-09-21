import 'dart:typed_data';

abstract class PlatformFileSaver {
  static Future<bool> saveAndShareFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? title,
  }) async {
    throw UnsupportedError('Cannot save file on unsupported platform');
  }
}
