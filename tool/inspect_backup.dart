import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final dbPath = 'C:\\Users\\Msi\\Downloads\\myfinance_backup_20261003_1024.db';
  final file = File(dbPath);
  if (!file.existsSync()) {
    print('File not found: $dbPath');
    return;
  }

  print('Database File Size: ${file.lengthSync()} bytes');
  final db = sqlite3.open(dbPath);

  // List all tables
  final tables = db.select("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");
  print('\n=== Tables in Backup (${tables.length} tables) ===');
  for (final t in tables) {
    final tName = t['name'] as String;
    final count = db.select('SELECT COUNT(*) as c FROM "$tName"').first['c'];
    print('  - $tName : $count rows');
  }

  // Check Assets (is GPF there?)
  print('\n=== Assets Table ===');
  final assets = db.select('SELECT id, symbol, name, asset_type, deleted_at FROM assets;');
  for (final a in assets) {
    print('  Asset: ${a['symbol']} | ${a['name']} | Type: ${a['asset_type']} | DeletedAt: ${a['deleted_at']}');
  }

  // Check Investment Lots (is GPF lots there?)
  print('\n=== Investment Lots ===');
  final lots = db.select('SELECT l.id, a.symbol, l.quantity, l.deleted_at FROM investment_lots l JOIN assets a ON l.asset_id = a.id;');
  for (final l in lots) {
    print('  Lot: ${l['symbol']} | Qty: ${l['quantity']} | DeletedAt: ${l['deleted_at']}');
  }

  // Check Budgets
  print('\n=== Budgets Table ===');
  final budgets = db.select('SELECT * FROM budgets;');
  print('  Budgets count: ${budgets.length}');
  for (final b in budgets) {
    print('  Budget: ${b['category_id']} | Limit: ${b['limit_satang']} | DeletedAt: ${b['deleted_at']} | IsActive: ${b['is_active']}');
  }

  // Check Categories (sort_order)
  print('\n=== Categories (First 15 with sort_order) ===');
  final cats = db.select('SELECT id, name_th, sort_order, is_system, deleted_at FROM categories ORDER BY sort_order ASC, name_th ASC LIMIT 15;');
  for (final c in cats) {
    print('  Cat: ${c['name_th'].toString().padRight(20)} | sort_order: ${c['sort_order']} | system: ${c['is_system']} | deleted: ${c['deleted_at']}');
  }

  // Check Credit Card Payments & Recent Transactions
  print('\n=== Recent Transactions (Last 10 by transaction_date / created_at) ===');
  final txs = db.select('SELECT id, transaction_type, source_account_id, destination_account_id, amount_thb_satang, transaction_date, note, tag, deleted_at FROM transactions ORDER BY transaction_date DESC, created_at DESC LIMIT 10;');
  for (final tx in txs) {
    print('  Tx: ${tx['transaction_date']} | ${tx['transaction_type']} | ${(tx['amount_thb_satang'] / 100).toStringAsFixed(2)} THB | Src: ${tx['source_account_id']} | Dst: ${tx['destination_account_id']} | Note: ${tx['note']} | Deleted: ${tx['deleted_at']}');
  }

  // Check Credit Card Account & Balance in Backup
  print('\n=== Accounts in Backup ===');
  final accs = db.select('SELECT id, name, account_type, deleted_at FROM accounts;');
  for (final a in accs) {
    print('  Account: ${a['name'].toString().padRight(20)} | Type: ${a['account_type']} | Deleted: ${a['deleted_at']}');
  }

  db.dispose();
}
