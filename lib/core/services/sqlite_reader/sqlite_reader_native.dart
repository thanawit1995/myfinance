import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'sqlite_backup_data.dart';

Future<SqliteBackupData> readSqliteBackupData(Uint8List sqliteBytes) async {
  Directory tempDir;
  try {
    tempDir = await getTemporaryDirectory();
  } catch (_) {
    tempDir = Directory.systemTemp;
  }
  final tempFile = File(p.join(tempDir.path, 'backup_restore_temp_${DateTime.now().millisecondsSinceEpoch}.db'));
  await tempFile.writeAsBytes(sqliteBytes);

  final db = sqlite.sqlite3.open(tempFile.path, mode: sqlite.OpenMode.readOnly);

  List<Map<String, dynamic>> readTable(String tableName) {
    try {
      final result = db.select('SELECT * FROM $tableName');
      return result.map((row) {
        return <String, dynamic>{
          for (final col in result.columnNames) col: row[col],
        };
      }).toList();
    } catch (_) {
      return [];
    }
  }

  final accounts = readTable('accounts');
  final categories = readTable('categories');
  final transactions = readTable('transactions');
  final assets = readTable('assets');
  final insurance = readTable('insurance_policies');
  final liabilities = readTable('liabilities');
  final budgets = readTable('budgets');
  final recurring = readTable('recurring_rules');

  DateTime? latestDate;
  try {
    final maxDateRow = db.select('SELECT max(transaction_date) as m_date FROM transactions WHERE deleted_at IS NULL');
    final mVal = maxDateRow.first['m_date'];
    if (mVal is String && mVal.isNotEmpty) {
      latestDate = DateTime.tryParse(mVal);
    } else if (mVal is int) {
      latestDate = mVal > 100000000000
          ? DateTime.fromMillisecondsSinceEpoch(mVal)
          : DateTime.fromMillisecondsSinceEpoch(mVal * 1000);
    }
  } catch (_) {}

  db.dispose();
  try {
    await tempFile.delete();
  } catch (_) {}

  return SqliteBackupData(
    accountsCount: accounts.where((a) => a['deleted_at'] == null).length,
    transactionsCount: transactions.where((t) => t['deleted_at'] == null).length,
    latestTransactionDate: latestDate,
    accounts: accounts,
    categories: categories,
    transactions: transactions,
    assets: assets,
    insurancePolicies: insurance,
    liabilities: liabilities,
    budgets: budgets,
    recurringRules: recurring,
  );
}
