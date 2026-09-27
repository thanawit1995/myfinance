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

      // 2. Find transactions associated with this batch
      final txs = await (select(transactions)..where((t) => t.importBatchId.equals(batchId))).get();
      final txIds = txs.map((e) => e.id).toList();

      final affectedAssetIds = <String>{};
      for (final tx in txs) {
        if (tx.assetId != null) {
          affectedAssetIds.add(tx.assetId!);
        }
        if (tx.tag != null && tx.tag!.startsWith('investment_buy:')) {
          affectedAssetIds.add(tx.tag!.substring('investment_buy:'.length));
        }
      }

      // 3. Delete investment lots referencing these transactions first to avoid FK constraint failures
      if (txIds.isNotEmpty) {
        await (delete(attachedDatabase.investmentLots)
              ..where((l) => l.buyTransactionId.isIn(txIds)))
            .go();
      }

      // 4. Delete transactions associated with this batch
      final deletedCount = await (delete(transactions)..where((t) => t.importBatchId.equals(batchId))).go();

      // 5. Recalculate FIFO for any affected assets to keep portfolio balance consistent
      for (final assetId in affectedAssetIds) {
        await attachedDatabase.investmentsDao.recalculateFifoForAsset(assetId);
      }

      return deletedCount;
    });
  }

  /// Cleans up any unbatched investment lots and transactions (created before batch tracking existed)
  /// so user can cleanly re-import without duplicates or leftover records.
  Future<int> resetUnbatchedInvestments() async {
    return transaction(() async {
      final unbatchedTxs = await (select(transactions)
            ..where((t) =>
                t.importBatchId.isNull() &
                (t.assetId.isNotNull() | t.tag.like('investment_buy:%'))))
          .get();
      final txIds = unbatchedTxs.map((e) => e.id).toList();

      if (txIds.isNotEmpty) {
        await (delete(attachedDatabase.investmentLots)
              ..where((l) => l.buyTransactionId.isIn(txIds)))
            .go();
      }

      // Also clean up any orphan lots whose buy transaction no longer exists
      final allLots = await select(attachedDatabase.investmentLots).get();
      for (final lot in allLots) {
        final tx = await (select(transactions)..where((t) => t.id.equals(lot.buyTransactionId))).getSingleOrNull();
        if (tx == null) {
          await (delete(attachedDatabase.investmentLots)..where((l) => l.id.equals(lot.id))).go();
        }
      }

      int deletedCount = 0;
      if (txIds.isNotEmpty) {
        deletedCount = await (delete(transactions)..where((t) => t.id.isIn(txIds))).go();
      }

      // Recalculate FIFO for all assets
      final allAssets = await select(attachedDatabase.assets).get();
      for (final asset in allAssets) {
        await attachedDatabase.investmentsDao.recalculateFifoForAsset(asset.id);
      }

      return deletedCount;
    });
  }
}
