import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/services/backup_crypto_helper.dart';

void main() {
  group('BackupCryptoHelper - AES-256 Encryption & Decryption Tests', () {
    test('Encrypt and decrypt round-trip restores exact identical database bytes', () {
      final samplePlaintext = 'SQLite format 3\x00${'A' * 500}Secret financial records: 1,000,000 THB';
      final plainBytes = Uint8List.fromList(utf8.encode(samplePlaintext));
      const password = 'mySecretPin123';

      final encrypted = BackupCryptoHelper.encryptDatabaseBytes(plainBytes, password);

      // Verify header format
      expect(BackupCryptoHelper.isEncrypted(encrypted), isTrue);
      expect(encrypted.length, greaterThan(plainBytes.length));

      // Verify plaintext string is NOT present in encrypted bytes
      final rawString = String.fromCharCodes(encrypted);
      expect(rawString.contains('Secret financial records'), isFalse);

      // Decrypt
      final decrypted = BackupCryptoHelper.decryptDatabaseBytes(encrypted, password);
      expect(decrypted, equals(plainBytes));
      expect(utf8.decode(decrypted), equals(samplePlaintext));
    });

    test('Decrypting with wrong password throws FormatException', () {
      final plainBytes = Uint8List.fromList(utf8.encode('Sensitive banking data'));
      final encrypted = BackupCryptoHelper.encryptDatabaseBytes(plainBytes, 'correctPin');

      expect(
        () => BackupCryptoHelper.decryptDatabaseBytes(encrypted, 'wrongPin'),
        throwsA(isA<FormatException>()),
      );
    });

    test('isEncrypted returns false for raw SQLite or corrupted files', () {
      final sqliteHeader = Uint8List.fromList(utf8.encode('SQLite format 3\x00'));
      expect(BackupCryptoHelper.isEncrypted(sqliteHeader), isFalse);

      final shortBytes = Uint8List.fromList([1, 2, 3]);
      expect(BackupCryptoHelper.isEncrypted(shortBytes), isFalse);
    });
  });
}
