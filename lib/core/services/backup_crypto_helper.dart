import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class BackupCryptoHelper {
  static const String headerMagic = 'MYFINANCE_ENC_V1'; // exactly 16 ASCII bytes

  /// ตรวจสอบว่าไฟล์ข้อมูลเป็นไฟล์สำรองที่เข้ารหัสไว้หรือไม่
  static bool isEncrypted(List<int> bytes) {
    if (bytes.length < 16) return false;
    final magic = utf8.decode(bytes.sublist(0, 16), allowMalformed: true);
    return magic == headerMagic;
  }

  /// เข้ารหัสไบนารีฐานข้อมูล SQLite ด้วย AES-256 (CBC + PKCS7)
  static Uint8List encryptDatabaseBytes(Uint8List plainBytes, String password) {
    final random = Random.secure();
    final salt = Uint8List.fromList(List<int>.generate(16, (_) => random.nextInt(256)));
    final ivBytes = Uint8List.fromList(List<int>.generate(16, (_) => random.nextInt(256)));

    // Derive 256-bit key from password + salt using SHA-256
    final keyBytes = sha256.convert([...utf8.encode(password), ...salt]).bytes;
    final key = enc.Key(Uint8List.fromList(keyBytes));
    final iv = enc.IV(ivBytes);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);

    // File format: [16 bytes Header] + [16 bytes Salt] + [16 bytes IV] + [Encrypted Data]
    final headerBytes = utf8.encode(headerMagic);
    final output = BytesBuilder(copy: false);
    output.add(headerBytes);
    output.add(salt);
    output.add(ivBytes);
    output.add(encrypted.bytes);

    return output.toBytes();
  }

  /// ถอดรหัสไฟล์สำรองข้อมูล หากรหัสผ่านถูกต้องจะคืนค่าไบนารีของฐานข้อมูล SQLite
  static Uint8List decryptDatabaseBytes(Uint8List encryptedFileBytes, String password) {
    if (!isEncrypted(encryptedFileBytes)) {
      throw const FormatException('ไฟล์ไม่ใช่รูปแบบสำรองข้อมูลที่เข้ารหัสของ MyFinance');
    }

    if (encryptedFileBytes.length < 48) {
      throw const FormatException('ขนาดไฟล์ไม่สมบูรณ์');
    }

    final salt = encryptedFileBytes.sublist(16, 32);
    final ivBytes = encryptedFileBytes.sublist(32, 48);
    final cipherBytes = encryptedFileBytes.sublist(48);

    final keyBytes = sha256.convert([...utf8.encode(password), ...salt]).bytes;
    final key = enc.Key(Uint8List.fromList(keyBytes));
    final iv = enc.IV(Uint8List.fromList(ivBytes));

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    try {
      final decrypted = encrypter.decryptBytes(enc.Encrypted(Uint8List.fromList(cipherBytes)), iv: iv);
      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw const FormatException('รหัสผ่านหรือรหัส PIN ไม่ถูกต้อง ไม่สามารถถอดรหัสได้');
    }
  }

  /// Alias for encryptDatabaseBytes
  static Uint8List encryptDatabase(Uint8List plainBytes, String password) =>
      encryptDatabaseBytes(plainBytes, password);

  /// Alias for decryptDatabaseBytes
  static Uint8List decryptDatabase(Uint8List encryptedFileBytes, String password) =>
      decryptDatabaseBytes(encryptedFileBytes, password);
}
