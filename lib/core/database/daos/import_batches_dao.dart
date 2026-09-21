import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/import_batches_table.dart';
import '../tables/transactions_table.dart';

part 'import_batches_dao.g.dart';

@DriftAccessor(tables: [ImportBatches, Transactions])
class ImportBatchesDao extends DatabaseAccessor<AppDatabase> with _$ImportBatchesDaoMixin {
  ImportBatchesDao(super.db);

  Future<void> createBatch(ImportBatchesCompanion batch) => into(importBatches).insert(batch);

  Future<List<ImportBatch>> getAllBatches() {
    return (select(importBatches)..orderBy([(t) => OrderingTerm.desc(t.importedAt)])).get();
  }

  Future<ImportBatch?> getBatchById(String id) {
    return (select(importBatches)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> rollbackBatch(String batchId) async {
    return transaction(() async {
      // 1. Mark batch as rolled back
      final now = DateTime.now();
      await (update(importBatches)..where((t) => t.id.equals(batchId))).write(
        ImportBatchesCompanion(
          isRolledBack: const Value(true),
          rolledBackAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      // 2. Delete or soft delete transactions associated with this batch
      return await (delete(transactions)..where((t) => t.importBatchId.equals(batchId))).go();
    });
  }
}
