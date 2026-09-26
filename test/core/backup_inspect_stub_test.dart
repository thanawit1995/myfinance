import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/services/backup_crypto_helper.dart';
import 'package:myfinance/core/services/backup_inspect/backup_inspector_stub.dart';

void main() {
  group('BackupInspectorStub Web Inspection Tests', () {
    test('Valid raw SQLite bytes pass inspection', () async {
      final sampleSqlite = 'SQLite format 3\x00${'B' * 100}';
      final bytes = Uint8List.fromList(utf8.encode(sampleSqlite));

      final result = await inspectSqliteDatabaseFile('backup.db', bytes: bytes);
      expect(result.isValid, isTrue);
      expect(result.isEncrypted, isFalse);
      expect(result.requiresPassword, isFalse);
    });

    test('Encrypted SQLite bytes without password request password', () async {
      final sampleSqlite = 'SQLite format 3\x00${'C' * 100}';
      final plainBytes = Uint8List.fromList(utf8.encode(sampleSqlite));
      final encBytes = BackupCryptoHelper.encryptDatabase(plainBytes, 'testPin456');

      final result = await inspectSqliteDatabaseFile('backup.db', bytes: encBytes);
      expect(result.isValid, isFalse);
      expect(result.isEncrypted, isTrue);
      expect(result.requiresPassword, isTrue);
    });

    test('Encrypted SQLite bytes with correct password pass inspection', () async {
      final sampleSqlite = 'SQLite format 3\x00${'D' * 100}';
      final plainBytes = Uint8List.fromList(utf8.encode(sampleSqlite));
      final encBytes = BackupCryptoHelper.encryptDatabase(plainBytes, 'testPin456');

      final result = await inspectSqliteDatabaseFile(
        'backup.db',
        bytes: encBytes,
        password: 'testPin456',
      );
      expect(result.isValid, isTrue);
      expect(result.isEncrypted, isTrue);
      expect(result.requiresPassword, isFalse);
    });

    test('Encrypted SQLite bytes with incorrect password fail inspection with password error', () async {
      final sampleSqlite = 'SQLite format 3\x00${'E' * 100}';
      final plainBytes = Uint8List.fromList(utf8.encode(sampleSqlite));
      final encBytes = BackupCryptoHelper.encryptDatabase(plainBytes, 'testPin456');

      final result = await inspectSqliteDatabaseFile(
        'backup.db',
        bytes: encBytes,
        password: 'wrongPassword',
      );
      expect(result.isValid, isFalse);
      expect(result.isEncrypted, isTrue);
      expect(result.requiresPassword, isTrue);
      expect(result.errorMessage, contains('รหัสผ่านหรือรหัส PIN ไม่ถูกต้อง'));
    });
  });
}
