import 'package:drift/drift.dart';
import 'accounts_table.dart';
import 'currencies_table.dart';

@TableIndex(name: 'idx_snapshots_acc_date', columns: {#accountId, #snapshotDate})
class BalanceSnapshots extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get accountId => text().references(Accounts, #id)();
  DateTimeColumn get snapshotDate => dateTime()();
  IntColumn get closingBalanceSatang => integer()();
  TextColumn get currencyCode => text().references(Currencies, #code)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
