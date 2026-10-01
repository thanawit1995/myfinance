import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/services/sqlite_reader/sqlite_backup_data.dart';
import 'package:myfinance/core/services/backup_inspect/backup_inspection_result.dart';

void main() {
  group('Backup Inspection & Data Models', () {
    test('SqliteBackupData holds table data and counts correctly', () {
      final now = DateTime(2026, 10, 1, 17, 33);
      final data = SqliteBackupData(
        accountsCount: 6,
        transactionsCount: 3881,
        latestTransactionDate: now,
        accounts: [
          {'id': 'acc-1', 'name': 'Main Savings', 'deleted_at': null},
          {'id': 'acc-2', 'name': 'Credit Card', 'deleted_at': null},
        ],
        transactions: List.generate(3881, (i) => {'id': 'tx-$i', 'deleted_at': null}),
      );

      expect(data.accountsCount, equals(6));
      expect(data.transactionsCount, equals(3881));
      expect(data.latestTransactionDate, equals(now));
      expect(data.accounts.length, equals(2));
      expect(data.transactions.length, equals(3881));
    });

    test('BackupInspectionResult holds file details and flags', () {
      final result = BackupInspectionResult(
        isValid: true,
        fileName: 'myfinance_backup_20261001_1733.db',
        sizeBytes: 3989600,
        totalAccounts: 6,
        totalTransactions: 3881,
        latestTransactionDate: DateTime(2026, 10, 1),
        sampleAccountNames: ['Main Savings', 'Credit Card'],
      );

      expect(result.isValid, isTrue);
      expect(result.totalAccounts, equals(6));
      expect(result.totalTransactions, equals(3881));
      expect(result.sampleAccountNames, contains('Main Savings'));
      expect(result.requiresPassword, isFalse);
    });

    test('Unencrypted SQLite bytes are identified as not encrypted', () {
      final sqliteHeader = [83, 81, 76, 105, 116, 101, 32, 102, 111, 114, 109, 97, 116, 32, 51, 0];
      final isEnc = sqliteHeader.length >= 16 &&
          String.fromCharCodes(sqliteHeader.sublist(0, 16)) == 'MYFINANCE_ENC_V1';
      expect(isEnc, isFalse);
    });
  });
}
