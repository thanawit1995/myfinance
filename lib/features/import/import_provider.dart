import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_provider.dart';
import 'domain/import_executor.dart';

final importExecutorProvider = Provider<ImportExecutor>((ref) {
  return ImportExecutor(
    db: ref.watch(databaseProvider),
    transactionsDao: ref.watch(transactionsDaoProvider),
    accountsDao: ref.watch(accountsDaoProvider),
    categoriesDao: ref.watch(categoriesDaoProvider),
    importBatchesDao: ref.watch(importBatchesDaoProvider),
  );
});
