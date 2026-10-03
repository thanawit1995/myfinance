import 'dart:typed_data';
import 'package:sqlite3/wasm.dart';
import 'sqlite_backup_data.dart';

WasmSqlite3? _cachedSqlite3;
InMemoryFileSystem? _cachedFs;

Future<SqliteBackupData> readSqliteBackupData(Uint8List sqliteBytes) async {
  final sqlite3 = _cachedSqlite3 ??= await WasmSqlite3.loadFromUrl(Uri.base.resolve('sqlite3.wasm'));
  final fs = _cachedFs ??= InMemoryFileSystem();
  try {
    sqlite3.registerVirtualFileSystem(fs, makeDefault: true);
  } catch (_) {
    // Already registered, ignore
  }

  final filename = '/backup_temp_${DateTime.now().millisecondsSinceEpoch}.db';
  final (file: file, outFlags: _) = fs.xOpen(
    Sqlite3Filename(filename),
    SqlFlag.SQLITE_OPEN_CREATE | SqlFlag.SQLITE_OPEN_READWRITE,
  );
  file.xWrite(sqliteBytes, 0);
  file.xClose();

  final db = sqlite3.open(filename);

  List<Map<String, dynamic>> readTable(String tableName) {
    try {
      final result = db.select('SELECT * FROM "$tableName"');
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
  final projects = readTable('projects');
  final installments = readTable('credit_card_installments');
  final lots = readTable('investment_lots');
  final sales = readTable('investment_sales');
  final invIncomes = readTable('investment_incomes');
  final taxDeductions = readTable('tax_deductions');

  // Read all tables dynamically from SQLite database
  final allTables = <String, List<Map<String, dynamic>>>{};
  try {
    final tableList = db.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
    );
    for (final r in tableList) {
      final tName = r['name'] as String;
      allTables[tName] = readTable(tName);
    }
  } catch (_) {}

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
    fs.xDelete(filename, 0);
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
    projects: projects,
    creditCardInstallments: installments,
    investmentLots: lots,
    investmentSales: sales,
    investmentIncomes: invIncomes,
    taxDeductions: taxDeductions,
    allTables: allTables,
  );
}

Future<Uint8List> dumpDriftDatabaseToSqliteBytes(dynamic db) async {
  final sqlite3 = _cachedSqlite3 ??= await WasmSqlite3.loadFromUrl(Uri.base.resolve('sqlite3.wasm'));
  final fs = _cachedFs ??= InMemoryFileSystem();
  try {
    sqlite3.registerVirtualFileSystem(fs, makeDefault: true);
  } catch (_) {}

  final filename = '/export_live_${DateTime.now().millisecondsSinceEpoch}.db';
  final exportDb = sqlite3.open(filename);

  try {
    exportDb.execute('PRAGMA foreign_keys = OFF;');

    final tables = await db.customSelect(
      "SELECT name, sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '_drift_%' AND sql IS NOT NULL ORDER BY name;",
    ).get();

    for (final t in tables) {
      final tableName = t.data['name'] as String;
      final tableSql = t.data['sql'] as String;
      exportDb.execute(tableSql);

      final rows = await db.customSelect('SELECT * FROM "$tableName";').get();
      if (rows.isEmpty) continue;

      final firstRow = rows.first.data;
      final cols = firstRow.keys.map((c) => '"$c"').join(', ');
      final placeholders = firstRow.keys.map((_) => '?').join(', ');
      final stmt = exportDb.prepare('INSERT INTO "$tableName" ($cols) VALUES ($placeholders);');

      for (final r in rows) {
        final values = firstRow.keys.map((c) => r.data[c]).toList();
        stmt.execute(values);
      }
      stmt.dispose();
    }

    final indices = await db.customSelect(
      "SELECT name, sql FROM sqlite_master WHERE type='index' AND sql IS NOT NULL;",
    ).get();
    for (final idx in indices) {
      final idxSql = idx.data['sql'] as String;
      try {
        exportDb.execute(idxSql);
      } catch (_) {}
    }

    final views = await db.customSelect(
      "SELECT name, sql FROM sqlite_master WHERE type='view' AND sql IS NOT NULL;",
    ).get();
    for (final v in views) {
      final viewSql = v.data['sql'] as String;
      try {
        exportDb.execute(viewSql);
      } catch (_) {}
    }

    try {
      final int ver = (db.schemaVersion is int) ? (db.schemaVersion as int) : 10;
      exportDb.execute('PRAGMA user_version = $ver;');
    } catch (_) {
      exportDb.execute('PRAGMA user_version = 10;');
    }
  } finally {
    exportDb.dispose();
  }

  final (file: file, outFlags: _) = fs.xOpen(Sqlite3Filename(filename), 0x00000001); // SQLITE_OPEN_READONLY = 1
  final size = file.xFileSize();
  final buffer = Uint8List(size);
  file.xRead(buffer, 0);
  file.xClose();
  try {
    fs.xDelete(filename, 0);
  } catch (_) {}

  return buffer;
}

