import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/conflict_logs_table.dart';
import '../tables/transactions_table.dart';
import '../tables/accounts_table.dart';
import '../tables/categories_table.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [ConflictLogs, Transactions, Accounts, Categories])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  Future<void> recordConflict(ConflictLogsCompanion conflict) =>
      into(conflictLogs).insert(conflict);

  Future<List<ConflictLog>> getAllConflicts() {
    return (select(conflictLogs)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Future<int> clearAllConflicts() => delete(conflictLogs).go();

  Future<int> countPendingSync(DateTime? lastSyncTime) async {
    if (lastSyncTime == null) {
      // Everything is pending if never synced
      final txCount = await select(transactions).get().then((l) => l.length);
      final accCount = await select(accounts).get().then((l) => l.length);
      final catCount = await select(categories).get().then((l) => l.length);
      return txCount + accCount + catCount;
    }

    final txCount = await (select(transactions)..where((t) => t.updatedAt.isBiggerThanValue(lastSyncTime))).get().then((l) => l.length);
    final accCount = await (select(accounts)..where((t) => t.updatedAt.isBiggerThanValue(lastSyncTime))).get().then((l) => l.length);
    final catCount = await (select(categories)..where((t) => t.updatedAt.isBiggerThanValue(lastSyncTime))).get().then((l) => l.length);

    return txCount + accCount + catCount;
  }
}
